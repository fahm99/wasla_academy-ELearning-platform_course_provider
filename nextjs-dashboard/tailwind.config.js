/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Primary - Dark Blue (Authority)
        primary: {
          DEFAULT: '#0C1445',
          50: '#eef0f6',
          100: '#d3d8e6',
          200: '#b3b9d6',
          300: '#8f9ac3',
          400: '#6d7db3',
          500: '#4d5ea0',
          600: '#3d4a7d',
          700: '#2f3a63',
          800: '#1f2949',
          900: '#0C1445',
        },
        // Secondary - Gold/Yellow
        secondary: {
          DEFAULT: '#FFD54F',
          50: '#fff9e6',
          100: '#ffefb3',
          200: '#ffe680',
          300: '#ffdb4d',
          400: '#FFD54F',
          500: '#e6bc3d',
          600: '#cca333',
          700: '#b38a2a',
          800: '#997120',
          900: '#7f5817',
        },
        // Background
        background: '#F5F7FA',
        // Surface
        surface: {
          DEFAULT: '#FFFFFF',
          alt: '#F5F7FA',
        },
        // Text
        textPrimary: '#1A1A1A',
        textSecondary: '#777777',
        // Status Colors
        success: '#4CAF50',
        error: '#F44336',
        warning: '#FF9800',
        info: '#2196F3',
        // Surface Colors (No lines needed)
        surfaceOld: {
          DEFAULT: '#f7f9fc',
          low: '#f2f4f7',
          lowest: '#ffffff',
          bright: '#ffffff',
          dim: '#e8eaef',
        },
        // Text colors
        'on-surface': '#191c1e',
        'on-surface-variant': '#46464f',
        'on-surface-subtle': '#6b7280',
        // Outline variants
        'outline-soft': 'rgba(12, 20, 69, 0.12)',
      },
      fontFamily: {
        arabic: ['var(--font-tajawal)', 'Tajawal', 'Cairo', 'system-ui', 'sans-serif'],
        display: ['var(--font-plus-jakarta)', 'Plus Jakarta Sans', 'sans-serif'],
      },
      boxShadow: {
        'ambient': '0px 12px 32px rgba(12, 20, 69, 0.06)',
        'float': '0 4px 16px rgba(12, 20, 69, 0.08)',
        'elevated': '0 8px 24px rgba(12, 20, 69, 0.1)',
      },
      backgroundImage: {
        'gradient-primary': 'linear-gradient(135deg, #0C1445 0%, #7980b6 100%)',
        'gradient-gold': 'linear-gradient(135deg, #FFD54F 0%, #ffefb3 100%)',
      },
      borderRadius: {
        'xl': '1.5rem',
        '2xl': '2rem',
      },
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
      },
    },
  },
  plugins: [],
};