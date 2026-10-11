/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          darkest: '#080D18',
          dark: '#0D1422',
          surface: '#111B2B',
          surfaceLight: '#162338',
          card: '#131F33',
          border: '#1E2F48',
          cyan: '#20D9F3',
          blue: '#438BFF',
          green: '#10B981',
          amber: '#F59E0B',
          red: '#EF4444',
          purple: '#A855F7',
          magenta: '#D946EF',
        }
      }
    },
  },
  plugins: [],
}
