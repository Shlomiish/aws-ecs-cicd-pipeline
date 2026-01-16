// // import express from 'express';
// // import morgan from 'morgan';
// // import cors from 'cors';

// // export function buildPayload(button) {
// //   return {
// //     ok: true,
// //     button,
// //     message: button === 'button1' ? 'Hello from API #1' : 'Hello from API #2',
// //     timestamp: new Date().toISOString(),
// //   };
// // }

// // export function createApp({ sendKafkaEvent }) {
// //   const app = express();

// //   app.use(express.json());
// //   app.use(cors());
// //   app.use(morgan('combined'));

// //   app.get('/api/health', (req, res) => res.json({ ok: true }));

// //   app.get('/api/button1', async (req, res, next) => {
// //     try {
// //       const payload = buildPayload('button1');
// //       await sendKafkaEvent(payload);
// //       res.json(payload);
// //     } catch (e) {
// //       next(e);
// //     }
// //   });

// //   app.get('/api/button2', async (req, res, next) => {
// //     try {
// //       const payload = buildPayload('button2');
// //       await sendKafkaEvent(payload);
// //       res.json(payload);
// //     } catch (e) {
// //       next(e);
// //     }
// //   });

// //   app.use((err, req, res, next) => {
// //     console.error('[server] request failed', err);
// //     res.status(500).json({ ok: false, error: 'internal_error' });
// //   });

// //   return app;
// // }

// import express from 'express';
// import morgan from 'morgan';
// import cors from 'cors';

// export function buildPayload(button) {
//   return {
//     ok: true,
//     button,
//     message: button === 'button1' ? 'Hello from API #1' : 'Hello from API #2',
//     timestamp: new Date().toISOString(),
//   };
// }

// export function createApp({ sendLogToSQS }) {
//   const app = express();

//   app.use(express.json());
//   app.use(cors());
//   app.use(morgan('combined'));

//   app.get('/api/health', (req, res) => res.json({ ok: true }));

//   app.get('/api/button1', async (req, res, next) => {
//     try {
//       console.log('[server] Step: received request to /api/button1');
//       const payload = buildPayload('button1');
//       console.log('[server] Step: built payload for button1');
//       await sendLogToSQS(payload);
//       console.log('[server] Step: returning response to client');
//       res.json(payload);
//     } catch (e) {
//       next(e);
//     }
//   });

//   app.get('/api/button2', async (req, res, next) => {
//     try {
//       console.log('[server] Step: received request to /api/button2');
//       const payload = buildPayload('button2');
//       console.log('[server] Step: built payload for button2');
//       await sendLogToSQS(payload);
//       console.log('[server] Step: returning response to client');
//       res.json(payload);
//     } catch (e) {
//       next(e);
//     }
//   });

//   app.use((err, req, res, next) => {
//     console.error('[server] request failed', err);
//     res.status(500).json({ ok: false, error: 'internal_error' });
//   });

//   return app;
// }

import express from 'express';
import morgan from 'morgan';
import cors from 'cors';

export function buildPayload(button) {
  return {
    ok: true,
    button,
    message: button === 'button1' ? 'Hello from API #1' : 'Hello from API #2',
    timestamp: new Date().toISOString(),
  };
}

export function createApp({ sendLogToSQS }) {
  const app = express();

  app.use(express.json());
  app.use(cors());
  app.use(morgan('combined'));

  app.get('/api/health', (req, res) => res.json({ ok: true }));

  app.get('/api/button1', async (req, res, next) => {
    try {
      console.log('[server] Step: received request to /api/button1');
      const payload = buildPayload('button1');
      console.log('[server] Step: built payload for button1');
      await sendLogToSQS(payload);
      console.log('[server] Step: returning response to client');
      res.json(payload);
    } catch (e) {
      next(e);
    }
  });

  app.get('/api/button2', async (req, res, next) => {
    try {
      console.log('[server] Step: received request to /api/button2');
      const payload = buildPayload('button2');
      console.log('[server] Step: built payload for button2');
      await sendLogToSQS(payload);
      console.log('[server] Step: returning response to client');
      res.json(payload);
    } catch (e) {
      next(e);
    }
  });

  app.use((err, req, res, next) => {
    console.error('[server] request failed', err);
    res.status(500).json({ ok: false, error: 'internal_error' });
  });

  return app;
}
