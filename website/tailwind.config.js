/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                codex: {
                    dark: '#0A0A0A',
                    card: '#141414',
                    accent: '#00A3FF',
                    secondary: '#71717A',
                }
            }
        },
    },
    plugins: [],
}
