<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();
    String activePeerName = (activePeer != null) ? activePeer.getPeerName() : "";
    String activePeerId = (activePeer != null) ? activePeer.getPeerID().toString() : "";
%>

<!-- Tailwind CSS CDN & Configuration -->
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

<!-- FontAwesome CDN -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- Sticky Header fixed to h-16 (64px) -->
<header class="sticky top-0 z-50 w-full h-16 backdrop-blur-md bg-white/80 dark:bg-dark-card/80 border-b border-gray-200 dark:border-dark-border px-4 sm:px-6 transition-colors duration-300 shadow-sm flex items-center justify-between">
    
    <!-- Left: Toggle & Brand -->
    <div class="flex items-center gap-3 sm:gap-4">
        <button onclick="toggleSidebar()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors focus:outline-none" title="Toggle Sidebar">
            <i class="fas fa-bars text-xl"></i>
        </button>
        <div class="bg-gradient-to-br from-primary-500 to-blue-700 text-white font-bold w-9 h-9 sm:w-10 sm:h-10 flex items-center justify-center rounded-lg text-lg sm:text-xl shadow-md">
            <i class="fas fa-water"></i>
        </div>
        <span class="font-bold text-lg sm:text-xl text-gray-800 dark:text-white font-mono hidden sm:block tracking-tight">SharkNet</span>
    </div>

    <!-- Right: Status, Help, Theme, Logout -->
    <div class="flex items-center gap-2 sm:gap-4">
        <div class="hidden lg:flex items-center gap-2 border-r border-gray-200 dark:border-gray-700 pr-4">
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 border border-blue-100 dark:border-blue-800/50 shadow-sm" title="Active Peer">
                <i class="fas fa-user-circle text-sm"></i> <span id="activePeerName"><%= activePeerName %></span>
            </div>
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-green-50 text-green-700 dark:bg-green-900/30 dark:text-green-400 border border-green-100 dark:border-green-800/50 shadow-sm" title="Network Mode">
                <i class="fas fa-globe text-sm"></i> Internet
            </div>
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300 border border-gray-200 dark:border-gray-700 shadow-sm" title="Online Peers Count">
                <i class="fas fa-users text-sm"></i> <span id="globalPeerCount">...</span>
            </div>
        </div>

        <a href="welcome.jsp" class="flex items-center gap-2 text-gray-500 hover:text-primary-600 dark:text-gray-400 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 px-3 py-2 rounded-lg transition-colors font-medium text-sm" title="Help & Welcome Page">
            <i class="fas fa-question-circle text-lg"></i>
            <span class="hidden md:block">Help</span>
        </a>

        <button id="themeToggleBtn" onclick="toggleTheme()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors flex items-center justify-center w-9 h-9 sm:w-10 sm:h-10 focus:outline-none" title="Toggle Dark Mode">
            <i class="fas fa-moon text-lg"></i>
        </button>

        <button onclick="logout()" class="bg-red-50 hover:bg-red-100 dark:bg-red-900/20 dark:hover:bg-red-900/40 text-red-600 dark:text-red-400 border border-red-200 dark:border-red-800/50 px-3 py-2 sm:px-4 rounded-lg text-sm font-medium transition-colors shadow-sm flex items-center gap-2" title="Logout">
            <i class="fas fa-sign-out-alt"></i>
            <span class="hidden sm:block">Logout</span>
        </button>
    </div>
</header>

<!-- Rest of the scripts... -->
<script>
    window.currentActivePeerId = '<%= activePeerId %>';
    fetch("/snm-webapp/api/peer").then(r => r.json()).then(peers => {
        document.getElementById('globalPeerCount').innerText = peers ? peers.length : 0;
        if (peers && peers.length > 0) {
            const activePeer = peers.find(p => p.active);
            if (activePeer) {
                window.currentActivePeerId = activePeer.peerId;
                document.getElementById('activePeerName').innerText = activePeer.name;
                window.dispatchEvent(new CustomEvent('peerReady', { detail: activePeer.peerId }));
            }
        }
    }).catch(() => {
        const el = document.getElementById('globalPeerCount');
        if (el) el.innerText = "Offline";
    });

    function logout() {
        if (confirm('Are you sure you want to logout? This will stop the active peer.')) {
            if (window.currentActivePeerId) {
                fetch(`/snm-webapp/api/stop/${window.currentActivePeerId}`, { method: 'POST' })
                    .then(() => window.location.href = '/snm-webapp/login.jsp')
                    .catch(() => window.location.href = '/snm-webapp/login.jsp');
            } else {
                window.location.href = '/snm-webapp/login.jsp';
            }
        }
    }
</script>

<!-- Scripts -->
<script src="js/ui-ux.js?v=5"></script>