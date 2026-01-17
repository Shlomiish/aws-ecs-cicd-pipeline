import 'dotenv/config';
import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from '@aws-sdk/client-sqs';

const REGION = process.env.AWS_REGION;
const QUEUE_URL = process.env.SQS_QUEUE_URL;

// if (!QUEUE_URL) {
//   console.log('[consumer] ⚠️  SQS is DISABLED (missing SQS_QUEUE_URL). Exiting.');
//   process.exit(0);
// }

if (!QUEUE_URL) {
  console.log('[consumer] ⚠️  SQS disabled – running in idle mode');
  setInterval(() => {
    console.log('[consumer] idle heartbeat...');
  }, 5000);
  return;
}

const sqs = new SQSClient({ region: REGION });

async function pollOnce() {
  const res = await sqs.send(
    new ReceiveMessageCommand({
      QueueUrl: QUEUE_URL,
      MaxNumberOfMessages: 5,
      WaitTimeSeconds: 20, // long polling
      VisibilityTimeout: 30,
      MessageAttributeNames: ['All'],
    })
  );

  if (!res.Messages || res.Messages.length === 0) {
    console.log('[consumer] no messages...');
    return;
  }

  for (const msg of res.Messages) {
    try {
      console.log('[consumer] received message:', msg.Body);

      await sqs.send(
        new DeleteMessageCommand({
          QueueUrl: QUEUE_URL,
          ReceiptHandle: msg.ReceiptHandle,
        })
      );

      console.log('[consumer] deleted message ✅');
    } catch (err) {
      console.error('[consumer] failed handling message:', err.message);
    }
  }
}

async function main() {
  console.log('[consumer] starting poll loop...');
  // endless loop
  // eslint-disable-next-line no-constant-condition
  while (true) {
    try {
      await pollOnce();
    } catch (err) {
      console.error('[consumer] poll error:', err.message);
      // small backoff so we don’t spam
      await new Promise((r) => setTimeout(r, 2000));
    }
  }
}

main();

process.on('SIGINT', () => {
  console.log('[consumer] shutdown...');
  process.exit(0);
});
