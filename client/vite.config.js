import { defineConfig } from 'vite';

import react from '@vitejs/plugin-react';

export default defineConfig({
  // Tell Vite to use the React plugin (JSX, hooks, fast refresh, etc.)

  plugins: [react()],

  build: { outDir: 'dist' },
  // Configure the build output directory where compiled files will be generated

  test: {
    environment: 'happy-dom',
    setupFiles: './tests/setup.js',
    globals: true,
  },
});

/* vite takes the JSX files (like App.jsx) and translates them into regular web files (also from which nginx serves the application in production) */
