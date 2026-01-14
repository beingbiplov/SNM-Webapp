<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <header>
        <div class="brand">
            <div class="logo-icon">S</div>
            SharkNet Messenger
        </div>
        <div class="header-status">
            <div class="status-item">Protocol Status: <span>ASAP/1.0 - OK</span></div>
            <div class="status-item">Peer Count: <span id="globalPeerCount">...</span></div>
            <div class="status-item">Network Mode: <span>Internet</span></div>
        </div>
    </header>
    <script>
        // Simple global peer counter and active peer tracker
        window.currentActivePeerId = null;
        fetch("/snm-webapp/api/peer").then(r => r.json()).then(peers => {
            document.getElementById('globalPeerCount').innerText = peers ? peers.length : 0;
            if (peers && peers.length > 0) {
                // Find first active peer
                const activePeer = peers.find(p => p.active);
                if (activePeer) {
                    window.currentActivePeerId = activePeer.peerId;
                    // Dispatch event so other pages know peer is ready
                    window.dispatchEvent(new CustomEvent('peerReady', { detail: activePeer.peerId }));
                }
            }
        }).catch(() => {
            const el = document.getElementById('globalPeerCount');
            if (el) el.innerText = "Offline";
        });
    </script>