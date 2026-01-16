// import { Kafka } from 'kafkajs';
// import 'dotenv/config';

// const KAFKA_BROKER = process.env.KAFKA_BROKER; // Kafka broker address

// const KAFKA_TOPIC = process.env.KAFKA_TOPIC; // Kafka topic name to consume messages from

// const KAFKA_GROUP_ID = process.env.KAFKA_GROUP_ID; // Consumer group ID (used by Kafka to manage offsets and load balancing)

// const CONSUMER_NAME = process.env.CONSUMER_NAME;

// const kafka = new Kafka({ clientId: CONSUMER_NAME, brokers: [KAFKA_BROKER] }); // Create a Kafka client with a clientId and broker list

// const consumer = kafka.consumer({ groupId: KAFKA_GROUP_ID }); // Create a Kafka consumer instance belonging to the given consumer group

// async function run() {
//   console.log('[consumer] Step: connect...');
//   await consumer.connect(); // Connect the consumer to the Kafka broker

//   console.log('[consumer] Step: subscribe...');
//   await consumer.subscribe({ topic: KAFKA_TOPIC, fromBeginning: true }); // Subscribe to the topic and read messages from the beginning

//   console.log('[consumer] Step: running ✅');

//   await consumer.run({
//     eachMessage: async ({ topic, partition, message }) => {
//       const key = message.key?.toString(); // Convert message key from bytes to string

//       const value = message.value?.toString(); // Convert message value from bytes to string

//       console.log(
//         `[consumer] Step: received topic=${topic} partition=${partition} key=${key} value=${value}`
//       );
//     },
//   });
// }

// run().catch((err) => {
//   console.error('[consumer] failed ❌', err);

//   process.exit(1);
// });

// process.on('SIGINT', async () => {
//   console.log('[consumer] shutdown...'); // Handle Ctrl+C or container shutdown signal

//   await consumer.disconnect(); // Gracefully disconnect from Kafka

//   process.exit(0); // Gracefully disconnect from Kafka
// });

import 'dotenv/config';
import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from '@aws-sdk/client-sqs';

const REGION = process.env.AWS_REGION;
const QUEUE_URL = process.env.SQS_QUEUE_URL;

if (!QUEUE_URL) {
  console.log('[consumer] ⚠️  SQS is DISABLED (missing SQS_QUEUE_URL). Exiting.');
  process.exit(0);
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
