<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Favicon using FontAwesome SVG -->
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 640' fill='%233b82f6'%3E%3Cpath d='M474.6 188.1C495.3 203.7 520.6 218.8 548.8 222.6C561.9 224.4 574 215.1 575.8 202C577.6 188.9 568.3 176.8 555.2 175C539.3 172.9 522 163.7 503.5 149.8C465.1 120.8 413 120.8 374.5 149.8C350.5 167.9 333.8 176.1 320 176.1C306.2 176.1 289.5 167.9 265.5 149.8C227.1 120.8 175 120.8 136.5 149.8C118 163.7 100.7 172.9 84.8 175C71.7 176.8 62.4 188.8 64.2 202C66 215.2 78 224.4 91.2 222.6C119.4 218.8 144.8 203.7 165.4 188.1C186.7 172 215.3 172 236.6 188.1C260.8 206.4 288.9 224 320 224C351.1 224 379.1 206.3 403.4 188.1C424.7 172 453.3 172 474.6 188.1zM474.6 332.1C495.3 347.7 520.6 362.8 548.8 366.6C561.9 368.4 574 359.1 575.8 346C577.6 332.9 568.3 320.8 555.2 319C539.3 316.9 522 307.7 503.5 293.8C465.1 264.8 413 264.8 374.5 293.8C350.5 311.9 333.8 320.1 320 320.1C306.2 320.1 289.5 311.9 265.5 293.8C227.1 264.8 175 264.8 136.5 293.8C118 307.7 100.7 316.9 84.8 319C71.7 320.7 62.4 332.8 64.2 346C66 359.2 78 368.4 91.2 366.6C119.4 362.8 144.8 347.7 165.4 332.1C186.7 316 215.3 316 236.6 332.1C260.8 350.4 288.9 368 320 368C351.1 368 379.1 350.3 403.4 332.1C424.7 316 453.3 316 474.6 332.1zM403.4 476.1C424.7 460 453.3 460 474.6 476.1C495.3 491.7 520.6 506.8 548.8 510.6C561.9 512.4 574 503.1 575.8 490C577.6 476.9 568.3 464.8 555.2 463C539.3 460.9 522 451.7 503.5 437.8C465.1 408.8 413 408.8 374.5 437.8C350.5 455.9 333.8 464.1 320 464.1C306.2 464.1 289.5 455.9 265.5 437.8C227.1 408.8 175 408.8 136.5 437.8C118 451.7 100.7 460.9 84.8 463C71.7 464.8 62.4 476.8 64.2 490C66 503.2 78 512.4 91.2 510.6C119.4 506.8 144.8 491.7 165.4 476.1C186.7 460 215.3 460 236.6 476.1C260.8 494.4 288.9 512 320 512C351.1 512 379.1 494.3 403.4 476.1z'/%3E%3C/svg%3E">
    <title>Login - SharkNet Messenger</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        primary: { 500: '#3b82f6', 600: '#2563eb' },
                        dark: { bg: '#0f172a', card: '#1e293b', border: '#334155' }
                    }
                }
            }
        }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r134/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/vanta@latest/dist/vanta.net.min.js"></script>
</head>

