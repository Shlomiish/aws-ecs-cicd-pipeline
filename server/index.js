// import express from 'express';

// import morgan from 'morgan'; // automatically prints a log for every http request that enters the server instead of console log each time

// import cors from 'cors'; // allow to the frontend make request to the backend, like a security but in the web level

// import { Kafka } from 'kafkajs';

// import 'dotenv/config';

// const app = express();

// app.use(express.json()); // parse incoming JSON request bodies

// app.use(cors());

// app.use(morgan('combined')); // produces access logs in Apache standard format, which includes IP, method, path, status

// const PORT = process.env.PORT;

// const KAFKA_BROKER = process.env.KAFKA_BROKER;

// const KAFKA_TOPIC = process.env.KAFKA_TOPIC;

// const kafka = new Kafka({ clientId: 'demo-server', brokers: [KAFKA_BROKER] });

// const producer = kafka.producer();

// async function startKafka() {
//   console.log('[server] Step: connect Kafka producer...');
//   await producer.connect();

//   console.log('[server] Step: Kafka producer connected ✅');
// }

// function buildPayload(button) {
//   return {
//     ok: true,
//     button,
//     message: button === 'button1' ? 'Hello from API #1' : 'Hello from API #2',
//     timestamp: new Date().toISOString(),
//   };
// }

// async function sendKafkaEvent(payload) {
//   console.log(`[server] Step: send event to Kafka topic=${KAFKA_TOPIC}`, payload);

//   await producer.send({
//     topic: KAFKA_TOPIC,
//     messages: [{ key: payload.button, value: JSON.stringify(payload) }],
//   });

//   console.log('[server] Step: event sent ✅');
// }

// app.get('/api/button1', async (req, res) => {
//   console.log('[server] Step: /api/button1 called');

//   const payload = buildPayload('button1');

//   await sendKafkaEvent(payload);

//   res.json(payload);
// });

// app.get('/api/button2', async (req, res) => {
//   console.log('[server] Step: /api/button2 called');

//   const payload = buildPayload('button2');

//   await sendKafkaEvent(payload);

//   res.json(payload);
// });

// app.get('/api/health', (req, res) => res.json({ ok: true }));

// startKafka()
//   .then(() => {
//     console.log('[server] Step: start HTTP server...'); // Start HTTP server only after Kafka is ready

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
import { Kafka } from 'kafkajs';
import 'dotenv/config';
import { createApp } from './app.js';

const PORT = process.env.PORT || 3000;
const KAFKA_BROKER = process.env.KAFKA_BROKER;
const KAFKA_TOPIC = process.env.KAFKA_TOPIC;

const kafka = new Kafka({ clientId: 'demo-server', brokers: [KAFKA_BROKER] });
const producer = kafka.producer();

async function startKafka() {
  console.log('[server] Step: connect Kafka producer...');
  await producer.connect();
  console.log('[server] Step: Kafka producer connected ✅');
}

async function sendKafkaEvent(payload) {
  console.log(`[server] Step: send event to Kafka topic=${KAFKA_TOPIC}`, payload);

  await producer.send({
    topic: KAFKA_TOPIC,
    messages: [{ key: payload.button, value: JSON.stringify(payload) }],
  });

  console.log('[server] Step: event sent ✅');
}

const app = createApp({ sendKafkaEvent });

startKafka()
  .then(() => {
    console.log('[server] Step: start HTTP server...');
    app.listen(PORT, () => console.log(`[server] listening on port ${PORT} ✅`));
  })
  .catch((err) => {
    console.error('[server] Kafka init failed ❌', err);
    process.exit(1);
  });

process.on('SIGINT', async () => {
  console.log('[server] shutdown: disconnect producer...');
  await producer.disconnect();
  process.exit(0);
});
