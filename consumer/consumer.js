import { Kafka } from 'kafkajs';
import 'dotenv/config';

const KAFKA_BROKER = process.env.KAFKA_BROKER; // Kafka broker address

const KAFKA_TOPIC = process.env.KAFKA_TOPIC; // Kafka topic name to consume messages from

const KAFKA_GROUP_ID = process.env.KAFKA_GROUP_ID; // Consumer group ID (used by Kafka to manage offsets and load balancing)

const CONSUMER_NAME = process.env.CONSUMER_NAME;

const kafka = new Kafka({ clientId: CONSUMER_NAME, brokers: [KAFKA_BROKER] }); // Create a Kafka client with a clientId and broker list

const consumer = kafka.consumer({ groupId: KAFKA_GROUP_ID }); // Create a Kafka consumer instance belonging to the given consumer group

async function run() {
  console.log('[consumer] Step: connect...');
  await consumer.connect(); // Connect the consumer to the Kafka broker

  console.log('[consumer] Step: subscribe...');
  await consumer.subscribe({ topic: KAFKA_TOPIC, fromBeginning: true }); // Subscribe to the topic and read messages from the beginning

  console.log('[consumer] Step: running ✅');

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const key = message.key?.toString(); // Convert message key from bytes to string

      const value = message.value?.toString(); // Convert message value from bytes to string

      console.log(
        `[consumer] Step: received topic=${topic} partition=${partition} key=${key} value=${value}`
      );
    },
  });
}

run().catch((err) => {
  console.error('[consumer] failed ❌', err);

  process.exit(1);
});

process.on('SIGINT', async () => {
  console.log('[consumer] shutdown...'); // Handle Ctrl+C or container shutdown signal

  await consumer.disconnect(); // Gracefully disconnect from Kafka

  process.exit(0); // Gracefully disconnect from Kafka
});
