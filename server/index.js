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
