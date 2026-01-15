import { describe, it, expect, vi } from 'vitest';
import request from 'supertest';
import { createApp } from '../app.js';

describe('server api', () => {
  it('GET /api/health returns ok:true', async () => {
    const app = createApp({ sendKafkaEvent: async () => {} });
    const res = await request(app).get('/api/health').expect(200);
    expect(res.body).toEqual({ ok: true });
  });

  it('GET /api/button1 returns payload and calls kafka sender', async () => {
    const sendKafkaEvent = vi.fn(async () => {});
    const app = createApp({ sendKafkaEvent });

    const res = await request(app).get('/api/button1').expect(200);

    expect(res.body.ok).toBe(true);
    expect(res.body.button).toBe('button1');
    expect(res.body.message).toBe('Hello from API #1');
    expect(typeof res.body.timestamp).toBe('string');
    expect(sendKafkaEvent).toHaveBeenCalledTimes(1);
    expect(sendKafkaEvent.mock.calls[0][0].button).toBe('button1');
  });

  it('if kafka sender fails, endpoint returns 500', async () => {
    const sendKafkaEvent = vi.fn(async () => {
      throw new Error('kafka down');
    });
    const app = createApp({ sendKafkaEvent });

    const res = await request(app).get('/api/button2').expect(500);
    expect(res.body).toEqual({ ok: false, error: 'internal_error' });
  });
});
