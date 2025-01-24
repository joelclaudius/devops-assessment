// https://vite.dev/config/
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Allows external connections
    allowedHosts: ['.ngrok-free.app', 'localhost', 'blogs.kedevs.com'], // Specify domain patterns or add the specific domains
  },
});
