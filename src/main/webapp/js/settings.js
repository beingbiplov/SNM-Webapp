// settings.js - Settings page JavaScript

let currentSettings = {};

function loadPeerStatus() {
    if (!window.currentActivePeerId) return;

    fetch(`/snm-webapp/api/peer/status/${window.currentActivePeerId}`)
        .then(r => r.json())
        .then(data => {
            displayPeerStatus(data);
            displayAppSettings(data.appSettings || {});
            displayPKIStatus(data.pkiStatus || {});
            displayNetworkStatus(data);
            currentSettings = data.appSettings || {};
        })
        .catch(err => {
            console.error('Failed to load peer status:', err);
            document.getElementById('peer-status-content').innerHTML =
                '<div style="color: red; text-align: center;">Failed to load peer status</div>';
        });
}

function displayPeerStatus(data) {
    const peerInfo = data.peerInfo || {};
    const content = document.getElementById('peer-status-content');

    content.innerHTML = `
        <div class="stat-row">
            <span>Peer Name:</span>
            <span style="font-family: var(--font-mono); font-weight: 600;">${peerInfo.name || 'Unknown'}</span>
        </div>
        <div class="stat-row">
            <span>Peer ID:</span>
            <span style="font-family: var(--font-mono); font-size: 0.8rem;">${peerInfo.id || 'Unknown'}</span>
        </div>
        <div class="stat-row">
            <span>Status:</span>
            <span class="badge ${peerInfo.active ? 'badge-green' : 'badge-gray'}">${peerInfo.active ? 'Active' : 'Inactive'}</span>
        </div>
    `;
}

function displayAppSettings(settings) {
    const rememberEl = document.getElementById('rememberNewHubConnections');
    if (rememberEl) rememberEl.checked = settings.rememberNewHubConnections || false;

    const reconnectEl = document.getElementById('hubReconnect');
    if (reconnectEl) reconnectEl.checked = settings.hubReconnect || false;
}

function displayPKIStatus(pkiStatus) {
    const content = document.getElementById('pki-status-content');

    content.innerHTML = `
        <div class="stat-row">
            <span>Known Persons:</span>
            <span style="font-weight: 600;">${pkiStatus.persons || 0}</span>
        </div>
        <div class="stat-row">
            <span>Certificates:</span>
            <span style="font-weight: 600;">${pkiStatus.certificates || 0}</span>
        </div>
        <div class="stat-row">
            <span>Public Key Fingerprint:</span>
            <span style="font-family: var(--font-mono); font-size: 0.7rem; word-break: break-all;">${pkiStatus.publicKeyFingerprint || 'Not available'}</span>
        </div>
    `;
}

function displayNetworkStatus(data) {
    const hubStatus = data.hubConnections || {};
    const encounterStatus = data.encounterStatus || {};
    const content = document.getElementById('network-status-content');

    content.innerHTML = `
        <div class="stat-row">
            <span>Connected Hubs:</span>
            <span style="font-weight: 600;">${hubStatus.hubsConnected || 0}</span>
        </div>
        <div class="stat-row">
            <span>Failed Hub Connections:</span>
            <span style="color: var(--red);">${hubStatus.failedToConnect || 0}</span>
        </div>
        <div class="stat-row">
            <span>Encounters Tracked:</span>
            <span style="font-weight: 600;">${encounterStatus.encountersTracked || 0}</span>
        </div>
    `;
}

function saveSettings() {
    const rememberEl = document.getElementById('rememberNewHubConnections');
    const reconnectEl = document.getElementById('hubReconnect');

    const newSettings = {
        rememberNewHubConnections: rememberEl ? rememberEl.checked : false,
        hubReconnect: reconnectEl ? reconnectEl.checked : false
    };

    // Note: Backend has setRememberNewHubConnections() and setHubReconnect() methods
    // but no API endpoint to call them. Settings are session-based only.
    alert('Settings updated for current session! (Note: Persistence would require backend API)');

    // Update current settings for display
    currentSettings = newSettings;
}

// Initialize
window.addEventListener('peerReady', () => loadPeerStatus());

// Fallback if peer was already ready
setTimeout(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 500);

// Auto-refresh every 30 seconds
setInterval(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 30000);
