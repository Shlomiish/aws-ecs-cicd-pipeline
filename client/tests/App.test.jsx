import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import App from '../src/App.jsx';

beforeEach(() => {
  vi.restoreAllMocks();
});

describe('App', () => {
  it('clicking Button 1 calls /api/button1 and renders JSON', async () => {
    const user = userEvent.setup();

    global.fetch = vi.fn(async () => ({
      ok: true,
      status: 200,
      json: async () => ({ ok: true, button: 'button1' }),
    }));

    render(<App />);

    // click first matching Button 1 (safe if duplicated)
    await user.click(screen.getAllByRole('button', { name: /button 1/i })[0]);

    expect(global.fetch).toHaveBeenCalledWith('/api/button1');

    // verify unique JSON content instead of "Button 1" label
    expect(await screen.findByText(/"button": "button1"/i)).toBeInTheDocument();
    expect(await screen.findByText(/"ok": true/i)).toBeInTheDocument();
  });

  it('shows Loading... while request is pending, then Idle', async () => {
    const user = userEvent.setup();

    let resolveFetch;
    global.fetch = vi.fn(
      () =>
        new Promise((resolve) => {
          resolveFetch = () =>
            resolve({
              ok: true,
              status: 200,
              json: async () => ({ ok: true }),
            });
        })
    );

    render(<App />);

    // Note: your UI shows "Idle" with capital I
    expect(screen.getByText(/idle/i)).toBeInTheDocument();

    await user.click(screen.getAllByRole('button', { name: /button 2/i })[0]);

    expect(screen.getByText(/loading\.\.\./i)).toBeInTheDocument();

    resolveFetch();

    expect(await screen.findByText(/idle/i)).toBeInTheDocument();
  });

  it('on fetch error, renders ok:false in the JSON', async () => {
    const user = userEvent.setup();

    global.fetch = vi.fn(async () => {
      throw new Error('network down');
    });

    render(<App />);

    await user.click(screen.getAllByRole('button', { name: /button 1/i })[0]);

    // don't search for "Error" (appears in multiple places), search the JSON
    expect(await screen.findByText(/"ok": false/i)).toBeInTheDocument();
    expect(await screen.findByText(/network down/i)).toBeInTheDocument();
  });
});
