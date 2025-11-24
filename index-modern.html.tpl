<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta
      name="description"
      content="High performance Bitcoin Cash (BCH) development platform - Full node and libraries in 7 languages"
    />
    <title>Knuth | Bitcoin Cash Full Node and Development Platform</title>

    <link rel="icon" href="./img/logo-white.svg" />

    <!-- CodeMirror for syntax highlighting -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/theme/dracula.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/mode/javascript/javascript.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/addon/edit/closebrackets.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/addon/edit/matchbrackets.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/addon/selection/active-line.min.js"></script>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
      tailwind.config = {
        darkMode: 'class',
        theme: {
          extend: {
            colors: {
              primary: {
                DEFAULT: '#3b009b',
                dark: '#2d0075',
                light: '#5200cc'
              },
              dark: {
                DEFAULT: '#0e1419',
                lighter: '#1a1f26',
                text: '#4d4d4d'
              }
            },
            fontFamily: {
              'cairo': ['"Cairo"', 'sans-serif'],
              'mono': ['"Ubuntu Mono"', 'monospace']
            },
            animation: {
              'fade-in': 'fadeIn 1s ease-in',
              'slide-up': 'slideUp 0.5s ease-out',
              'scale-in': 'scaleIn 0.3s ease-out'
            },
            keyframes: {
              fadeIn: {
                '0%': { opacity: '0' },
                '100%': { opacity: '1' }
              },
              slideUp: {
                '0%': { transform: 'translateY(20px)', opacity: '0' },
                '100%': { transform: 'translateY(0)', opacity: '1' }
              },
              scaleIn: {
                '0%': { transform: 'scale(0.9)', opacity: '0' },
                '100%': { transform: 'scale(1)', opacity: '1' }
              }
            }
          }
        }
      }
    </script>

    <!-- Cairo font -->
    <link
      href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap"
      rel="stylesheet"
    />

    <!-- Ubuntu Mono font -->
    <link
      href="https://fonts.googleapis.com/css2?family=Ubuntu+Mono&display=swap"
      rel="stylesheet"
    />

    <!-- Fontawesome icons -->
    <script
      src="https://kit.fontawesome.com/086597c03d.js"
      crossorigin="anonymous"
    ></script>

    <!-- ClipboardJs -->
    <script src="https://cdn.jsdelivr.net/npm/clipboard@2/dist/clipboard.min.js"></script>

    <style>
      /* Animated gradient keyframe */
      @keyframes gradient-shift {
        0%, 100% {
          background-position: 0% 50%;
        }
        50% {
          background-position: 100% 50%;
        }
      }

      /* Shared animated gradient */
      .hero-mesh-gradient {
        background: linear-gradient(-45deg, #7c3aed, #5200cc, #3b009b, #ec4899, #f59e0b);
        background-size: 400% 400%;
        animation: gradient-shift 12s ease infinite;
      }

      /* Menu inicial - visible solo arriba */
      #initial-menu {
        background: transparent;
        transition: opacity 300ms;
      }

      #initial-menu.hidden-menu {
        opacity: 0;
        pointer-events: none;
      }

      /* Navbar flotante - oculto por defecto */
      #floating-navbar {
        background: transparent;
        opacity: 0;
        transform: translateY(-100%);
        transition: opacity 300ms, transform 300ms, box-shadow 300ms;
      }

      /* Navbar flotante visible cuando scrolleas */
      #floating-navbar.show {
        opacity: 1;
        transform: translateY(0);
        background: linear-gradient(-45deg, #7c3aed, #5200cc, #3b009b, #ec4899, #f59e0b);
        background-size: 400% 400%;
        animation: gradient-shift 12s ease infinite;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
      }

      /* Logo siempre visible en navbar flotante */
      #floating-navbar #navbar-logo {
        opacity: 1;
      }

      /* Smooth scroll behavior */
      html {
        scroll-behavior: smooth;
        scroll-padding-top: 80px; /* Offset for fixed navbar */
      }

      /* Matrix rain effect background */
      .matrix-container {
        position: relative;
        overflow: hidden;
      }

      .matrix-rain {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        z-index: 0;
        opacity: 0;
        transition: opacity 0.3s;
      }

      .matrix-rain.active {
        opacity: 0.15;
      }

      .matrix-column {
        position: absolute;
        top: -100%;
        font-family: 'Ubuntu Mono', monospace;
        font-size: 14px;
        color: #22c55e;
        text-shadow: 0 0 8px rgba(34, 197, 94, 0.8);
        white-space: pre;
        animation: matrix-fall linear;
      }

      @keyframes matrix-fall {
        0% {
          top: -100%;
          opacity: 0;
        }
        10% {
          opacity: 1;
        }
        90% {
          opacity: 1;
        }
        100% {
          top: 100%;
          opacity: 0;
        }
      }

      /* Output content layer */
      .matrix-content {
        position: relative;
        z-index: 1;
      }

      /* Character drop effect */
      .matrix-line {
        display: block;
        white-space: pre;
      }

      .matrix-char {
        display: inline-block;
        opacity: 0;
        text-shadow: 0 0 8px rgba(34, 197, 94, 0.6);
      }

      @keyframes char-drop {
        0% {
          opacity: 0;
          transform: translateY(-100px);
          filter: blur(4px);
        }
        50% {
          opacity: 0.7;
        }
        100% {
          opacity: 1;
          transform: translateY(0);
          filter: blur(0);
        }
      }
    </style>
  </head>

  <body class="font-cairo antialiased transition-colors duration-300 m-0 p-0">
    <!-- Initial Menu (visible at top only) -->
    <nav id="initial-menu" class="fixed top-0 left-0 right-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-end items-center h-16">
          <!-- Desktop Navigation -->
          <div class="hidden lg:flex lg:items-center lg:space-x-8">
            <a href="#download" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Get Knuth</a>
            <a href="#features" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Libraries</a>
            <a href="#features-info" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Features</a>
            <a href="https://fund.kth.cash" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Funding</a>
            <a href="#contact" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Contact</a>

            <!-- Dark Mode Toggle Button -->
            <button id="dark-mode-toggle-initial" class="text-white hover:text-gray-200 focus:outline-none transition-all duration-200 hover:scale-110" aria-label="Toggle dark mode">
              <svg id="sun-icon-initial" class="h-6 w-6 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
              <svg id="moon-icon-initial" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
              </svg>
            </button>
          </div>

          <!-- Mobile menu button and dark mode toggle -->
          <div class="lg:hidden flex items-center space-x-4">
            <button id="dark-mode-toggle-mobile-initial" class="text-white hover:text-gray-200 focus:outline-none transition-all duration-200" aria-label="Toggle dark mode">
              <svg id="sun-icon-mobile-initial" class="h-6 w-6 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
              <svg id="moon-icon-mobile-initial" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
              </svg>
            </button>

            <button id="mobile-menu-button-initial" type="button" class="text-white hover:text-gray-200 focus:outline-none" aria-label="Toggle menu">
              <svg id="menu-icon-open-initial" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
              <svg id="menu-icon-close-initial" class="h-6 w-6 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Mobile Navigation -->
      <div id="mobile-menu-initial" class="hidden lg:hidden bg-gradient-to-r from-primary to-primary-dark">
        <div class="px-4 pt-2 pb-4 space-y-2">
          <a href="#download" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Get Knuth</a>
          <a href="#features" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Libraries</a>
          <a href="#features-info" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Features</a>
          <a href="https://fund.kth.cash" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Funding</a>
          <a href="#contact" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Contact</a>
        </div>
      </div>
    </nav>

    <!-- Floating Navbar (visible when scrolling) -->
    <nav id="floating-navbar" class="fixed top-0 left-0 right-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <!-- Logo (visible when scrolled) -->
          <div class="flex-shrink-0">
            <img id="navbar-logo" class="h-8 transition-opacity duration-300" src="./img/logo-white.svg" alt="Knuth" />
          </div>

          <!-- Desktop Navigation -->
          <div class="hidden lg:flex lg:items-center lg:space-x-8">
            <a href="#download" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Get Knuth</a>
            <a href="#features" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Libraries</a>
            <a href="#features-info" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Features</a>
            <a href="https://fund.kth.cash" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Funding</a>
            <a href="#contact" class="text-white font-semibold hover:text-gray-200 transition-all duration-200 hover:scale-105">Contact</a>

            <!-- Dark Mode Toggle Button -->
            <button id="dark-mode-toggle" class="text-white hover:text-gray-200 focus:outline-none transition-all duration-200 hover:scale-110" aria-label="Toggle dark mode">
              <!-- Sun Icon (shown in dark mode) -->
              <svg id="sun-icon" class="h-6 w-6 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
              <!-- Moon Icon (shown in light mode) -->
              <svg id="moon-icon" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
              </svg>
            </button>
          </div>

          <!-- Mobile menu button and dark mode toggle -->
          <div class="lg:hidden flex items-center space-x-4">
            <!-- Dark Mode Toggle (Mobile) -->
            <button id="dark-mode-toggle-mobile" class="text-white hover:text-gray-200 focus:outline-none transition-all duration-200" aria-label="Toggle dark mode">
              <svg id="sun-icon-mobile" class="h-6 w-6 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
              <svg id="moon-icon-mobile" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
              </svg>
            </button>

            <!-- Hamburger Menu Button -->
            <div>
            <button id="mobile-menu-button" type="button" class="text-white hover:text-gray-200 focus:outline-none" aria-label="Toggle menu">
              <svg id="menu-icon-open" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
              <svg id="menu-icon-close" class="h-6 w-6 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Mobile Navigation -->
      <div id="mobile-menu" class="hidden lg:hidden bg-gradient-to-r from-primary to-primary-dark">
        <div class="px-4 pt-2 pb-4 space-y-2">
          <a href="#download" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Get Knuth</a>
          <a href="#features" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Libraries</a>
          <a href="#features-info" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Features</a>
          <a href="https://fund.kth.cash" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Funding</a>
          <a href="#contact" class="block text-white font-semibold py-2 px-3 hover:bg-white/10 rounded transition-colors mobile-menu-link">Contact</a>
        </div>
      </div>
    </nav>

    <!-- Hero Header (starts from top, navbar floats over it) -->
    <header class="relative h-96 lg:h-[500px] hero-mesh-gradient">
      <div class="absolute inset-0 flex flex-col items-center justify-center gap-6">
        <img class="h-32 lg:h-64 animate-fade-in drop-shadow-2xl" src="./img/logo-white.svg" alt="Knuth" />
        <h1 class="text-lg lg:text-2xl font-normal text-white text-center px-4 animate-slide-up drop-shadow-lg" style="animation-delay: 0.3s;">
          High Performance Bitcoin Cash Development Platform
        </h1>
      </div>
    </header>

    <!-- Main Content Wrapper -->
    <div class="bg-white dark:bg-gray-900">

    <!-- Info Section -->
    <section id="info" class="relative py-12 bg-gradient-to-br from-white via-gray-50/50 to-purple-50/30 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800 transition-colors duration-300">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16 animate-fade-in">
          <h2 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            <span class="bg-gradient-to-r from-primary via-purple-600 to-pink-600 dark:from-purple-400 dark:via-pink-400 dark:to-yellow-400 bg-clip-text text-transparent"># Built for Bitcoin Cash Professionals</span>
          </h2>
          <p class="text-xl lg:text-2xl text-gray-600 dark:text-gray-300 max-w-4xl mx-auto">
            High performance Bitcoin Cash (BCH) full node implementation focused on extra capacity and throughput. More than a client — it's a complete development platform with libraries in 7 languages and an optimized executable node.
          </p>
        </div>

        <!-- Cards Grid -->
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <!-- Card 1 -->
          <div class="group bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700 animate-scale-in">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center shadow-lg">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M6.672 1.911a1 1 0 10-1.932.518l.259.966a1 1 0 001.932-.518l-.26-.966zM2.429 4.74a1 1 0 10-.517 1.932l.966.259a1 1 0 00.517-1.932l-.966-.26zm8.814-.569a1 1 0 00-1.415-1.414l-.707.707a1 1 0 101.415 1.415l.707-.708zm-7.071 7.072l.707-.707A1 1 0 003.465 9.12l-.708.707a1 1 0 001.415 1.415zm3.2-5.171a1 1 0 00-1.3 1.3l4 10a1 1 0 001.823.075l1.38-2.759 3.018 3.02a1 1 0 001.414-1.415l-3.019-3.02 2.76-1.379a1 1 0 00-.076-1.822l-10-4z" clip-rule="evenodd" />
                  </svg>
                </div>
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-purple-400 transition-colors">Miners & Pools</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm">Running competitive operations at scale</p>
              </div>
            </div>
          </div>

          <!-- Card 2 -->
          <div class="group bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700 animate-scale-in" style="animation-delay: 0.1s;">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center shadow-lg">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M8.433 7.418c.155-.103.346-.196.567-.267v1.698a2.305 2.305 0 01-.567-.267C8.07 8.34 8 8.114 8 8c0-.114.07-.34.433-.582zM11 12.849v-1.698c.22.071.412.164.567.267.364.243.433.468.433.582 0 .114-.07.34-.433.582a2.305 2.305 0 01-.567.267z" />
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-13a1 1 0 10-2 0v.092a4.535 4.535 0 00-1.676.662C6.602 6.234 6 7.009 6 8c0 .99.602 1.765 1.324 2.246.48.32 1.054.545 1.676.662v1.941c-.391-.127-.68-.317-.843-.504a1 1 0 10-1.51 1.31c.562.649 1.413 1.076 2.353 1.253V15a1 1 0 102 0v-.092a4.535 4.535 0 001.676-.662C13.398 13.766 14 12.991 14 12c0-.99-.602-1.765-1.324-2.246A4.535 4.535 0 0011 9.092V7.151c.391.127.68.317.843.504a1 1 0 101.511-1.31c-.563-.649-1.413-1.076-2.354-1.253V5z" clip-rule="evenodd" />
                  </svg>
                </div>
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-purple-400 transition-colors">Exchanges</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm">Dependable full indexation & high throughput</p>
              </div>
            </div>
          </div>

          <!-- Card 3 -->
          <div class="group bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700 animate-scale-in" style="animation-delay: 0.2s;">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center shadow-lg">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z" />
                  </svg>
                </div>
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-purple-400 transition-colors">Enterprises</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm">Building production-grade applications</p>
              </div>
            </div>
          </div>

          <!-- Card 4 -->
          <div class="group bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700 animate-scale-in" style="animation-delay: 0.3s;">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center shadow-lg">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
                  </svg>
                </div>
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-purple-400 transition-colors">Developers</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm">Taking projects to the next level</p>
              </div>
            </div>
          </div>

          <!-- Card 5 -->
          <div class="group bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700 animate-scale-in" style="animation-delay: 0.4s;">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center shadow-lg">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10.394 2.08a1 1 0 00-.788 0l-7 3a1 1 0 000 1.84L5.25 8.051a.999.999 0 01.356-.257l4-1.714a1 1 0 11.788 1.838L7.667 9.088l1.94.831a1 1 0 00.787 0l7-3a1 1 0 000-1.838l-7-3zM3.31 9.397L5 10.12v4.102a8.969 8.969 0 00-1.05-.174 1 1 0 01-.89-.89 11.115 11.115 0 01.25-3.762zm5.99 7.176A9.026 9.026 0 007 14.935v-3.957l1.818.78a3 3 0 002.364 0l5.508-2.361a11.026 11.026 0 01.25 3.762 1 1 0 01-.89.89 8.968 8.968 0 00-5.35 2.524 1 1 0 01-1.4 0zM6 18a1 1 0 001-1v-2.065a8.935 8.935 0 00-2-.712V17a1 1 0 001 1z" />
                  </svg>
                </div>
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-purple-400 transition-colors">Researchers</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm">Exploring blockchain innovation</p>
              </div>
            </div>
          </div>

          <!-- Card 6 -->
          <div class="group bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700 animate-scale-in" style="animation-delay: 0.5s;">
            <div class="flex items-start space-x-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center shadow-lg">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clip-rule="evenodd" />
                  </svg>
                </div>
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-purple-400 transition-colors">Newcomers</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm">First steps in the blockchain ecosystem</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Architecture Section -->
    <section id="architecture" class="relative py-12 bg-white dark:bg-gray-900 transition-colors duration-300 overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-1/4 left-0 w-96 h-96 bg-primary rounded-full blur-3xl"></div>
        <div class="absolute bottom-1/4 right-0 w-96 h-96 bg-pink-500 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16">
          <h2 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            <span class="bg-gradient-to-r from-primary via-purple-600 to-pink-600 dark:from-purple-400 dark:via-pink-400 dark:to-yellow-400 bg-clip-text text-transparent"># Layered Architecture</span>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
            All language bindings share the same high-performance C++23 core. Universal Bitcoin Cash API across all platforms.
          </p>
        </div>

        <!-- Architecture Diagram -->
        <div class="max-w-4xl mx-auto">
          <!-- Layer 1: High-Level Languages -->
          <div class="mb-8 animate-slide-up">
            <div class="text-center mb-4">
              <span class="inline-block bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-bold px-4 py-2 rounded-full">
                High-Level Language Bindings
              </span>
            </div>
            <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
              <a href="https://github.com/k-nuth/py-api" target="_blank" class="group bg-gradient-to-br from-purple-100 to-pink-50 dark:from-purple-900/30 dark:to-pink-900/30 rounded-xl p-6 border-2 border-purple-200 dark:border-purple-700 hover:scale-105 transition-transform duration-300 hover:shadow-lg">
                <img src="./images/libraries/python.svg" alt="Python" class="w-12 h-12 mx-auto mb-2" />
                <p class="text-sm font-bold text-gray-700 dark:text-gray-300 text-center">Python</p>
              </a>
              <a href="https://github.com/k-nuth/js-api" target="_blank" class="group bg-gradient-to-br from-purple-100 to-pink-50 dark:from-purple-900/30 dark:to-pink-900/30 rounded-xl p-6 border-2 border-purple-200 dark:border-purple-700 hover:scale-105 transition-transform duration-300 hover:shadow-lg">
                <img src="./images/libraries/javascript.svg" alt="JavaScript" class="w-12 h-12 mx-auto mb-2" />
                <p class="text-sm font-bold text-gray-700 dark:text-gray-300 text-center">JavaScript</p>
              </a>
              <a href="https://github.com/k-nuth/js-api" target="_blank" class="group bg-gradient-to-br from-purple-100 to-pink-50 dark:from-purple-900/30 dark:to-pink-900/30 rounded-xl p-6 border-2 border-purple-200 dark:border-purple-700 hover:scale-105 transition-transform duration-300 hover:shadow-lg">
                <img src="./images/libraries/typescript.svg" alt="TypeScript" class="w-12 h-12 mx-auto mb-2" />
                <p class="text-sm font-bold text-gray-700 dark:text-gray-300 text-center">TypeScript</p>
              </a>
              <a href="https://github.com/k-nuth/cs-api" target="_blank" class="group bg-gradient-to-br from-purple-100 to-pink-50 dark:from-purple-900/30 dark:to-pink-900/30 rounded-xl p-6 border-2 border-purple-200 dark:border-purple-700 hover:scale-105 transition-transform duration-300 hover:shadow-lg">
                <img src="./images/libraries/csharp.svg" alt="C#" class="w-12 h-12 mx-auto mb-2" />
                <p class="text-sm font-bold text-gray-700 dark:text-gray-300 text-center">C#</p>
              </a>
              <a href="https://github.com/k-nuth/js-wasm" target="_blank" class="group relative bg-gradient-to-br from-purple-100 to-pink-50 dark:from-purple-900/30 dark:to-pink-900/30 rounded-xl p-6 border-2 border-purple-200 dark:border-purple-700 hover:scale-105 transition-transform duration-300 hover:shadow-lg">
                <div class="absolute -top-2 -right-2 bg-gradient-to-r from-green-500 to-emerald-600 text-white text-xs font-bold px-2 py-1 rounded-full shadow-lg">
                  🔥 HOT
                </div>
                <img src="./images/libraries/wasm.svg" alt="WebAssembly" class="w-12 h-12 mx-auto mb-2" />
                <p class="text-sm font-bold text-gray-700 dark:text-gray-300 text-center">WASM</p>
              </a>
            </div>
          </div>

          <!-- Arrows Down -->
          <div class="flex justify-center mb-6">
            <svg class="w-8 h-8 text-primary dark:text-purple-400 animate-bounce" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 10.293a1 1 0 010 1.414l-6 6a1 1 0 01-1.414 0l-6-6a1 1 0 111.414-1.414L9 14.586V3a1 1 0 012 0v11.586l4.293-4.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </div>

          <!-- Layer 2: C Language Binding -->
          <div class="mb-6 animate-slide-up" style="animation-delay: 0.1s;">
            <div class="text-center mb-4">
              <span class="inline-block bg-gradient-to-r from-primary to-primary-dark text-white text-sm font-bold px-4 py-2 rounded-full">
                Universal C Bindings
              </span>
            </div>
            <a href="https://github.com/k-nuth/c-api" target="_blank" class="block bg-gradient-to-br from-primary/10 to-purple-500/10 dark:from-primary/20 dark:to-purple-500/20 rounded-2xl p-8 border-4 border-primary dark:border-purple-500 shadow-2xl hover:scale-105 transition-transform duration-300">
              <div class="flex items-center justify-center gap-4">
                <img src="./images/libraries/c.svg" alt="C" class="w-16 h-16" />
                <div class="text-left">
                  <h3 class="text-2xl font-bold text-gray-900 dark:text-white">C Language Binding</h3>
                  <p class="text-gray-600 dark:text-gray-300">The universal interlingua that connects all programming languages to the C++ core</p>
                </div>
              </div>
            </a>
          </div>

          <!-- Arrows Down -->
          <div class="flex justify-center mb-6">
            <svg class="w-8 h-8 text-primary dark:text-purple-400 animate-bounce" style="animation-delay: 0.2s;" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 10.293a1 1 0 010 1.414l-6 6a1 1 0 01-1.414 0l-6-6a1 1 0 111.414-1.414L9 14.586V3a1 1 0 012 0v11.586l4.293-4.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </div>

          <!-- Layer 3: C++ Core -->
          <div class="mb-6 animate-slide-up" style="animation-delay: 0.2s;">
            <div class="text-center mb-4">
              <span class="inline-block bg-gradient-to-r from-orange-500 to-red-500 text-white text-sm font-bold px-4 py-2 rounded-full">
                High-Performance Core
              </span>
            </div>
            <a href="https://github.com/k-nuth/node" target="_blank" class="block bg-gradient-to-br from-orange-100 to-red-50 dark:from-orange-900/30 dark:to-red-900/30 rounded-2xl p-8 border-4 border-orange-400 dark:border-orange-600 shadow-2xl hover:scale-105 transition-transform duration-300">
              <div class="flex items-center justify-center gap-4">
                <img src="./images/libraries/cpp.svg" alt="C++" class="w-20 h-20" />
                <div class="text-left">
                  <h3 class="text-3xl font-bold text-gray-900 dark:text-white">C++23 Core Implementation</h3>
                  <p class="text-lg text-gray-600 dark:text-gray-300">Optimized for modern CPUs (Haswell+ baseline)</p>
                </div>
              </div>
            </a>
          </div>

          <!-- Info boxes -->
          <div class="grid md:grid-cols-3 gap-4 mt-8">
            <div class="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-6 border-2 border-blue-200 dark:border-blue-700">
              <div class="flex items-start gap-3">
                <svg class="w-6 h-6 text-blue-600 dark:text-blue-400 flex-shrink-0 mt-1" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/><path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
                </svg>
                <div>
                  <h4 class="font-bold text-gray-900 dark:text-white mb-1">Libraries</h4>
                  <p class="text-sm text-gray-600 dark:text-gray-300">Use Knuth as a library in your projects. Build custom Bitcoin Cash applications with full blockchain access.</p>
                </div>
              </div>
            </div>
            <div class="bg-green-50 dark:bg-green-900/20 rounded-xl p-6 border-2 border-green-200 dark:border-green-700">
              <div class="flex items-start gap-3">
                <svg class="w-6 h-6 text-green-600 dark:text-green-400 flex-shrink-0 mt-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm3.293 1.293a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 01-1.414-1.414L7.586 10 5.293 7.707a1 1 0 010-1.414zM11 12a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd"/>
                </svg>
                <div>
                  <h4 class="font-bold text-gray-900 dark:text-white mb-1">Executable Node</h4>
                  <p class="text-sm text-gray-600 dark:text-gray-300">Run the full node executable. High-performance Bitcoin Cash node ready to use out of the box.</p>
                </div>
              </div>
            </div>
            <div class="bg-purple-50 dark:bg-purple-900/20 rounded-xl p-6 border-2 border-purple-200 dark:border-purple-700">
              <div class="flex items-start gap-3">
                <svg class="w-6 h-6 text-purple-600 dark:text-purple-400 flex-shrink-0 mt-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clip-rule="evenodd"/>
                </svg>
                <div>
                  <h4 class="font-bold text-gray-900 dark:text-white mb-1">Direct Integration</h4>
                  <p class="text-sm text-gray-600 dark:text-gray-300">Unlike JSON-RPC, your application becomes the node. All components run as a single process with native performance—no network overhead.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Getting Started Section -->
    <section id="download" class="relative bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-900 py-12 transition-colors duration-300 overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-0 right-1/4 w-96 h-96 bg-primary rounded-full blur-3xl"></div>
        <div class="absolute bottom-0 left-1/4 w-96 h-96 bg-pink-500 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-3">
          <div class="inline-flex items-center gap-2 bg-primary/10 dark:bg-primary/30 px-4 py-2 rounded-full mb-6">
            <svg class="w-5 h-5 text-primary dark:text-purple-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clip-rule="evenodd" />
            </svg>
            <span class="text-sm font-bold text-primary dark:text-purple-400 uppercase tracking-wider">Quick Start Guide</span>
          </div>
          <h2 class="text-4xl lg:text-5xl font-black text-gray-900 dark:text-white mb-4">
            <span class="bg-gradient-to-r from-primary via-purple-600 to-pink-600 dark:from-purple-400 dark:via-pink-400 dark:to-yellow-400 bg-clip-text text-transparent"># Getting Started</span>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300">
            Install and use Knuth in your preferred environment.
          </p>
        </div>

        <!-- Libraries -->
        <div id="content-libraries">
          <div class="pt-2">
            <p class="text-center text-gray-600 dark:text-gray-400 mb-4 text-lg">
              Select an option to see installation instructions and usage examples
            </p>

              <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-3 mb-6">
                <button onclick="showLibraryA('executable')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <svg class="w-10 h-10 mx-auto mb-2 text-primary dark:text-purple-400 group-hover:scale-110 transition-transform" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm3.293 1.293a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 01-1.414-1.414L7.586 10 5.293 7.707a1 1 0 010-1.414zM11 12a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd"/>
                  </svg>
                  <p class="text-sm font-bold text-gray-900 dark:text-white">Executable</p>
                </button>
                <button onclick="showLibraryA('cpp')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <img src="./images/libraries/cpp.svg" alt="C++" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">C++</p>
                </button>
                <button onclick="showLibraryA('c')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <img src="./images/libraries/c.svg" alt="C" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">C</p>
                </button>
                <button onclick="showLibraryA('javascript')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <img src="./images/libraries/javascript.svg" alt="JavaScript" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">JavaScript</p>
                </button>
                <button onclick="showLibraryA('typescript')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <img src="./images/libraries/typescript.svg" alt="TypeScript" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">TypeScript</p>
                </button>
                <button onclick="showLibraryA('python')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <img src="./images/libraries/python.svg" alt="Python" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">Python</p>
                </button>
                <button onclick="showLibraryA('csharp')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary">
                  <img src="./images/libraries/csharp.svg" alt="C#" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">C#</p>
                </button>
                <button onclick="showLibraryA('wasm')" class="lib-card-a group bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 border-2 border-transparent hover:border-primary relative">
                  <div class="absolute -top-1 -right-1 bg-gradient-to-r from-primary to-pink-600 text-white text-xs font-bold px-2 py-0.5 rounded-full">NEW</div>
                  <img src="./images/libraries/wasm.svg" alt="WASM" class="w-10 h-10 mx-auto mb-2 group-hover:scale-110 transition-transform" />
                  <p class="text-sm font-bold text-gray-900 dark:text-white">WASM</p>
                </button>
              </div>

              <div id="content-a-python" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4">🐍 Python</h4>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>Python with pip</li>
                  </ul>
                </div>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Installation:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-green-400">$ </span><span class="text-cyan-300">pip install</span> <span class="text-orange-300">kth</span></div>
                  </div>
                </div>
                <div>
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Example:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-purple-300">import</span> <span class="text-blue-300">kth</span></div>
                    <div><span class="text-purple-300">import</span> <span class="text-blue-300">asyncio</span></div>
                    <div></div>
                    <div><span class="text-purple-300">async def</span> <span class="text-yellow-300">main</span>():</div>
                    <div>  <span class="text-blue-300">config</span> = kth.config.<span class="text-yellow-300">getDefault</span>(kth.config.Network.mainnet)</div>
                    <div>  <span class="text-purple-300">with</span> kth.node.<span class="text-yellow-300">Node</span>(<span class="text-blue-300">config</span>, <span class="text-purple-300">True</span>) <span class="text-purple-300">as</span> <span class="text-blue-300">node</span>:</div>
                    <div>    <span class="text-purple-300">await</span> node.<span class="text-yellow-300">launch</span>(kth.primitives.StartModules.all)</div>
                    <div>    (_, <span class="text-blue-300">height</span>) = <span class="text-purple-300">await</span> node.chain.<span class="text-yellow-300">getLastHeight</span>()</div>
                    <div>    <span class="text-yellow-300">print</span>(<span class="text-green-300">f"Height: {</span><span class="text-blue-300">height</span><span class="text-green-300">}"</span>)</div>
                    <div></div>
                    <div>asyncio.<span class="text-yellow-300">run</span>(<span class="text-yellow-300">main</span>())</div>
                  </div>
                </div>
              </div>
              <div id="content-a-typescript" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4">📘 TypeScript</h4>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>Node.js with npm or yarn</li>
                    <li>TypeScript compiler</li>
                  </ul>
                </div>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Installation:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-green-400">$ </span><span class="text-cyan-300">npm install</span> <span class="text-orange-300">@knuth/bch</span></div>
                  </div>
                </div>
                <div>
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Example:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-purple-300">import</span> <span class="text-purple-300">*</span> <span class="text-purple-300">as</span> <span class="text-blue-300">kth</span> <span class="text-purple-300">from</span> <span class="text-green-300">"@knuth/bch"</span>;</div>
                    <div></div>
                    <div><span class="text-purple-300">const</span> <span class="text-blue-300">config</span> = kth.settings.<span class="text-yellow-300">getDefault</span>(kth.network.mainnet);</div>
                    <div><span class="text-purple-300">const</span> <span class="text-blue-300">node</span> = <span class="text-purple-300">new</span> kth.node.<span class="text-yellow-300">Node</span>(<span class="text-blue-300">config</span>, <span class="text-purple-300">false</span>);</div>
                    <div><span class="text-purple-300">await</span> node.<span class="text-yellow-300">launch</span>(kth.startModules.all);</div>
                    <div></div>
                    <div><span class="text-purple-300">const</span> [_, <span class="text-blue-300">height</span>] = <span class="text-purple-300">await</span> node.chain.<span class="text-yellow-300">getLastHeight</span>();</div>
                    <div>console.<span class="text-yellow-300">log</span>(<span class="text-green-300">`Height: ${</span><span class="text-blue-300">height</span><span class="text-green-300">}`</span>);</div>
                  </div>
                </div>
              </div>

              <div id="content-a-csharp" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <img src="./images/libraries/csharp.svg" alt="C#" class="w-6 h-6" />
                  <span>C#</span>
                </h4>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>.NET 8 framework</li>
                    <li>Python PIP package-management system</li>
                  </ul>
                </div>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Installation:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-green-400">$ </span><span class="text-cyan-300">dotnet add package</span> <span class="text-orange-300">kth-bch</span></div>
                  </div>
                </div>
                <div>
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Example:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-purple-300">using</span> <span class="text-blue-300">Knuth</span>;</div>
                    <div></div>
                    <div><span class="text-purple-300">var</span> <span class="text-blue-300">config</span> = Knuth.Config.Settings.<span class="text-yellow-300">GetDefault</span>(NetworkType.Mainnet);</div>
                    <div><span class="text-purple-300">using</span> (<span class="text-purple-300">var</span> <span class="text-blue-300">node</span> = <span class="text-purple-300">new</span> Knuth.<span class="text-yellow-300">Node</span>(<span class="text-blue-300">config</span>)) {</div>
                    <div>  <span class="text-purple-300">await</span> node.<span class="text-yellow-300">LaunchAsync</span>();</div>
                    <div>  <span class="text-purple-300">var</span> <span class="text-blue-300">height</span> = <span class="text-purple-300">await</span> node.Chain.<span class="text-yellow-300">GetLastHeightAsync</span>();</div>
                    <div>  Console.<span class="text-yellow-300">WriteLine</span>(<span class="text-green-300">$"Current height: {</span><span class="text-blue-300">height.Result</span><span class="text-green-300">}"</span>);</div>
                    <div>}</div>
                  </div>
                </div>
              </div>

              <div id="content-a-cpp" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <img src="./images/libraries/cpp.svg" alt="C++" class="w-6 h-6" />
                  <span>C++</span>
                </h4>

                <!-- Prerequisites -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>Python 3 with pip</li>
                    <li>GCC or compatible C++ compiler with C++20 support</li>
                    <li>CMake</li>
                  </ul>
                </div>

                <!-- Tooling Setup -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Tooling Setup:</p>
                  <div class="relative group">
                    <!-- SNIPPET:cpp-tooling-setup -->
                  </div>
                </div>

                <!-- Project Setup -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Project Setup:</p>
                  <p class="text-base text-gray-600 dark:text-gray-400 mb-2">Create <code class="bg-gray-200 dark:bg-gray-700 px-1 rounded">conanfile.txt</code>:</p>
                  <div class="relative group mb-3">
                    <!-- SNIPPET:cpp-conanfile -->
                  </div>
                  <p class="text-base text-gray-600 dark:text-gray-400 mb-2">Create <code class="bg-gray-200 dark:bg-gray-700 px-1 rounded">CMakeLists.txt</code>:</p>
                  <div class="relative group">
                    <!-- SNIPPET:cpp-cmake -->
                  </div>
                </div>

                <!-- Code Example -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Code (<code class="bg-gray-200 dark:bg-gray-700 px-1 rounded">pizza.cpp</code>):</p>
                  <div class="relative group">
                    <!-- SNIPPET:cpp-pizza -->
                  </div>
                </div>

                <!-- Build -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Build:</p>
                  <div class="relative group">
                    <!-- SNIPPET:cpp-build -->
                  </div>
                </div>

                <!-- Run -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Run:</p>
                  <div class="relative group">
                    <!-- SNIPPET:cpp-run -->
                  </div>
                </div>
              </div>

              <div id="content-a-c" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <img src="./images/libraries/c.svg" alt="C" class="w-6 h-6" />
                  <span>C</span>
                </h4>

                <!-- Prerequisites -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>Python 3 with pip</li>
                    <li>GCC or compatible C compiler</li>
                    <li>CMake</li>
                  </ul>
                </div>

                <!-- Tooling Setup -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Tooling Setup:</p>
                  <div class="relative group">
                    <!-- SNIPPET:c-tooling-setup -->
                  </div>
                </div>

                <!-- Project Setup -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Project Setup:</p>
                  <p class="text-base text-gray-600 dark:text-gray-400 mb-2">Create <code class="bg-gray-200 dark:bg-gray-700 px-1 rounded">conanfile.txt</code>:</p>
                  <div class="relative group mb-3">
                    <!-- SNIPPET:c-conanfile -->
                  </div>
                  <p class="text-base text-gray-600 dark:text-gray-400 mb-2">Create <code class="bg-gray-200 dark:bg-gray-700 px-1 rounded">CMakeLists.txt</code>:</p>
                  <div class="relative group">
                    <!-- SNIPPET:c-cmake -->
                  </div>
                </div>

                <!-- Code Example -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Code (<code class="bg-gray-200 dark:bg-gray-700 px-1 rounded">pizza.c</code>):</p>
                  <div class="relative group">
                    <!-- SNIPPET:c-pizza -->
                  </div>
                </div>

                <!-- Build -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Build:</p>
                  <div class="relative group">
                    <!-- SNIPPET:c-build -->
                  </div>
                </div>

                <!-- Run -->
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Run:</p>
                  <div class="relative group">
                    <!-- SNIPPET:c-run -->
                  </div>
                </div>
              </div>

              <div id="content-a-javascript" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <img src="./images/libraries/javascript.svg" alt="JavaScript" class="w-6 h-6" />
                  <span>JavaScript</span>
                </h4>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>Node.js with npm or yarn</li>
                  </ul>
                </div>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Installation:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-green-400">$ </span><span class="text-cyan-300">npm install</span> <span class="text-orange-300">@knuth/bch</span></div>
                  </div>
                </div>
                <div>
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Example:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-purple-300">const</span> <span class="text-blue-300">kth</span> = <span class="text-yellow-300">require</span>(<span class="text-green-300">"@knuth/bch"</span>);</div>
                    <div></div>
                    <div><span class="text-purple-300">const</span> <span class="text-blue-300">config</span> = kth.settings.<span class="text-yellow-300">getDefault</span>(kth.network.mainnet);</div>
                    <div><span class="text-purple-300">const</span> <span class="text-blue-300">node</span> = <span class="text-purple-300">new</span> kth.node.<span class="text-yellow-300">Node</span>(<span class="text-blue-300">config</span>, <span class="text-purple-300">false</span>);</div>
                    <div><span class="text-purple-300">await</span> node.<span class="text-yellow-300">launch</span>(kth.startModules.all);</div>
                    <div></div>
                    <div><span class="text-purple-300">const</span> [_, <span class="text-blue-300">height</span>] = <span class="text-purple-300">await</span> node.chain.<span class="text-yellow-300">getLastHeight</span>();</div>
                    <div>console.<span class="text-yellow-300">log</span>(<span class="text-green-300">\`Height: \${</span><span class="text-blue-300">height</span><span class="text-green-300">}\`</span>);</div>
                  </div>
                </div>
              </div>

              <div id="content-a-wasm" class="library-content-a hidden bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <img src="./images/libraries/wasm.svg" alt="WASM" class="w-6 h-6" />
                  <span>WebAssembly</span>
                </h4>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Prerequisites:</p>
                  <ul class="text-base text-gray-600 dark:text-gray-400 list-disc list-inside">
                    <li>Modern browser with WebAssembly support</li>
                  </ul>
                </div>
                <div class="mb-4">
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Installation:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-green-400">$ </span><span class="text-cyan-300">npm install</span> <span class="text-orange-300">@knuth/js-wasm</span></div>
                  </div>
                </div>
                <div>
                  <p class="text-base font-semibold text-gray-700 dark:text-gray-300 mb-2">Example:</p>
                  <div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                    <div><span class="text-purple-300">const</span> { loadLib, PaymentAddress } = __KTH_MODULE__;</div>
                    <div></div>
                    <div><span class="text-purple-300">await</span> <span class="text-yellow-300">loadLib</span>(<span class="text-green-300">'kth.wasm'</span>, <span class="text-green-300">'kth.js'</span>);</div>
                    <div></div>
                    <div><span class="text-purple-300">const</span> <span class="text-blue-300">addr</span> = PaymentAddress.<span class="text-yellow-300">fromString</span>(</div>
                    <div>  <span class="text-green-300">"bitcoincash:qz2qt6q9yf5e0ruzsk8l5v6mln03swvxpg6ez3j4jd"</span></div>
                    <div>);</div>
                    <div>console.<span class="text-yellow-300">log</span>(addr.<span class="text-yellow-300">encodedCashAddr</span>());</div>
                  </div>
                </div>
              </div>

              <div id="content-a-executable" class="library-content-a bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-2xl p-6 border-2 border-blue-200 dark:border-blue-800">
                <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                  <svg class="w-6 h-6 text-primary dark:text-purple-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm3.293 1.293a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 01-1.414-1.414L7.586 10 5.293 7.707a1 1 0 010-1.414zM11 12a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd"/>
                  </svg>
                  <span>Executable Node</span>
                </h4>

                <!-- Step 1: Setup -->
                <div class="mb-8">
                  <h5 class="text-md font-bold text-gray-900 dark:text-white mb-4 font-mono flex items-center gap-2">
                    <span class="text-primary dark:text-purple-400">1.</span>
                    Install and configure the Knuth build helper
                  </h5>

                  <!-- Command 1.1 -->
                  <div class="relative group mb-2">
                    <div class="bg-gray-900 dark:bg-black rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                      <div><span class="text-green-400 select-none">$ </span><span class="text-cyan-300">pip install conan</span><span class="text-purple-300"> --user --upgrade</span></div>
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="pip install conan --user --upgrade">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>
                  </div>

                  <!-- Command 1.2 -->
                  <div class="relative group mb-2">
                    <div class="bg-gray-900 dark:bg-black rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                      <div><span class="text-green-400 select-none">$ </span><span class="text-cyan-300">pip install kthbuild</span><span class="text-purple-300"> --user --upgrade</span></div>
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="pip install kthbuild --user --upgrade">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>
                  </div>

                  <!-- Command 1.3 -->
                  <div class="relative group mb-2">
                    <div class="bg-gray-900 dark:bg-black rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                      <div><span class="text-green-400 select-none">$ </span><span class="text-cyan-300">conan remote add kth </span><span class="text-blue-300">https://packages.kth.cash/api</span></div>
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="conan remote add kth https://packages.kth.cash/api">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>
                  </div>

                  <!-- Command 1.4 -->
                  <div class="relative group">
                    <div class="bg-gray-900 dark:bg-black rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                      <div class="whitespace-pre-wrap"><span class="text-green-400 select-none">$ </span><span class="text-cyan-300">conan config install </span><span class="text-blue-300">https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip</span></div>
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- Step 2: Install -->
                <div class="mb-8">
                  <h5 class="text-md font-bold text-gray-900 dark:text-white mb-4 font-mono flex items-center gap-2">
                    <span class="text-primary dark:text-purple-400">2.</span>
                    Install the node executable
                  </h5>

                  <div class="relative group">
                    <div class="bg-gray-900 dark:bg-black rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                      <div><span class="text-green-400 select-none">$ </span><span class="text-cyan-300">conan install </span><span class="text-purple-300">--requires=</span><span class="text-orange-300">kth/0.46.0</span><span class="text-purple-300"> --update --deployer=direct_deploy</span></div>
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="conan install --requires=kth/0.46.0 --update --deployer=direct_deploy">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- Step 3: Run -->
                <div>
                  <h5 class="text-md font-bold text-gray-900 dark:text-white mb-4 font-mono flex items-center gap-2">
                    <span class="text-primary dark:text-purple-400">3.</span>
                    Run the node
                  </h5>

                  <div class="relative group">
                    <div class="bg-gray-900 dark:bg-black rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
                      <div><span class="text-green-400 select-none">$ </span><span class="text-cyan-300">./kth/bin/kth</span></div>
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="./kth/bin/kth">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section id="features-info" class="relative bg-gradient-to-br from-gray-50 to-white dark:from-gray-800 dark:to-gray-900 py-12 transition-colors duration-300 overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-1/3 left-1/4 w-96 h-96 bg-blue-500 rounded-full blur-3xl"></div>
        <div class="absolute bottom-1/3 right-1/4 w-96 h-96 bg-purple-500 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16">
          <div class="inline-flex items-center gap-2 bg-blue-500/10 dark:bg-blue-500/30 px-4 py-2 rounded-full mb-6 animate-fade-in">
            <svg class="w-5 h-5 text-blue-600 dark:text-blue-400" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z"/>
              <path fill-rule="evenodd" d="M4 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v11a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 000 2h.01a1 1 0 100-2H7zm3 0a1 1 0 000 2h3a1 1 0 100-2h-3zm-3 4a1 1 0 100 2h.01a1 1 0 100-2H7zm3 0a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd"/>
            </svg>
            <span class="text-sm font-bold text-blue-600 dark:text-blue-400 uppercase tracking-wider">Technical Excellence</span>
          </div>
          <h2 class="text-4xl lg:text-5xl font-black text-gray-900 dark:text-white mb-4">
            <span class="bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 dark:from-blue-400 dark:via-purple-400 dark:to-pink-400 bg-clip-text text-transparent"># Features</span>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
            Modular architecture, beautiful code, and industry-leading standards for building production-grade applications.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <!-- Feature 1 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-blue-500/20 hover:shadow-2xl dark:hover:shadow-blue-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-blue-500 dark:hover:border-blue-400 animate-scale-in">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M3 12v3c0 1.657 3.134 3 7 3s7-1.343 7-3v-3c0 1.657-3.134 3-7 3s-7-1.343-7-3z"/>
                    <path d="M3 7v3c0 1.657 3.134 3 7 3s7-1.343 7-3V7c0 1.657-3.134 3-7 3S3 8.657 3 7z"/>
                    <path d="M17 5c0 1.657-3.134 3-7 3S3 6.657 3 5s3.134-3 7-3 7 1.343 7 3z"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">Development Platform</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              Full node implementation plus development platform. Modern <strong>C++23</strong> core with libraries in multiple languages for building custom Bitcoin Cash applications.
            </p>
          </div>

          <!-- Feature 2 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-purple-500/20 hover:shadow-2xl dark:hover:shadow-purple-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-purple-500 dark:hover:border-purple-400 animate-scale-in" style="animation-delay: 0.1s;">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500 to-pink-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M3 5a2 2 0 012-2h10a2 2 0 012 2v8a2 2 0 01-2 2h-2.22l.123.489.804.804A1 1 0 0113 18H7a1 1 0 01-.707-1.707l.804-.804L7.22 15H5a2 2 0 01-2-2V5zm5.771 7H5V5h10v7H8.771z" clip-rule="evenodd"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors">Cross-Platform</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              Works on any 64-bit architecture. Compile natively on Linux, Windows, macOS, FreeBSD, and more with zero friction. Run in the browser with <strong>WebAssembly</strong>.
            </p>
          </div>

          <!-- Feature 3 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-green-500/20 hover:shadow-2xl dark:hover:shadow-green-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-green-500 dark:hover:border-green-400 animate-scale-in" style="animation-delay: 0.2s;">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-teal-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-green-600 dark:group-hover:text-green-400 transition-colors">Optimized Build System</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              Auto-detects CPU microarchitecture and creates optimized binaries. Pre-compiled binaries compatible with <strong>Intel Haswell+</strong> architecture for maximum performance.
            </p>
          </div>

          <!-- Feature 4 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-orange-500/20 hover:shadow-2xl dark:hover:shadow-orange-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-orange-500 dark:hover:border-orange-400 animate-scale-in" style="animation-delay: 0.3s;">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M3 12v3c0 1.657 3.134 3 7 3s7-1.343 7-3v-3c0 1.657-3.134 3-7 3s-7-1.343-7-3z"/>
                    <path d="M3 7v3c0 1.657 3.134 3 7 3s7-1.343 7-3V7c0 1.657-3.134 3-7 3S3 8.657 3 7z"/>
                    <path d="M17 5c0 1.657-3.134 3-7 3S3 6.657 3 5s3.134-3 7-3 7 1.343 7 3z"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-orange-600 dark:group-hover:text-orange-400 transition-colors">Database Modes</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              Three database modes: <strong>normal</strong>, <strong>pruned</strong>, and <strong>full-indexed</strong> for specialized use cases.
            </p>
          </div>

          <!-- Feature 5 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-indigo-500/20 hover:shadow-2xl dark:hover:shadow-indigo-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-indigo-500 dark:hover:border-indigo-400 animate-scale-in" style="animation-delay: 0.4s;">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">Bitcoin Cash Since 2017</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              One of the first implementations supporting BCH from day one. Continuously updated with every protocol upgrade: <strong>Schnorr signatures</strong>, <strong>CashTokens</strong>, <strong>ABLA</strong>, and more.
            </p>
          </div>

          <!-- Feature 6 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-pink-500/20 hover:shadow-2xl dark:hover:shadow-pink-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-pink-500 dark:hover:border-pink-400 animate-scale-in" style="animation-delay: 0.5s;">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-pink-500 to-rose-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-pink-600 dark:group-hover:text-pink-400 transition-colors">Industry Standards</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              Built with Abseil, Boost, GMP, ICU. Toolchain: GCC, Clang, MSVC, CMake, Conan, clang-tidy, clang-format.
            </p>
          </div>

          <!-- Feature 7 -->
          <div class="group bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-cyan-500/20 hover:shadow-2xl dark:hover:shadow-cyan-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-cyan-500 dark:hover:border-cyan-400 animate-scale-in" style="animation-delay: 0.6s;">
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-cyan-600 dark:group-hover:text-cyan-400 transition-colors">Modular Architecture</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
              Completely modular design. Each module is an independent library following single-responsibility principle. Use them together or separately. Protocol changes can be introduced faster and more efficiently.
            </p>
          </div>

          <!-- Feature 8 -->
          <div class="group relative bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-lg dark:shadow-2xl dark:shadow-emerald-500/20 hover:shadow-2xl dark:hover:shadow-emerald-400/30 transition-all duration-300 hover:-translate-y-2 border-2 border-transparent hover:border-emerald-500 dark:hover:border-emerald-400 animate-scale-in col-span-1 md:col-span-2 lg:col-span-3" style="animation-delay: 0.7s;">
            <div class="absolute -top-3 -right-3 bg-gradient-to-r from-green-500 to-emerald-600 text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg animate-pulse">
              🔥 COMING SOON
            </div>
            <div class="flex items-start gap-4 mb-4">
              <div class="flex-shrink-0">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-green-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                  <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M4 4a2 2 0 00-2 2v1h16V6a2 2 0 00-2-2H4z"/>
                    <path fill-rule="evenodd" d="M18 9H2v5a2 2 0 002 2h12a2 2 0 002-2V9zM4 13a1 1 0 011-1h1a1 1 0 110 2H5a1 1 0 01-1-1zm5-1a1 1 0 100 2h1a1 1 0 100-2H9z" clip-rule="evenodd"/>
                  </svg>
                </div>
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-emerald-600 dark:group-hover:text-emerald-400 transition-colors">Wallet Capabilities</h3>
              </div>
            </div>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm max-w-4xl mb-4">
              Knuth libraries now include an <strong>evolved Wallet API</strong> for building production-grade wallet applications. Our <strong>WebAssembly binding</strong> enables cutting-edge web and mobile wallets with modern UI/UX — powered by the same battle-tested, high-performance C++ core.
            </p>
            <div class="flex flex-wrap gap-2">
              <span class="text-xs bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 px-3 py-1 rounded-full font-semibold">Web Wallets</span>
              <span class="text-xs bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 px-3 py-1 rounded-full font-semibold">Mobile Wallets</span>
              <span class="text-xs bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 px-3 py-1 rounded-full font-semibold">WebAssembly Powered</span>
              <span class="text-xs bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 px-3 py-1 rounded-full font-semibold">Battle-Tested C++ Core</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Interactive WASM Demo Section -->
    <section id="wasm-demo" class="relative py-12 bg-white dark:bg-gray-900 transition-colors duration-300 overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-0 left-1/3 w-96 h-96 bg-purple-500 rounded-full blur-3xl"></div>
        <div class="absolute bottom-0 right-1/3 w-96 h-96 bg-pink-500 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16">
          <div class="inline-flex items-center gap-2 bg-purple-500/10 dark:bg-purple-500/30 px-4 py-2 rounded-full mb-6 animate-fade-in">
            <svg class="w-5 h-5 text-purple-600 dark:text-purple-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clip-rule="evenodd" />
            </svg>
            <span class="text-sm font-bold text-purple-600 dark:text-purple-400 uppercase tracking-wider">Live Demo</span>
          </div>
          <h2 class="text-4xl lg:text-5xl font-black text-gray-900 dark:text-white mb-4">
            <span class="bg-gradient-to-r from-purple-600 via-pink-600 to-red-600 dark:from-purple-400 dark:via-pink-400 dark:to-red-400 bg-clip-text text-transparent"># Try it in Your Browser</span>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
            Experience the power of Knuth running natively in WebAssembly. No installation required!
          </p>
        </div>

        <!-- Example Selector -->
        <div class="mb-8">
          <h3 class="text-sm font-bold text-gray-700 dark:text-gray-300 mb-3">Choose an example:</h3>
          <div class="flex flex-wrap gap-2">
            <button onclick="loadExample('address-converter')" class="example-btn active px-4 py-2 bg-purple-600 text-white rounded-lg font-semibold text-sm hover:bg-purple-700 transition-all shadow-md">
              📬 Address Converter
            </button>
            <button onclick="loadExample('address-validator')" class="example-btn px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg font-semibold text-sm hover:bg-gray-300 dark:hover:bg-gray-600 transition-all">
              ✅ Address Validator
            </button>
            <button onclick="loadExample('wallet-generator')" class="example-btn px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg font-semibold text-sm hover:bg-gray-300 dark:hover:bg-gray-600 transition-all">
              👛 Wallet Generator
            </button>
            <button onclick="loadExample('sha256-hash')" class="example-btn px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg font-semibold text-sm hover:bg-gray-300 dark:hover:bg-gray-600 transition-all">
              #️⃣ SHA256 Hash
            </button>
            <button onclick="loadExample('libconfig')" class="example-btn px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg font-semibold text-sm hover:bg-gray-300 dark:hover:bg-gray-600 transition-all">
              ⚙️ Library Config
            </button>
          </div>
        </div>

        <!-- Demo Content -->
        <div class="grid lg:grid-cols-2 gap-8">
          <!-- Code Example -->
          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-gray-800 dark:to-gray-900 rounded-2xl p-6 border-2 border-gray-200 dark:border-gray-700 shadow-xl">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
                <svg class="w-5 h-5 text-purple-600 dark:text-purple-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
                </svg>
                <span id="example-title">Address Converter</span>
              </h3>
              <button id="run-example-btn" class="px-4 py-2 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-semibold rounded-lg transition-all duration-300 hover:scale-105 shadow-lg text-sm">
                ▶ Run
              </button>
            </div>
            <div id="demo-code-wrapper" class="rounded-xl overflow-hidden border-2 border-gray-700"></div>
          </div>

          <!-- Output Window -->
          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-gray-800 dark:to-gray-900 rounded-2xl p-6 border-2 border-gray-200 dark:border-gray-700 shadow-xl">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
                <svg class="w-5 h-5 text-green-600 dark:text-green-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm3.293 1.293a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 01-1.414-1.414L7.586 10 5.293 7.707a1 1 0 010-1.414zM11 12a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd"/>
                </svg>
                Output
              </h3>
              <button id="clear-output-btn" class="px-4 py-2 text-xs text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors">
                Clear
              </button>
            </div>
            <div id="demo-output" class="matrix-container bg-gray-900 dark:bg-black rounded-xl p-4 font-mono text-sm h-[450px] overflow-y-auto text-gray-300">
              <canvas id="demo-output-rain" class="matrix-rain"></canvas>
              <div class="matrix-content">
                <div class="text-gray-500 italic">// Output will appear here...</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Loading Indicator -->
        <!-- Loading indicator (floating, non-modal) -->
        <div id="wasm-loader" class="fixed bottom-8 right-8 z-50 animate-fade-in">
          <div class="bg-white dark:bg-gray-800 rounded-xl p-4 shadow-2xl border-2 border-purple-500/50 dark:border-purple-400/50">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 border-3 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
              <div>
                <p class="text-gray-900 dark:text-white font-semibold text-sm">Loading WASM...</p>
                <p class="text-xs text-gray-600 dark:text-gray-400">Please wait</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact Section -->
    <section id="contact" class="relative bg-gradient-to-br from-gray-100 to-gray-50 dark:from-gray-800 dark:to-gray-900 py-12 transition-colors duration-300 overflow-hidden">
      <!-- Decorative background -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-1/2 left-1/4 w-96 h-96 bg-purple-500 rounded-full blur-3xl"></div>
        <div class="absolute bottom-1/2 right-1/4 w-96 h-96 bg-pink-500 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16">
          <div class="inline-flex items-center gap-2 bg-purple-500/10 dark:bg-purple-500/30 px-4 py-2 rounded-full mb-6 animate-fade-in">
            <svg class="w-5 h-5 text-purple-600 dark:text-purple-400" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"/>
              <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"/>
            </svg>
            <span class="text-sm font-bold text-purple-600 dark:text-purple-400 uppercase tracking-wider">Let's Connect</span>
          </div>
          <h2 class="text-4xl lg:text-5xl font-black text-gray-900 dark:text-white mb-4">
            <span class="bg-gradient-to-r from-purple-600 via-pink-600 to-red-600 dark:from-purple-400 dark:via-pink-400 dark:to-red-400 bg-clip-text text-transparent"># Get in Touch</span>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Join our community, follow our updates, or reach out directly. We're always happy to connect!
          </p>
        </div>

        <!-- Contact Cards Grid -->
        <div class="flex flex-wrap justify-center gap-8">
          <!-- GitHub -->
          <a target="_blank" href="https://github.com/k-nuth" class="group flex flex-col items-center">
            <div class="w-16 h-16 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center shadow-md hover:shadow-lg transition-all duration-300 hover:-translate-y-1 border border-gray-200 dark:border-gray-700">
              <img class="w-8 h-8 dark:invert" src="./img/icons/github.svg" alt="GitHub" />
            </div>
            <span class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300 group-hover:text-gray-900 dark:group-hover:text-white transition-colors">GitHub</span>
          </a>

          <!-- X (Twitter) -->
          <a target="_blank" rel="nofollow" href="https://twitter.com/KnuthNode" class="group flex flex-col items-center">
            <div class="w-16 h-16 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center shadow-md hover:shadow-lg transition-all duration-300 hover:-translate-y-1 border border-gray-200 dark:border-gray-700">
              <img class="w-8 h-8 dark:invert" src="./img/icons/x-twitter.svg" alt="X (Twitter)" />
            </div>
            <span class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300 group-hover:text-gray-900 dark:group-hover:text-white transition-colors">X (Twitter)</span>
          </a>

          <!-- Telegram -->
          <a target="_blank" href="https://t.me/knuth_cash" class="group flex flex-col items-center">
            <div class="w-16 h-16 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center shadow-md hover:shadow-lg transition-all duration-300 hover:-translate-y-1 border border-gray-200 dark:border-gray-700">
              <img class="w-8 h-8 dark:invert" src="./img/icons/telegram.svg" alt="Telegram" />
            </div>
            <span class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300 group-hover:text-gray-900 dark:group-hover:text-white transition-colors">Telegram</span>
          </a>

          <!-- Email -->
          <a target="_blank" href="mailto:info@kth.cash" class="group flex flex-col items-center">
            <div class="w-16 h-16 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center shadow-md hover:shadow-lg transition-all duration-300 hover:-translate-y-1 border border-gray-200 dark:border-gray-700">
              <img class="w-8 h-8 dark:invert" src="./img/icons/mail.svg" alt="Email" />
            </div>
            <span class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300 group-hover:text-gray-900 dark:group-hover:text-white transition-colors">Email</span>
          </a>
        </div>

        <!-- Additional Info -->
        <div class="mt-16 text-center">
          <p class="text-gray-600 dark:text-gray-400">
            Open source, community-driven, and committed to Bitcoin Cash.
          </p>
        </div>
      </div>
    </section>

    <!-- Back to Top Button -->
    <a id="back2Top" href="#" class="fixed bottom-12 right-6 w-12 h-12 bg-primary hover:bg-primary-dark text-white rounded-full flex items-center justify-center shadow-lg hover:shadow-2xl transition-all duration-300 hover:scale-110 opacity-0 pointer-events-none">
      <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18" />
      </svg>
    </a>

    </div>
    <!-- End Main Content Wrapper -->

    <!-- Footer -->
    <!-- Footer -->
    <footer class="bg-gray-900 text-white py-6 text-center">
      <small>
        Copyright © 2016-<span id="current-year"></span>, Knuth
      </small>
    </footer>

    <!-- Knuth WASM Library -->
    <script type="text/javascript" src="./kth.js"></script>

    <!-- JavaScript -->
    <script>
      // Current year
      document.getElementById('current-year').textContent = new Date().getFullYear();

      // Fetch latest Knuth version from GitHub
      async function fetchLatestVersion() {
        let version = '0.73.0'; // Default version

        try {
          const response = await fetch('https://api.github.com/repos/k-nuth/kth-mono/releases/latest');
          const data = await response.json();
          version = data.tag_name.replace('v', ''); // Remove 'v' prefix if exists
        } catch (error) {
          console.log('Using default version 0.73.0');
        }

        // Replace all KTH_VERSION placeholders in the page
        replaceKthVersionPlaceholders(version);
      }

      // Replace all KTH_VERSION placeholders with actual version
      function replaceKthVersionPlaceholders(version) {
        // Update specific elements by ID
        const versionElement = document.getElementById('kth-version');
        if (versionElement) {
          versionElement.textContent = version;
        }

        const cConanfileVersion = document.getElementById('kth-version-c-conanfile');
        if (cConanfileVersion) {
          cConanfileVersion.textContent = version;
        }

        // Update copy button with new version
        const copyBtn = document.getElementById('copy-install-btn');
        if (copyBtn) {
          copyBtn.setAttribute('data-clipboard-text', `conan install --requires=kth/${version} --update --deployer=direct_deploy`);
        }

        // Replace all text nodes containing KTH_VERSION
        const walker = document.createTreeWalker(
          document.body,
          NodeFilter.SHOW_TEXT,
          null,
          false
        );

        const nodesToReplace = [];
        let node;
        while (node = walker.nextNode()) {
          if (node.nodeValue && node.nodeValue.includes('KTH_VERSION')) {
            nodesToReplace.push(node);
          }
        }

        nodesToReplace.forEach(node => {
          node.nodeValue = node.nodeValue.replace(/KTH_VERSION/g, version);
        });

        // Update all data-clipboard-text attributes containing KTH_VERSION
        document.querySelectorAll('[data-clipboard-text]').forEach(btn => {
          const text = btn.getAttribute('data-clipboard-text');
          if (text && text.includes('KTH_VERSION')) {
            btn.setAttribute('data-clipboard-text', text.replace(/KTH_VERSION/g, version));
          }
        });
      }

      // Fetch version on page load
      fetchLatestVersion();

      // Initialize clipboard for copy buttons
      const clipboard = new ClipboardJS('.copy-btn');

      clipboard.on('success', function(e) {
        const btn = e.trigger;
        const originalHTML = btn.innerHTML;

        // Show checkmark
        btn.innerHTML = '<svg class="w-5 h-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>';

        // Reset after 2 seconds
        setTimeout(() => {
          btn.innerHTML = originalHTML;
        }, 2000);

        e.clearSelection();
      });

      // ========== Library Selector Functions ==========

      // Show library content when card is clicked
      function showLibraryA(lang) {
        // Hide all content
        document.querySelectorAll('.library-content-a').forEach(el => el.classList.add('hidden'));
        // Show selected
        const content = document.getElementById(`content-a-${lang}`);
        if (content) {
          content.classList.remove('hidden');
        }
      }

      // Dark mode toggle - for both navbars
      const darkModeToggleInitial = document.getElementById('dark-mode-toggle-initial');
      const darkModeToggleMobileInitial = document.getElementById('dark-mode-toggle-mobile-initial');
      const darkModeToggle = document.getElementById('dark-mode-toggle');
      const darkModeToggleMobile = document.getElementById('dark-mode-toggle-mobile');

      // Get all icon elements
      const sunIconInitial = document.getElementById('sun-icon-initial');
      const moonIconInitial = document.getElementById('moon-icon-initial');
      const sunIconMobileInitial = document.getElementById('sun-icon-mobile-initial');
      const moonIconMobileInitial = document.getElementById('moon-icon-mobile-initial');
      const sunIcon = document.getElementById('sun-icon');
      const moonIcon = document.getElementById('moon-icon');
      const sunIconMobile = document.getElementById('sun-icon-mobile');
      const moonIconMobile = document.getElementById('moon-icon-mobile');

      // Check for saved dark mode preference or default to dark mode
      const currentMode = localStorage.getItem('darkMode') || 'dark';
      if (currentMode === 'dark') {
        document.documentElement.classList.add('dark');
        // Initial menu icons
        sunIconInitial.classList.remove('hidden');
        moonIconInitial.classList.add('hidden');
        sunIconMobileInitial.classList.remove('hidden');
        moonIconMobileInitial.classList.add('hidden');
        // Floating navbar icons
        sunIcon.classList.remove('hidden');
        moonIcon.classList.add('hidden');
        sunIconMobile.classList.remove('hidden');
        moonIconMobile.classList.add('hidden');
      }

      // Toggle dark mode function
      function toggleDarkMode() {
        document.documentElement.classList.toggle('dark');
        const isDark = document.documentElement.classList.contains('dark');

        // Toggle all icons
        sunIconInitial.classList.toggle('hidden');
        moonIconInitial.classList.toggle('hidden');
        sunIconMobileInitial.classList.toggle('hidden');
        moonIconMobileInitial.classList.toggle('hidden');
        sunIcon.classList.toggle('hidden');
        moonIcon.classList.toggle('hidden');
        sunIconMobile.classList.toggle('hidden');
        moonIconMobile.classList.toggle('hidden');

        // Save preference
        localStorage.setItem('darkMode', isDark ? 'dark' : 'light');
      }

      // Add click listeners to all 4 dark mode buttons
      darkModeToggleInitial.addEventListener('click', toggleDarkMode);
      darkModeToggleMobileInitial.addEventListener('click', toggleDarkMode);
      darkModeToggle.addEventListener('click', toggleDarkMode);
      darkModeToggleMobile.addEventListener('click', toggleDarkMode);

      // Mobile menu toggle - for initial menu
      const mobileMenuButtonInitial = document.getElementById('mobile-menu-button-initial');
      const mobileMenuInitial = document.getElementById('mobile-menu-initial');
      const menuIconOpenInitial = document.getElementById('menu-icon-open-initial');
      const menuIconCloseInitial = document.getElementById('menu-icon-close-initial');

      mobileMenuButtonInitial.addEventListener('click', () => {
        mobileMenuInitial.classList.toggle('hidden');
        menuIconOpenInitial.classList.toggle('hidden');
        menuIconCloseInitial.classList.toggle('hidden');
      });

      // Mobile menu toggle - for floating navbar
      const mobileMenuButton = document.getElementById('mobile-menu-button');
      const mobileMenu = document.getElementById('mobile-menu');
      const menuIconOpen = document.getElementById('menu-icon-open');
      const menuIconClose = document.getElementById('menu-icon-close');

      mobileMenuButton.addEventListener('click', () => {
        mobileMenu.classList.toggle('hidden');
        menuIconOpen.classList.toggle('hidden');
        menuIconClose.classList.toggle('hidden');
      });

      // Close both mobile menus when clicking a link
      document.querySelectorAll('.mobile-menu-link').forEach(link => {
        link.addEventListener('click', () => {
          mobileMenuInitial.classList.add('hidden');
          mobileMenu.classList.add('hidden');
          menuIconOpenInitial.classList.remove('hidden');
          menuIconCloseInitial.classList.add('hidden');
          menuIconOpen.classList.remove('hidden');
          menuIconClose.classList.add('hidden');
        });
      });

      // Navbar scroll effect - switch between initial and floating
      const initialMenu = document.getElementById('initial-menu');
      const floatingNavbar = document.getElementById('floating-navbar');
      const heroSection = document.querySelector('header');

      window.addEventListener('scroll', () => {
        // Get hero height dynamically
        const heroHeight = heroSection.offsetHeight;

        if (window.scrollY > heroHeight - 100) {
          initialMenu.classList.add('hidden-menu');
          floatingNavbar.classList.add('show');
        } else {
          initialMenu.classList.remove('hidden-menu');
          floatingNavbar.classList.remove('show');
        }
      });

      // Back to top button
      const backToTopButton = document.getElementById('back2Top');
      window.addEventListener('scroll', () => {
        if (window.scrollY > 300) {
          backToTopButton.classList.remove('opacity-0', 'pointer-events-none');
          backToTopButton.classList.add('opacity-100');
        } else {
          backToTopButton.classList.add('opacity-0', 'pointer-events-none');
          backToTopButton.classList.remove('opacity-100');
        }
      });

      backToTopButton.addEventListener('click', (e) => {
        e.preventDefault();
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });

      // Smooth scroll for anchor links
      document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
          const href = this.getAttribute('href');
          if (href !== '#' && href !== '#back2Top') {
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
              const offsetTop = target.offsetTop - 80; // Account for fixed navbar
              window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
              });
            }
          }
        });
      });

      // ===== WASM Demo Functionality =====
      let wasmReady = false;

      // Wait for WASM module to be available
      if (typeof __KTH_MODULE__ !== 'undefined') {
        const { loadLib, Kth, PaymentAddress, Wallet, HdPublic, HashFunctions } = __KTH_MODULE__;
        window.Kth = Kth;
        window.PaymentAddress = PaymentAddress;
        window.Wallet = Wallet;
        window.HdPublic = HdPublic;
        window.HashFunctions = HashFunctions;

        // Load WASM
        loadLib('./kth.wasm', './kth.js')
          .then(() => {
            wasmReady = true;

            // Hide loader
            document.getElementById('wasm-loader').style.display = 'none';
          })
          .catch(err => {
            console.error('Failed to load WASM:', err);
            document.getElementById('wasm-loader').style.display = 'none';
          });
      }

      // Matrix rain effect (falling down)
      function createMatrixRain(canvasId, duration = 1500) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return; // Canvas doesn't exist

        const ctx = canvas.getContext('2d');
        const container = canvas.parentElement;

        canvas.width = container.clientWidth;
        canvas.height = container.clientHeight;

        const fontSize = 14;
        const columns = Math.floor(canvas.width / fontSize);
        const drops = [];

        for (let i = 0; i < columns; i++) {
          drops[i] = Math.random() * -100;
        }

        const chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';

        canvas.classList.add('active');

        let frameCount = 0;
        const maxFrames = duration / 50;

        const draw = () => {
          ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
          ctx.fillRect(0, 0, canvas.width, canvas.height);

          ctx.fillStyle = '#22c55e';
          ctx.font = fontSize + 'px monospace';

          for (let i = 0; i < drops.length; i++) {
            const text = chars[Math.floor(Math.random() * chars.length)];
            const x = i * fontSize;
            const y = drops[i] * fontSize;

            ctx.fillText(text, x, y);

            if (y > canvas.height && Math.random() > 0.975) {
              drops[i] = 0;
            }

            drops[i]++;
          }

          frameCount++;
          if (frameCount < maxFrames) {
            requestAnimationFrame(draw);
          } else {
            canvas.classList.remove('active');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
          }
        };

        draw();
      }

      // Matrix rise effect (rising up from bottom)
      function createMatrixRise(canvasId, duration = 1500) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return; // Canvas doesn't exist

        const ctx = canvas.getContext('2d');
        const container = canvas.parentElement;

        canvas.width = container.clientWidth;
        canvas.height = container.clientHeight;

        const fontSize = 14;
        const columns = Math.floor(canvas.width / fontSize);
        const rises = [];

        // Start all columns from bottom
        for (let i = 0; i < columns; i++) {
          rises[i] = Math.floor(canvas.height / fontSize) + Math.random() * 20;
        }

        const chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';

        canvas.classList.add('active');

        let frameCount = 0;
        const maxFrames = duration / 50;

        const draw = () => {
          ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
          ctx.fillRect(0, 0, canvas.width, canvas.height);

          ctx.fillStyle = '#22c55e';
          ctx.font = fontSize + 'px monospace';

          for (let i = 0; i < rises.length; i++) {
            const text = chars[Math.floor(Math.random() * chars.length)];
            const x = i * fontSize;
            const y = rises[i] * fontSize;

            ctx.fillText(text, x, y);

            // Rise up (decrease y position)
            if (y < -fontSize && Math.random() > 0.975) {
              rises[i] = Math.floor(canvas.height / fontSize);
            }

            rises[i]--;
          }

          frameCount++;
          if (frameCount < maxFrames) {
            requestAnimationFrame(draw);
          } else {
            canvas.classList.remove('active');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
          }
        };

        draw();
      }

      // Character drop animation - sequential order (pure JavaScript)
      function createCharacterDrop(lineElement, text) {
        lineElement.innerHTML = '';
        const chars = text.split('');
        const charElements = [];

        // Create span for each character
        chars.forEach((char, index) => {
          const span = document.createElement('span');
          span.textContent = char === ' ' ? '\u00A0' : char; // Non-breaking space
          span.style.display = 'inline-block';
          span.style.opacity = '0';
          span.style.transform = 'translateY(-100px)';
          span.style.filter = 'blur(4px)';
          span.style.textShadow = '0 0 8px rgba(34, 197, 94, 0.6)';
          lineElement.appendChild(span);
          charElements.push(span);
        });

        // Animate each character with staggered delays
        charElements.forEach((span, index) => {
          const delay = index * 30; // 30ms delay per character
          const duration = 400 + Math.random() * 200; // Random duration between 400-600ms

          setTimeout(() => {
            const startTime = performance.now();
            const startY = -100;
            const endY = 0;

            function animate(currentTime) {
              const elapsed = currentTime - startTime;
              const progress = Math.min(elapsed / duration, 1);

              // Easing function (ease-out)
              const eased = 1 - Math.pow(1 - progress, 3);

              // Update transform
              const currentY = startY + (endY - startY) * eased;
              span.style.transform = `translateY(${currentY}px)`;
              span.style.opacity = eased;
              span.style.filter = `blur(${4 * (1 - eased)}px)`;

              if (progress < 1) {
                requestAnimationFrame(animate);
              } else {
                span.style.transform = 'translateY(0)';
                span.style.opacity = '1';
                span.style.filter = 'blur(0)';
              }
            }

            requestAnimationFrame(animate);
          }, delay);
        });
      }

      // Character drop animation - random order (pure JavaScript)
      function createCharacterDropRandom(lineElement, text) {
        lineElement.innerHTML = '';
        const chars = text.split('');
        const charElements = [];

        // Create span for each character
        chars.forEach((char, index) => {
          const span = document.createElement('span');
          span.textContent = char === ' ' ? '\u00A0' : char; // Non-breaking space
          span.style.display = 'inline-block';
          span.style.opacity = '0';
          span.style.transform = 'translateY(-100px)';
          span.style.filter = 'blur(4px)';
          span.style.textShadow = '0 0 8px rgba(34, 197, 94, 0.6)';
          lineElement.appendChild(span);
          charElements.push({ span, index });
        });

        // Create random order for character drops
        const randomOrder = [...charElements];
        for (let i = randomOrder.length - 1; i > 0; i--) {
          const j = Math.floor(Math.random() * (i + 1));
          [randomOrder[i], randomOrder[j]] = [randomOrder[j], randomOrder[i]];
        }

        // Animate each character in random order
        randomOrder.forEach((item, orderIndex) => {
          const delay = orderIndex * 25; // 25ms delay between each character drop
          const duration = 400 + Math.random() * 200; // Random duration between 400-600ms

          setTimeout(() => {
            const startTime = performance.now();
            const startY = -100;
            const endY = 0;

            function animate(currentTime) {
              const elapsed = currentTime - startTime;
              const progress = Math.min(elapsed / duration, 1);

              // Easing function (ease-out)
              const eased = 1 - Math.pow(1 - progress, 3);

              // Update transform
              const currentY = startY + (endY - startY) * eased;
              item.span.style.transform = `translateY(${currentY}px)`;
              item.span.style.opacity = eased;
              item.span.style.filter = `blur(${4 * (1 - eased)}px)`;

              if (progress < 1) {
                requestAnimationFrame(animate);
              } else {
                item.span.style.transform = 'translateY(0)';
                item.span.style.opacity = '1';
                item.span.style.filter = 'blur(0)';
              }
            }

            requestAnimationFrame(animate);
          }, delay);
        });
      }

      // Add output to demo output window
      function addOutput(text, type = 'log') {
        const outputDiv = document.getElementById('demo-output');
        let contentDiv = outputDiv.querySelector('.matrix-content');

        // Create content div if it doesn't exist
        if (!contentDiv) {
          contentDiv = document.createElement('div');
          contentDiv.className = 'matrix-content';
          outputDiv.appendChild(contentDiv);
        }

        const line = document.createElement('div');
        line.className = type === 'error' ? 'text-red-400 matrix-line' : 'text-green-400 matrix-line';
        contentDiv.appendChild(line);

        // Animate characters dropping in random order
        createCharacterDropRandom(line, text);

        outputDiv.scrollTop = outputDiv.scrollHeight;

        // Trigger matrix rain background effect
        createMatrixRain('demo-output-rain', 1000);
      }

      // Examples database
      const examples = {
        'address-converter': {
          title: 'Address Converter',
          code: `const addr = PaymentAddress.fromString(
  "bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a"
);

if (!addr) {
  console.log("Error: Invalid address");
  throw new Error("Invalid address");
}

console.log(\`Cash Address: \${addr.encodedCashAddr()}\`);
console.log(\`Legacy: \${addr.encodedLegacy()}\`);
console.log(\`CashTokens: \${addr.encodedCashTokens()}\`);`
        },
        'address-validator': {
          title: 'Address Validator',
          code: `const addresses = [
  "bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a",
  "invalid_address_123",
  "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
];

addresses.forEach(addr => {
  const isValid = PaymentAddress.isValid(addr);
  console.log(\`"\${addr.substring(0, 30)}..."\`);
  console.log(\`  Valid: \${isValid}\`);
  console.log("");
});`
        },
        'wallet-generator': {
          title: 'Wallet Generator',
          code: `// Replace with your own 12-word mnemonic seed phrase
const mnemonic = "";
const derivationPath = "m/44'/145'/0'/0";
const network = 'MAINNET';

if (!mnemonic || mnemonic.trim() === "") {
  console.log("Error: Please provide a valid mnemonic seed phrase");
  console.log("Example: 'word1 word2 word3 ... word12'");
  throw new Error("Mnemonic is required");
}

const wallet = Wallet.fromMnemonic(mnemonic.split(" "), derivationPath, network);

const addresses = await wallet.getAddresses(5);

console.log("Generated addresses:");
addresses.forEach((addr, index) => {
  console.log(\`  [\${index}]: \${addr.encodedCashAddr()}\`);
});`
        },
        'sha256-hash': {
          title: 'SHA256 Hash',
          code: `const messages = ["Hello Bitcoin Cash", "Knuth Node", "WebAssembly"];

messages.forEach(msg => {
  const bytes = new Uint8Array(
    msg.split('').map(c => c.charCodeAt(0))
  );

  const hash = HashFunctions.sha256(bytes);
  const hashHex = Array.from(hash)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  console.log(\`Message: "\${msg}"\`);
  console.log(\`SHA256:  \${hashHex}\`);
  console.log("");
});`
        },
        'libconfig': {
          title: 'Library Configuration',
          code: `const config = Kth.getLibconfig();

console.log("Knuth WebAssembly Library");
console.log("");
console.log(\`WASM Library: \${config.wasmLibraryVersion}\`);
console.log(\`C++ API: \${config.cppapiVersion}\`);
console.log(\`C API: \${config.capiVersion}\`);
console.log("");
console.log("Currency");
console.log(\`Network: \${config.currency}\`);
console.log(\`Symbol: \${config.currencySymbol}\`);
console.log("");
console.log("Build Info");
console.log(\`Architecture: \${config.architecture}\`);
console.log(\`Compiler: \${config.compilerName}\`);
console.log(\`Emscripten: \${config.emscriptenVersion}\`);
console.log(\`Optimization: \${config.optimizationLevel}\`);
console.log("");
console.log("Features");
console.log(\`Mempool: \${config.mempool}\`);
console.log(\`Read-only DB: \${config.dbReadonly}\`);
console.log(\`Debug Mode: \${config.debugMode}\`);`
        }
      };

      // Initialize CodeMirror
      let codeEditor;
      setTimeout(() => {
        codeEditor = CodeMirror(document.getElementById('demo-code-wrapper'), {
          value: examples['address-converter'].code,
          mode: 'javascript',
          theme: 'dracula',
          lineNumbers: true,
          lineWrapping: true,
          tabSize: 2,
          indentWithTabs: false,
          matchBrackets: true,
          autoCloseBrackets: true,
          styleActiveLine: true,
          viewportMargin: Infinity
        });
        codeEditor.setSize(null, '450px');
      }, 100);

      // Load example function
      window.loadExample = function(exampleId) {
        const example = examples[exampleId];
        if (!example) return;

        // Update code
        if (codeEditor) {
          codeEditor.setValue(example.code);
        }
        document.getElementById('example-title').textContent = example.title;

        // Update button styles
        document.querySelectorAll('.example-btn').forEach(btn => {
          btn.classList.remove('active', 'bg-purple-600', 'text-white', 'shadow-md');
          btn.classList.add('bg-gray-200', 'dark:bg-gray-700', 'text-gray-700', 'dark:text-gray-300');
        });
        event.target.classList.remove('bg-gray-200', 'dark:bg-gray-700', 'text-gray-700', 'dark:text-gray-300');
        event.target.classList.add('active', 'bg-purple-600', 'text-white', 'shadow-md');
      };

      // Run example code
      document.getElementById('run-example-btn').addEventListener('click', async () => {
        if (!wasmReady) {
          addOutput('Error: WebAssembly not loaded yet', 'error');
          return;
        }

        const outputDiv = document.getElementById('demo-output');
        outputDiv.innerHTML = '';

        // Get code from editor
        if (!codeEditor) {
          addOutput('Error: Code editor not initialized', 'error');
          return;
        }

        const code = codeEditor.getValue();
        if (!code.trim()) {
          addOutput('Error: No code to execute', 'error');
          return;
        }

        // Save original console methods
        const originalLog = console.log;
        const originalError = console.error;

        try {
          // Create a custom console.log for capturing output
          console.log = function(...args) {
            const output = args.map(arg =>
              typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
            ).join(' ');
            // If output is empty string, add a blank line
            addOutput(output === '' ? ' ' : output);
            originalLog.apply(console, args);
          };

          console.error = function(...args) {
            addOutput('ERROR: ' + args.join(' '), 'error');
            originalError.apply(console, args);
          };

          // Execute the code with async support
          const AsyncFunction = Object.getPrototypeOf(async function(){}).constructor;
          const fn = new AsyncFunction(code);
          await fn();

        } catch (err) {
          addOutput('Error: ' + err.message, 'error');
          originalLog('Stack trace:', err.stack);
        } finally {
          // ALWAYS restore original console methods
          console.log = originalLog;
          console.error = originalError;
        }
      });

      // Clear output
      document.getElementById('clear-output-btn').addEventListener('click', () => {
        const outputDiv = document.getElementById('demo-output');
        let contentDiv = outputDiv.querySelector('.matrix-content');

        if (!contentDiv) {
          contentDiv = document.createElement('div');
          contentDiv.className = 'matrix-content';
          outputDiv.appendChild(contentDiv);
        }

        contentDiv.innerHTML = '<div class="text-gray-500 italic">// Output will appear here...</div>';
      });

    </script>
  </body>
</html>
