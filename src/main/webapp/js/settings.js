// settings.js - Settings page JavaScript

let currentSettings = {};

/**
 * Loads the status of the current active peer from the backend API.
 * Initiates the display of various status sections.
 * @return {void}
 */
function loadPeerStatus() {
    if (!window.currentActivePeerId) return;

    const peerId = encodeURIComponent(window.currentActivePeerId);
    console.log('Loading status for peer:', peerId);

    fetch(`/snm-webapp/api/peer/status/${peerId}`)
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`Status ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            displayPeerStatus(data);
            displayPKIStatus(data.pkiStatus || {});
            displayNetworkStatus(data);

            // Load application settings with data from the server
            loadApplicationSettings(data.appSettings || {});
        })
        .catch(err => {
            console.error('Failed to load peer status:', err);
            const content = document.getElementById('peer-status-content');
            if (content) {
                content.innerHTML = `<div style="color: red; text-align: center;">Failed to load peer status: ${err.message}</div>`;
            }
        });
}

/**
 * Renders the basic peer information (Name, ID, Status).
 * @param {Object} data - The peer status data object
 * @return {void}
 */
function displayPeerStatus(data) {
    const peerInfo = data.peerInfo || {};
    const content = document.getElementById('peer-status-content');
    if (!content) return;

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

/**
 * Renders the PKI status details.
 * @param {Object} pkiStatus - The PKI status data object
 * @return {void}
 */
function displayPKIStatus(pkiStatus) {
    const content = document.getElementById('pki-status-content');
    if (!content) return;

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

/**
 * Renders the network connection statistics.
 * @param {Object} data - The network status data object
 * @return {void}
 */
function displayNetworkStatus(data) {
    const hubStatus = data.hubConnections || {};
    const encounterStatus = data.encounterStatus || {};
    const content = document.getElementById('network-status-content');
    if (!content) return;

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

/**
 * Populates the Application Settings UI. Merges server data with mock data
 * for newly proposed features that might not be in the backend yet.
 * @param {Object} serverSettings - The settings object retrieved from the server
 * @return {void}
 */
function loadApplicationSettings(serverSettings) {
    console.log("Loading application settings...");

    // MOCK DATA: Simulating settings for UI testing
    const mockSettings = {
        defaultSign: true,
        defaultEncrypt: false,
        displayName: "SharkNet_User_01"
    };

    // Bind data to UI elements
    const rememberEl = document.getElementById('rememberNewHubConnections');
    if (rememberEl) rememberEl.checked = (serverSettings.rememberNewHubConnections !== undefined) ? serverSettings.rememberNewHubConnections : true;

    const reconnectEl = document.getElementById('hubReconnect');
    if (reconnectEl) reconnectEl.checked = (serverSettings.hubReconnect !== undefined) ? serverSettings.hubReconnect : true;

    const signEl = document.getElementById('defaultSignMsg');
    if (signEl) signEl.checked = mockSettings.defaultSign;

    const encEl = document.getElementById('defaultEncryptMsg');
    if (encEl) encEl.checked = mockSettings.defaultEncrypt;

    const nameEl = document.getElementById('customDisplayName');
    if (nameEl) nameEl.value = mockSettings.displayName;

    currentSettings = serverSettings;
}

/**
 * Collects data from the Application Settings UI and simulates saving to the backend.
 * Bound to the "Save Changes" button.
 * @return {Promise<void>} Resolves when the save operation is complete
 */
async function saveSettings() {
    // Collect values from the DOM
    const settingsPayload = {
        defaultSign: document.getElementById('defaultSignMsg')?.checked || false,
        defaultEncrypt: document.getElementById('defaultEncryptMsg')?.checked || false,
        rememberNewHubConnections: document.getElementById('rememberNewHubConnections')?.checked || false,
        hubReconnect: document.getElementById('hubReconnect')?.checked || false,
        displayName: document.getElementById('customDisplayName')?.value || ""
    };

    console.log("Sending settings to backend:", settingsPayload);

    // TODO: Uncomment the fetch request below when SettingsServlet is implemented
    /*
    try {
        const response = await fetch('api/settings', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(settingsPayload)
        });

        if (!response.ok) {
            throw new Error("Failed to save settings to the server.");
        }
    } catch (error) {
        console.error("Error saving settings:", error);
        alert("Error saving settings. Check console for details.");
        return;
    }
    */

    // Alert user of success (mock behavior)
    alert("Settings successfully saved! (Note: Persistence requires backend API)");
    currentSettings = settingsPayload;
}

// Initialization Events
window.addEventListener('peerReady', () => loadPeerStatus());

// Fallback if the peer was already ready before the script loaded
setTimeout(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 500);

// Auto-refresh status data every 30 seconds
setInterval(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 30000);