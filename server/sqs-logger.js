// server/sqs-logger.js
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

let sqsClient = null;
let sqsQueueUrl = null;
let sqsEnabled = false;

/**
 * Initialize SQS logger - safe to call even if SQS is not configured
 */
export function initSQS() {
  const queueUrl = process.env.SQS_QUEUE_URL;
  const region = process.env.AWS_REGION || 'us-east-1';

  if (!queueUrl) {
    console.log('[sqs-logger] ⚠️  SQS is DISABLED (missing SQS_QUEUE_URL)');
    sqsEnabled = false;
    return;
  }

  try {
    sqsClient = new SQSClient({ region });
    sqsQueueUrl = queueUrl;
    sqsEnabled = true;
    console.log('[sqs-logger] ✅ SQS logger initialized');
  } catch (err) {
    console.error('[sqs-logger] ⚠️  Failed to initialize SQS:', err.message);
    sqsEnabled = false;
  }
}

/**
 * Send a log entry to SQS
 * @param {string} level - log level (info, error, warn)
 * @param {string} message - log message
 * @param {object} metadata - additional data
 */
export async function logToSQS(level, message, metadata = {}) {
  // If SQS is not enabled, just log to console and return
  if (!sqsEnabled) {
    console.log(`[sqs-logger] (disabled) ${level}: ${message}`, metadata);
    return;
  }

  try {
    const logEntry = {
      level,
      message,
      metadata,
      timestamp: new Date().toISOString(),
      service: 'demo-server',
    };

    console.log('[sqs-logger] Step: sending log to SQS...', logEntry);

    const command = new SendMessageCommand({
      QueueUrl: sqsQueueUrl,
      MessageBody: JSON.stringify(logEntry),
      MessageAttributes: {
        level: {
          DataType: 'String',
          StringValue: level,
        },
        service: {
          DataType: 'String',
          StringValue: 'demo-server',
        },
      },
    });

    await sqsClient.send(command);
    console.log('[sqs-logger] Step: log sent to SQS ✅');
  } catch (err) {
    // Don't crash if SQS fails - just log the error
    console.error('[sqs-logger] ⚠️  Failed to send to SQS:', err.message);
  }
}