<body class="min-h-screen flex items-center justify-center transition-colors duration-300 p-4 relative overflow-hidden">

    <div id="vanta-bg" class="absolute inset-0 z-0"></div>

    <div class="absolute top-6 right-6 z-20">
        <button onclick="toggleLoginTheme()" class="w-10 h-10 rounded-full bg-white/80 dark:bg-dark-card/80 backdrop-blur-md border border-gray-200 dark:border-dark-border text-gray-600 dark:text-gray-300 flex items-center justify-center shadow-sm hover:bg-white dark:hover:bg-gray-800 transition-colors" title="Toggle Dark Mode">
            <i class="fas fa-moon dark:hidden"></i>
            <i class="fas fa-sun hidden dark:inline"></i>
        </button>
    </div>

    <div class="relative z-10 bg-white/85 dark:bg-dark-card/85 backdrop-blur-xl rounded-2xl shadow-2xl w-full max-w-md p-8 border border-white/50 dark:border-white/10 transition-colors duration-300 animate-[fadeIn_0.3s_ease-out]">

        <div class="text-center mb-8">
            <div class="w-16 h-16 bg-primary-500 text-white rounded-2xl flex items-center justify-center text-3xl mx-auto mb-4 shadow-lg">
                <i class="fas fa-water"></i>
            </div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-white font-mono tracking-tight">SharkNet</h1>
            <p class="text-gray-500 dark:text-gray-400 text-sm mt-2 font-medium">Decentralized P2P Communication</p>
        </div>

        <div id="error-message" class="hidden bg-red-50 dark:bg-red-900/40 text-red-600 dark:text-red-400 p-3 rounded-lg text-sm mb-4 border border-red-200 dark:border-red-800/50 flex items-center gap-2"></div>
        <div id="success-message" class="hidden bg-green-50 dark:bg-green-900/40 text-green-600 dark:text-green-400 p-3 rounded-lg text-sm mb-4 border border-green-200 dark:border-green-800/50 flex items-center gap-2"></div>

        <div id="loading" class="hidden text-center py-6">
            <i class="fas fa-spinner fa-spin text-3xl text-primary-500 mb-3"></i>
            <div class="text-gray-500 dark:text-gray-400 text-sm font-medium">Processing request...</div>
        </div>

        <div id="existing-peer-form" class="login-form space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Select Existing Peer</label>
                <div class="relative custom-dropdown">
                    <button type="button" onclick="toggleDropdown()" class="w-full flex justify-between items-center bg-gray-50/80 dark:bg-dark-bg/80 border border-gray-300 dark:border-dark-border text-gray-900 dark:text-white px-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow backdrop-blur-sm">
                        <span id="selected-peer-text" class="truncate">-- Select a peer --</span>
                        <i class="fas fa-chevron-down text-gray-400 text-sm transition-transform duration-200" id="dropdown-arrow"></i>
                    </button>
                    <div id="peer-dropdown-options" class="hidden absolute z-50 w-full mt-2 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-lg shadow-xl max-h-48 overflow-y-auto backdrop-blur-md">
                        </div>
                </div>
            </div>
            <button type="button" onclick="selectExistingPeer()" class="w-full bg-primary-500 hover:bg-primary-600 text-white font-bold py-3 px-4 rounded-lg transition-colors flex justify-center items-center gap-2 shadow-sm">
                <span>Continue</span> <i class="fas fa-arrow-right text-sm"></i>
            </button>
        </div>

        <div class="flex items-center my-6 login-form">
            <div class="flex-1 border-t border-gray-200 dark:border-dark-border"></div>
            <span class="px-3 text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider">OR</span>
            <div class="flex-1 border-t border-gray-200 dark:border-dark-border"></div>
        </div>

        <div id="new-peer-form" class="login-form space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Create New Peer</label>
                <input type="text" id="peer-name" placeholder="Enter peer name..." maxlength="50" class="w-full bg-gray-50/80 dark:bg-dark-bg/80 border border-gray-300 dark:border-dark-border text-gray-900 dark:text-white px-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow placeholder-gray-400 backdrop-blur-sm">
            </div>
            <button type="button" onclick="createNewPeer()" class="w-full bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white font-bold py-3 px-4 rounded-lg transition-colors shadow-sm flex justify-center items-center gap-2">
                <i class="fas fa-plus text-sm"></i> <span>Create New Peer</span>
            </button>
        </div>

        <div class="mt-6 text-center login-form">
            <button type="button" onclick="refreshPeers()" class="text-sm text-primary-500 hover:text-primary-600 dark:text-primary-400 dark:hover:text-primary-300 font-bold flex justify-center items-center gap-1.5 mx-auto transition-colors">
                <i class="fas fa-sync-alt"></i> Refresh Peer List
            </button>
        </div>

    </div>

    <script>
        const savedTheme = localStorage.getItem('snm-theme');
        const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        let isDarkTheme = savedTheme === 'dark' || (!savedTheme && prefersDark);

        if (isDarkTheme) {
            document.documentElement.classList.add('dark');
        }

        let vantaEffect = null;

        // Initialize Vanta.js NET effect with dynamic colors
        function initVanta(isDark) {
            if (vantaEffect) {
                vantaEffect.destroy(); // Destroy previous instance to re-render with new colors cleanly
            }
            vantaEffect = VANTA.NET({
                el: "#vanta-bg",
                mouseControls: true,
                touchControls: true,
                gyroControls: false,
                minHeight: 200.00,
                minWidth: 200.00,
                scale: 1.00,
                scaleMobile: 1.00,
                color: isDark ? 0x60a5fa : 0x2563eb,          // Nodes color (Light Blue vs Ocean Blue)
                backgroundColor: isDark ? 0x0f172a : 0xf0f9ff, // Background (Dark Slate vs Sky Blue)
                points: 13.00,
                maxDistance: 22.00,
                spacing: 18.00,
                showDots: true
            });
        }

        // Run animation when page loads
        document.addEventListener('DOMContentLoaded', () => {
            initVanta(isDarkTheme);
        });

        // Toggle Theme and synchronize Vanta.js colors
        function toggleLoginTheme() {
            document.documentElement.classList.toggle('dark');
            isDarkTheme = document.documentElement.classList.contains('dark');
            localStorage.setItem('snm-theme', isDarkTheme ? 'dark' : 'light');
            initVanta(isDarkTheme); // Refresh Vanta with the new theme colors
        }
    </script>

    <script src="js/login.js?v=5"></script>
</body>

</html>