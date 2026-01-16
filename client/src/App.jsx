// import { useState } from 'react';

// function pretty(obj) {
//   // helper to format objects as readable JSON text
//   return JSON.stringify(obj, null, 2); // pretty JSON with 2-space indentation
// }

// export default function App() {
//   const [loading, setLoading] = useState(false); // state that when on every change to true/false, the page is rerender
//   const [events, setEvents] = useState([]); // stores the history of API responses to render on the page

//   async function callApi(path, label) {
//     // call backend endpoint and store result as an event
//     setLoading(true); // mark UI as "loading"
//     try {
//       const res = await fetch(`${path}`); // If fetch receives a path starting with / The browser automatically connects it to the address from which the site is loaded
//       const json = await res.json();

//       setEvents((prev) => [
//         // with prev (something build in in react) i can save the last element that added to the array to the first line
//         {
//           id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
//           label,
//           at: new Date().toLocaleString(),
//           json,
//         },
//         ...prev, // prepend so newest event appears first
//       ]);
//     } catch (e) {
//       setEvents((prev) => [
//         {
//           id: `${Date.now()}-${Math.random().toString(36).slice(2)}`, // unique-ish id
//           label: 'Error',
//           at: new Date().toLocaleString(),
//           json: { ok: false, error: String(e) },
//         },
//         ...prev, // keep older events
//       ]);
//     } finally {
//       setLoading(false); // stop loading no matter success or failure
//     }
//   }

//   return (
//     <div className='page'>
//       <header className='header'>
//         <h1>Kafka Button Demo</h1>
//         <p>Click a button → fetch JSON → render UI → Kafka event produced.</p>{' '}
//       </header>
//       <div className='buttons'>
//         <button
//           className='btn primary'
//           disabled={loading}
//           onClick={() => callApi('/api/button1', 'Button 1')}
//         >
//           Button 1
//         </button>
//         <button
//           className='btn secondary'
//           disabled={loading}
//           onClick={() => callApi('/api/button2', 'Button 2')}
//         >
//           Button 2
//         </button>
//       </div>
//       <section className='panel'>
//         <div className='panelHeader'>
//           <h2>Responses</h2>
//           <span className={loading ? 'badge on' : 'badge'}>{loading ? 'Loading...' : 'Idle'}</span>
//         </div>
//         {events.length === 0 ? (
//           <div className='empty'>No responses yet. Click a button.</div>
//         ) : (
//           <div className='cards'>
//             {events.map((e) => (
//               <div className='card' key={e.id}>
//                 <div className='cardTop'>
//                   <div className='title'>{e.label}</div>
//                   <div className='time'>{e.at}</div>
//                 </div>
//                 <pre className='code'>{pretty(e.json)}</pre>
//               </div>
//             ))}
//           </div>
//         )}
//       </section>
//     </div>
//   );
// }

import { useState } from 'react';

function pretty(obj) {
  // helper to format objects as readable JSON text
  return JSON.stringify(obj, null, 2); // pretty JSON with 2-space indentation
}

export default function App() {
  const [loading, setLoading] = useState(false); // state that when on every change to true/false, the page is rerender
  const [events, setEvents] = useState([]); // stores the history of API responses to render on the page

  async function callApi(path, label) {
    // call backend endpoint and store result as an event
    console.log(`[client] Step: User clicked ${label}`);
    setLoading(true); // mark UI as "loading"
    console.log('[client] Step: Setting loading state to true');

    try {
      console.log(`[client] Step: Sending request to ${path}...`);
      const res = await fetch(`${path}`); // If fetch receives a path starting with / The browser automatically connects it to the address from which the site is loaded
      console.log('[client] Step: Received response from server');

      const json = await res.json();
      console.log('[client] Step: Parsed JSON response:', json);

      console.log('[client] Step: Updating events state...');
      setEvents((prev) => [
        // with prev (something build in in react) i can save the last element that added to the array to the first line
        {
          id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
          label,
          at: new Date().toLocaleString(),
          json,
        },
        ...prev, // prepend so newest event appears first
      ]);
      console.log('[client] Step: UI updated with new event ✅');
    } catch (e) {
      console.error('[client] Step: Request failed:', e);
      setEvents((prev) => [
        {
          id: `${Date.now()}-${Math.random().toString(36).slice(2)}`, // unique-ish id
          label: 'Error',
          at: new Date().toLocaleString(),
          json: { ok: false, error: String(e) },
        },
        ...prev, // keep older events
      ]);
    } finally {
      console.log('[client] Step: Setting loading state to false');
      setLoading(false); // stop loading no matter success or failure
    }
  }

  return (
    <div className='page'>
      <header className='header'>
        <h1>Event Logger Demo</h1>
        <p>Click a button → fetch JSON → render UI → event logged to SQS.</p>{' '}
      </header>
      <div className='buttons'>
        <button
          className='btn primary'
          disabled={loading}
          onClick={() => callApi('/api/button1', 'Button 1')}
        >
          Button 1
        </button>
        <button
          className='btn secondary'
          disabled={loading}
          onClick={() => callApi('/api/button2', 'Button 2')}
        >
          Button 2
        </button>
      </div>
      <section className='panel'>
        <div className='panelHeader'>
          <h2>Responses</h2>
          <span className={loading ? 'badge on' : 'badge'}>{loading ? 'Loading...' : 'Idle'}</span>
        </div>
        {events.length === 0 ? (
          <div className='empty'>No responses yet. Click a button.</div>
        ) : (
          <div className='cards'>
            {events.map((e) => (
              <div className='card' key={e.id}>
                <div className='cardTop'>
                  <div className='title'>{e.label}</div>
                  <div className='time'>{e.at}</div>
                </div>
                <pre className='code'>{pretty(e.json)}</pre>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
