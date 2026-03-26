import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        blue: {
          DEFAULT: "#1A5CFF",
          50: "#EEF3FF",
          100: "#D8E4FF",
          500: "#1A5CFF",
          600: "#1449CC",
          700: "#0E3799",
        },
        red: {
          DEFAULT: "#E8003D",
          500: "#E8003D",
        },
        ink: {
          DEFAULT: "#0D1117",
          60: "rgba(13,17,23,0.6)",
          30: "rgba(13,17,23,0.12)",
        },
      },
      fontFamily: {
        sans: ["Inter", "Noto Sans TC", "sans-serif"],
        serif: ["Spectral", "Georgia", "serif"],
      },
      animation: {
        "flip-in": "flipIn 0.4s ease",
        "flip-out": "flipOut 0.4s ease",
        "fade-in": "fadeIn 0.3s ease",
        "slide-up": "slideUp 0.3s ease",
      },
      keyframes: {
        flipIn: {
          "0%": { transform: "rotateY(-90deg)", opacity: "0" },
          "100%": { transform: "rotateY(0deg)", opacity: "1" },
        },
        flipOut: {
          "0%": { transform: "rotateY(0deg)", opacity: "1" },
          "100%": { transform: "rotateY(90deg)", opacity: "0" },
        },
        fadeIn: {
          "0%": { opacity: "0", transform: "translateY(8px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        slideUp: {
          "0%": { transform: "translateY(100%)" },
          "100%": { transform: "translateY(0)" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
