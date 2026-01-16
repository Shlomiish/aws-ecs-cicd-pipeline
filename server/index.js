// import { Kafka } from 'kafkajs';
// import 'dotenv/config';
// import { createApp } from './app.js';

// const PORT = process.env.PORT || 3000;
// const KAFKA_BROKER = process.env.KAFKA_BROKER;
// const KAFKA_TOPIC = process.env.KAFKA_TOPIC;

// const kafka = new Kafka({ clientId: 'demo-server', brokers: [KAFKA_BROKER] });
// const producer = kafka.producer();

// async function startKafka() {
//   console.log('[server] Step: connect Kafka producer...');
//   await producer.connect();
//   console.log('[server] Step: Kafka producer connected ✅');
// }

// async function sendKafkaEvent(payload) {
//   console.log(`[server] Step: send event to Kafka topic=${KAFKA_TOPIC}`, payload);

//   await producer.send({
//     topic: KAFKA_TOPIC,
//     messages: [{ key: payload.button, value: JSON.stringify(payload) }],
//   });

//   console.log('[server] Step: event sent ✅');
// }

// const app = createApp({ sendKafkaEvent });

// startKafka()
//   .then(() => {
//     console.log('[server] Step: start HTTP server...');
//     app.listen(PORT, () => console.log(`[server] listening on port ${PORT} ✅`));
//   })
//   .catch((err) => {
//     console.error('[server] Kafka init failed ❌', err);
//     process.exit(1);
//   });

// process.on('SIGINT', async () => {
//   console.log('[server] shutdown: disconnect producer...');
//   await producer.disconnect();
//   process.exit(0);
// });

import 'dotenv/config';
import { createApp } from './app.js';
import { initSQS, logToSQS } from './sqs-logger.js';

const PORT = process.env.PORT || 3000;

// Initialize SQS (optional - won't crash if not configured)
initSQS();

async function sendLogToSQS(payload) {
  console.log('[server] Step: logging event...', payload);

  // Send to SQS (won't fail if SQS is not configured)
  await logToSQS('info', 'Button clicked', {
    button: payload.button,
    message: payload.message,
    timestamp: payload.timestamp,
  });

  console.log('[server] Step: event logged ✅');
}

const app = createApp({ sendLogToSQS });

console.log('[server] Step: start HTTP server...');
app.listen(PORT, () => {
  console.log(`[server] listening on port ${PORT} ✅`);
});

process.on('SIGINT', async () => {
  console.log('[server] shutdown...');
  process.exit(0);
});
