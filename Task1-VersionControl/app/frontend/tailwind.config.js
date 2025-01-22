/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],

  theme: {
    extend: {
      colors: {
        // Define colors for dark mode
        gray: {
          900: '#1a202c',
          800: '#2d3748',
          50: '#f7fafc',
        },
      },
    },
  },
  darkMode: 'class',
  
  plugins: [],
}