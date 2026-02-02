<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();
    String activePeerName = (activePeer != null) ? activePeer.getPeerName() : "";
    String activePeerId = (activePeer != null) ? activePeer.getPeerID().toString() : "";
%>
    <header>
        <div class="brand">
            <div class="logo-icon">S</div>
            SharkNet Messenger
        </div>
        <div class="header-status">
            <div class="status-item">Active Peer: <span id="activePeerName"><%= activePeerName %></span></div>
            <div class="status-item">Protocol Status: <span>ASAP/1.0 - OK</span></div>
            <div class="status-item">Peer Count: <span id="globalPeerCount">...</span></div>
            <div class="status-item">Network Mode: <span>Internet</span></div>
            <button class="btn-logout" onclick="logout()" title="Logout and switch peer">
                🚪 Logout
            </button>
        </div>
    </header>
    <script>
        // Simple global peer counter and active peer tracker
        window.currentActivePeerId = '<%= activePeerId %>';
        fetch("/snm-webapp/api/peer").then(r => r.json()).then(peers => {
            document.getElementById('globalPeerCount').innerText = peers ? peers.length : 0;
            if (peers && peers.length > 0) {
                // Find first active peer
                const activePeer = peers.find(p => p.active);
                if (activePeer) {
                    window.currentActivePeerId = activePeer.peerId;
                    document.getElementById('activePeerName').innerText = activePeer.name;
                    // Dispatch event so other pages know peer is ready
                    window.dispatchEvent(new CustomEvent('peerReady', { detail: activePeer.peerId }));
                }
            }
        }).catch(() => {
            const el = document.getElementById('globalPeerCount');
            if (el) el.innerText = "Offline";
        });
        
        function logout() {
            if (confirm('Are you sure you want to logout? This will stop the active peer.')) {
                // Stop the active peer
                if (window.currentActivePeerId) {
                    fetch(`/snm-webapp/api/stop/${window.currentActivePeerId}`, {
                        method: 'POST'
                    }).then(() => {
                        // Redirect to login page
                        window.location.href = '/snm-webapp/login.jsp';
                    }).catch(() => {
                        // Even if stop fails, redirect to login
                        window.location.href = '/snm-webapp/login.jsp';
                    });
                } else {
                    window.location.href = '/snm-webapp/login.jsp';
                }
            }
        }
    </script>
    
    <style>
        .btn-logout {
            background: #ef4444;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.8rem;
            cursor: pointer;
            transition: background-color 0.2s;
            font-family: 'JetBrains Mono', monospace;
            margin-left: 12px;
        }
        
        .btn-logout:hover {
            background: #dc2626;
        }
        
        .header-status {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }
        
        @media (max-width: 768px) {
            .header-status {
                gap: 8px;
            }
            
            .btn-logout {
                margin-left: 8px;
            }
        }
    </style>