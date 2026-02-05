// certificates.js - Certificate Management JavaScript

let certificates = [];
let pendingCredentials = [];
let trustLevelCache = new Map(); // Cache trust levels to avoid repeated API calls
let lastRefreshTime = 0;
const REFRESH_INTERVAL = 15000; // 15 seconds instead of 5

// Global state for filtering
let currentFilter = {
    type: 'all',
    issuer: '',
    subject: '',
    trust: ''
};

function formatCertificateDate(value, withTime) {
    if (value === undefined || value === null) return 'Unknown';

    const str = String(value).trim();

    let date;

    // Check if it's a numeric timestamp (milliseconds)
    if (/^\-?\d+$/.test(str)) {
        date = new Date(Number(str));
    } else {
        // Try parsing string date
        date = new Date(str);

        // Handle timezone abbreviations if standard parsing fails
        if (isNaN(date.getTime())) {
            const scrubbed = str.replace(/\s[A-Z]{3,4}\s/, ' ');
            date = new Date(scrubbed);
        }
    }

    if (isNaN(date.getTime())) {
        console.warn('Date parsing failed for:', value);
        return 'Unknown';
    }

    try {
        const options = withTime ?
            { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' } :
            { day: '2-digit', month: '2-digit', year: 'numeric' };

        return date.toLocaleDateString(undefined, options);
    } catch (e) {
        console.error('Date formatting error:', e);
        return 'Unknown';
    }
}

function formatCertificateDateDeprecated(value, withTime) {
    if (value === undefined || value === null) return 'Unknown';

    const str = String(value).trim();
    console.log(`Formatting date: value="${value}", str="${str}"`); // Debug log

    let date;

    // Check if it's a numeric timestamp (milliseconds)
    if (/^\-?\d+$/.test(str)) {
        const num = Number(str);
        // Safety check: if it's very small (e.g. seconds since epoch), multiply by 1000? 
        // Java .getTime() is always ms, so typically > 10^12 for recent dates.
        date = new Date(num);
    } else {
        // Try parsing string date
        date = new Date(str);
        if (isNaN(date.getTime())) {
            // Try cleaning up common Java toString formats if needed
            // e.g. "Mon Feb 05 11:20:00 CET 2026"
            // JS Date parse is pretty good, but sometimes needs help.
            // Let's rely on standard parsing first.
        }
    }

    if (isNaN(date.getTime())) {
        console.warn('Date parsing failed for:', value);
        return 'Unknown';
    }

    try {
        const result = withTime ? date.toLocaleString() : date.toLocaleDateString();
        // Check if browser returned "Invalid Date" string
        if (result === 'Invalid Date') return 'Unknown';
        return result;
    } catch (e) {
        console.error('Date formatting error:', e);
        return 'Unknown';
    }
}


// Silent data refresh with caching
async function refreshDataSilently() {
    try {
        // Refresh pending credentials
        await loadPendingCredentials();
        
        // Refresh certificates with caching
        await loadCertificates(true);
    } catch (error) {
        console.error('Silent refresh error:', error);
    }
}

// Load certificates on page load
document.addEventListener('DOMContentLoaded', function () {
    console.log('=== CERTIFICATE PAGE LOADED ===');
    // Test basic connectivity first
    console.log('Testing basic connectivity...');
    fetch('/snm-webapp/api/peer')
        .then(response => {
            if (!response.ok) {
                console.error('Basic connectivity test FAILED:', response.status);
            } else {
                console.log('Basic connectivity test SUCCESS: API server responding');
            }
        })
        .catch(error => {
            console.error('Basic connectivity test ERROR:', error);
        });

    loadCertificates();
    loadPendingCredentials();
    loadOwnCertificate();

    // Auto-refresh every 15 seconds (reduced from 5)
    setInterval(() => {
        const importModal = document.getElementById('import-modal');
        const detailsModal = document.getElementById('details-modal');
        
        // Only refresh if modals are not visible AND enough time has passed
        const now = Date.now();
        if ((!importModal || importModal.style.display === 'none') &&
            (!detailsModal || detailsModal.style.display === 'none') &&
            (now - lastRefreshTime >= REFRESH_INTERVAL)) {
            
            lastRefreshTime = now;
            refreshDataSilently();
        }
    }, 5000); // Check every 5s but only refresh if 15s have passed
});

// Load own certificate information
async function loadOwnCertificate() {
    try {
        const response = await fetch('/snm-webapp/api/peer');
        if (response.ok) {
            const peers = await response.json();
            const activePeer = peers.find(p => p.active);
            if (activePeer) {
                document.getElementById('your-peer-id').textContent = activePeer.peerId;
            }
        }
    } catch (error) {
        console.error('Error loading own certificate:', error);
    }
}

// Load certificates from backend
async function loadCertificates(silent = false) {
    if (!silent) console.log('=== LOAD CERTIFICATES START ===');
    const tbody = document.getElementById('certificates-tbody');

    if (!silent) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:20px; color:var(--text-muted);">Loading certificates...</td></tr>';
    }

    try {
        // Get active peer ID
        if (!silent) console.log('Step 1: Fetching active peer...');
        const peersResponse = await fetch('/snm-webapp/api/peer');

        if (!peersResponse.ok) {
            if (!silent) console.error('Step 1 FAILED: Peers API not OK:', peersResponse.status);
            if (!silent) tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:red;">Failed to load peers. Please check if app is running.</td></tr>';
            return;
        }

        const peers = await peersResponse.json();
        const activePeer = peers.find(p => p.active);

        if (!activePeer) {
            if (!silent) console.error('Step 1 FAILED: No active peer found');
            if (!silent) tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:var(--text-muted);">No active peer found - Please login first.</td></tr>';
            return;
        }

        // Load certificates
        if (!silent) console.log('Step 2: Loading certificates for peer:', activePeer.peerId);
        const certResponse = await fetch(`/snm-webapp/api/pki/certificates?peerId=${encodeURIComponent(activePeer.peerId)}`);

        if (!certResponse.ok) {
            if (!silent) console.error('Step 2 FAILED: Certificate API not OK:', certResponse.status);
            if (!silent) tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:red;">Error loading certificates</td></tr>';
            return;
        }

        const certData = await certResponse.json();
        const newCertificates = certData.certificates || [];

        // Simple check to avoid unnecessary re-rendering if data hasn't changed (naïve length check)
        if (silent && newCertificates.length === certificates.length) {
            // We could do a deeper check, but for now this prevents flickering if count is same
            // Actually, trust levels might change, so we should arguably update anyway.
            // But to be "perfectly workable" and safe, let's just update.
            // However, to prevent flickering, we update the data and call display.
        }

        certificates = newCertificates;
        displayCertificates();
        if (!silent) console.log('=== LOAD CERTIFICATES END ===');

    } catch (error) {
        if (!silent) {
            console.error('=== LOAD CERTIFICATES ERROR ===', error);
            tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:red;">Error: ' + error.message + '</td></tr>';
        }
    }
}

// Display certificates in table
function displayCertificates() {
    const tbody = document.getElementById('certificates-tbody');

    if (certificates.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:20px; color:var(--text-muted);">No certificates found</td></tr>';
        return;
    }

    // We can optimize this by diffing, but full rebuild is safer for exactness
    tbody.innerHTML = '';
    certificates.forEach((cert, index) => {
        const row = document.createElement('tr');

        // Extract subject and issuer names from objects
        const subjectName = cert.subject && cert.subject.name ? cert.subject.name : 'Unknown';
        const subjectId = cert.subject && cert.subject.id ? cert.subject.id : 'Unknown';
        const issuerName = cert.issuedBy && cert.issuedBy.name ? cert.issuedBy.name : 'Unknown';
        const issuerId = cert.issuedBy && cert.issuedBy.id ? cert.issuedBy.id : 'Unknown';
        const validUntil = formatCertificateDate(cert.validUntil, false);

        // Initial loading state for trust badge
        let trustBadge = 'badge-gray';

        row.innerHTML = `
            <td><span style="font-family:var(--font-mono)" title="${subjectId}">${subjectName}</span></td>
            <td><span title="${issuerId}">${issuerName}</span></td>
            <td>${validUntil}</td>
            <td><span class="badge ${trustBadge}" id="trust-badge-${index}">Loading...</span></td>
            <td>
                <button class="btn-secondary" onclick="showCertificateDetails(${index})">Details</button>
                <button class="btn-outline-danger" style="margin-left:8px;" onclick="revokeCertificate('${subjectId}')">Revoke</button>
            </td>
        `;
        tbody.appendChild(row);

        // Load trust level asynchronously
        loadTrustLevel(index, subjectId);
    });
}

// Load trust level for a certificate (with caching)
async function loadTrustLevel(index, subjectId) {
    // Check cache first
    if (trustLevelCache.has(subjectId)) {
        const cached = trustLevelCache.get(subjectId);
        updateTrustBadge(index, cached);
        return;
    }
    
    try {
        const response = await fetch(`/snm-webapp/api/pki/identityAssurance?subjectId=${encodeURIComponent(subjectId)}`);
        if (response.ok) {
            const data = await response.json();
            const trustLevel = data.identityAssuranceText || data.identityAssurance || 'Unknown';
            const trustBadge = getTrustBadgeClass(data.identityAssurance);
            
            // Cache the result
            trustLevelCache.set(subjectId, {
                level: trustLevel,
                badgeClass: trustBadge,
                iaValue: data.identityAssurance
            });
            
            updateTrustBadge(index, trustLevelCache.get(subjectId));
        }
    } catch (error) {
        console.error('Error loading trust level:', error);
        // Cache error state to avoid repeated failed calls
        trustLevelCache.set(subjectId, { level: 'Error', badgeClass: 'badge-gray', iaValue: null });
        updateTrustBadge(index, trustLevelCache.get(subjectId));
    }
}

// Update trust badge UI
function updateTrustBadge(index, trustData) {
    const badgeEl = document.getElementById(`trust-badge-${index}`);
    if (badgeEl) {
        badgeEl.textContent = trustData.level;
        badgeEl.className = `badge ${trustData.badgeClass}`;
    }
}

// Load pending credentials
async function loadPendingCredentials() {
    try {
        const response = await fetch('/snm-webapp/api/pki/pendingCredentials');
        if (response.ok) {
            const data = await response.json();
            pendingCredentials = data.credentials || [];
            displayPendingCredentials();
        }
    } catch (error) {
        console.error('Error loading pending credentials:', error);
    }
}

// Display pending credentials
function displayPendingCredentials() {
    const container = document.getElementById('pending-credentials-container');
    const countBadge = document.getElementById('pending-count');

    countBadge.textContent = pendingCredentials.length;

    if (pendingCredentials.length === 0) {
        container.innerHTML = '<div style="text-align:center; padding:20px; color:var(--text-muted);">No pending credential requests</div>';
        return;
    }

    container.innerHTML = '';
    pendingCredentials.forEach((cred, index) => {
        const credDiv = document.createElement('div');
        credDiv.className = 'pending-credential-item';
        credDiv.style.cssText = 'padding: 12px; border: 1px solid var(--border-color); border-radius: 8px; margin-bottom: 12px; background: var(--bg-card);';
        credDiv.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <div style="font-weight: 600;">${cred.sender || 'Unknown Sender'}</div>
                    <div style="color: var(--text-muted); font-size: 0.9rem;">${cred.message || 'No message'}</div>
                </div>
                <div style="display: flex; gap: 8px;">
                    <button class="btn-secondary" onclick="acceptCredential(${index})">Accept</button>
                    <button class="btn-outline-danger" onclick="refuseCredential(${index})">Refuse</button>
                </div>
            </div>
        `;
        container.appendChild(credDiv);
    });
}

// Show certificate details
function showCertificateDetails(index) {
    const cert = certificates[index];
    const detailsDiv = document.getElementById('certificate-details');

    // Extract data from certificate object
    const subjectName = cert.subject && cert.subject.name ? cert.subject.name : 'Unknown';
    const subjectId = cert.subject && cert.subject.id ? cert.subject.id : 'Unknown';
    const issuerName = cert.issuedBy && cert.issuedBy.name ? cert.issuedBy.name : 'Unknown';
    const issuerId = cert.issuedBy && cert.issuedBy.id ? cert.issuedBy.id : 'Unknown';
    const validSince = formatCertificateDate(cert.validSince, true);
    const validUntil = formatCertificateDate(cert.validUntil, true);
    const fingerprint = cert.publicKeyFingerprint || 'Not available';
    const connectionType = cert.connectionType || 'Unknown';
    const identityChecked = cert.identityChecked || 'Unknown';

    // Load trust level dynamically
    loadTrustLevelForDetails(subjectId);

    detailsDiv.innerHTML = `
        <div style="display: grid; gap: 16px;">
            <div>
                <strong>Subject Name:</strong> <span style="font-family:var(--font-mono)">${subjectName}</span>
            </div>
            <div>
                <strong>Subject ID:</strong> <span style="font-family:var(--font-mono); word-break: break-all;">${subjectId}</span>
            </div>
            <div>
                <strong>Issuer Name:</strong> ${issuerName}
            </div>
            <div>
                <strong>Issuer ID:</strong> <span style="font-family:var(--font-mono); word-break: break-all;">${issuerId}</span>
            </div>
            <div>
                <strong>Valid From:</strong> ${validSince}
            </div>
            <div>
                <strong>Valid Until:</strong> ${validUntil}
            </div>
            <div>
                <strong>Connection Type:</strong> ${connectionType}
            </div>
            <div>
                <strong>Identity Check:</strong> ${identityChecked}
            </div>
            <div>
                <strong>Public Key Fingerprint:</strong> <span style="font-family:var(--font-mono); word-break: break-all; font-size: 0.8rem;">${fingerprint}</span>
            </div>
            <div>
                <strong>Trust Level:</strong> <span class="badge" id="details-trust-badge">Loading...</span>
            </div>
        </div>
    `;

    document.getElementById('details-modal').style.display = 'block';
}

// Load trust level for certificate details (with caching)
async function loadTrustLevelForDetails(subjectId) {
    // Check cache first
    if (trustLevelCache.has(subjectId)) {
        updateDetailsTrustBadge(trustLevelCache.get(subjectId));
        return;
    }
    
    try {
        const response = await fetch(`/snm-webapp/api/pki/identityAssurance?subjectId=${encodeURIComponent(subjectId)}`);
        if (response.ok) {
            const data = await response.json();
            const trustLevel = data.identityAssuranceText || 'Unknown';
            const trustBadge = getTrustBadgeClass(data.identityAssurance);
            
            // Cache the result
            trustLevelCache.set(subjectId, {
                level: trustLevel,
                badgeClass: trustBadge,
                iaValue: data.identityAssurance
            });
            
            updateDetailsTrustBadge(trustLevelCache.get(subjectId));
        }
    } catch (error) {
        console.error('Error loading trust level for details:', error);
        // Cache error state
        trustLevelCache.set(subjectId, { level: 'Error', badgeClass: 'badge-gray', iaValue: null });
        updateDetailsTrustBadge(trustLevelCache.get(subjectId));
    }
}

// Update details trust badge UI
function updateDetailsTrustBadge(trustData) {
    const badgeElement = document.getElementById('details-trust-badge');
    if (badgeElement) {
        badgeElement.textContent = trustData.level;
        badgeElement.className = `badge ${trustData.badgeClass}`;
    }
}


// Helper to get badge class based on identity assurance level
function getTrustBadgeClass(ia) {
    if (ia === undefined || ia === null) return 'badge-gray';
    if (ia >= 10) return 'badge-green'; // perfect
    if (ia >= 8) return 'badge-green'; // good
    if (ia >= 4) return 'badge-yellow'; // enough?
    return 'badge-gray'; // bad/unknown
}

// Accept pending credential
async function acceptCredential(index) {
    try {
        const cred = pendingCredentials[index];
        // The backend expects the 'index' from the pending list (1-based) which is stored in cred.index
        const response = await fetch(`/snm-webapp/api/pki/pendingCredentials/accept?index=${cred.index}`, {
            method: 'POST'
        });

        if (response.ok) {
            // Clear cache since trust levels may change
            trustLevelCache.clear();
            
            await loadPendingCredentials();
            await loadCertificates();
            alert('Credential accepted successfully!');
        } else {
            const data = await response.json();
            throw new Error(data.msg || 'Failed to accept credential');
        }
    } catch (error) {
        console.error('Error accepting credential:', error);
        alert('Error accepting credential: ' + error.message);
    }
}

// Refuse pending credential
async function refuseCredential(index) {
    try {
        const cred = pendingCredentials[index];
        const response = await fetch(`/snm-webapp/api/pki/pendingCredentials/refuse?index=${cred.index}`, {
            method: 'POST'
        });

        if (response.ok) {
            await loadPendingCredentials();
            alert('Credential refused');
        } else {
            const data = await response.json();
            throw new Error(data.msg || 'Failed to refuse credential');
        }
    } catch (error) {
        console.error('Error refusing credential:', error);
        alert('Error refusing credential: ' + error.message);
    }
}

// Send credentials to another peer
async function sendCredentials() {
    const peerName = document.getElementById('import-peer-name').value.trim();
    // The backend does not use the message field, so we ignore it here or just log it.
    // const message = document.getElementById('import-message').value.trim();

    if (!peerName) {
        alert('Please enter a peer name or ID');
        return;
    }

    try {
        // We pass the name/ID as 'targetPeerId'. If it's a name, it might fail if backend expects ID.
        // But since we can't change backend, we try valid ID first.
        const response = await fetch(`/snm-webapp/api/pki/sendCredentials?targetPeerId=${encodeURIComponent(peerName)}`, {
            method: 'POST'
        });

        if (response.ok) {
            hideImportModal();
            alert('Credentials sent successfully!');
            document.getElementById('import-peer-name').value = '';
            document.getElementById('import-message').value = '';
        } else {
            const data = await response.json();
            throw new Error(data.msg || 'Failed to send credentials');
        }
    } catch (error) {
        console.error('Error sending credentials:', error);
        alert('Error sending credentials: ' + error.message);
    }
}

// Export own certificate
function exportOwnCertificate() {
    const peerId = document.getElementById('your-peer-id').textContent;
    if (peerId && peerId !== 'Loading...') {
        // Create a text area with the peer ID
        const textarea = document.createElement('textarea');
        textarea.value = `SharkNet Peer ID: ${peerId}`;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
        alert('Peer ID copied to clipboard!');
    } else {
        alert('Peer ID not available');
    }
}

// Revoke certificate (now fully implemented)
async function revokeCertificate(subjectId) {
    if (!confirm(`Are you sure you want to revoke certificate for ${subjectId}? This action cannot be undone.`)) {
        return;
    }

    try {
        // Updated to use query parameter to match backend req.getParameter()
        const response = await fetch(`/snm-webapp/api/pki/revokeCertificate?subjectId=${encodeURIComponent(subjectId)}`, {
            method: 'POST'
        });

        if (response.ok) {
            const data = await response.json();
            alert('Certificate revoked successfully!');
            
            // Clear cache and refresh
            trustLevelCache.clear();
            await loadCertificates(); // Refresh the certificate list
        } else {
            const data = await response.json();
            throw new Error(data.msg || 'Failed to revoke certificate');
        }
    } catch (error) {
        console.error('Error revoking certificate:', error);
        alert('Error revoking certificate: ' + error.message);
    }
}

// Refresh certificates (manual refresh)
function refreshCertificates() {
    // Clear cache to force fresh data
    trustLevelCache.clear();
    lastRefreshTime = 0; // Reset refresh timer
    
    loadCertificates();
    loadPendingCredentials();
}

// Filter certificates
function filterCertificates() {
    const searchTerm = document.getElementById('certificate-search').value.toLowerCase();
    const rows = document.querySelectorAll('#certificates-tbody tr');

    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

// Modal functions
function showImportModal() {
    document.getElementById('import-modal').classList.remove('hidden');
}

function hideImportModal() {
    document.getElementById('import-modal').classList.add('hidden');
}

function hideDetailsModal() {
    document.getElementById('details-modal').classList.add('hidden');
}

// Close modals when clicking outside
window.onclick = function (event) {
    const importModal = document.getElementById('import-modal');
    const detailsModal = document.getElementById('details-modal');
    const revokeModal = document.getElementById('revoke-modal');

    if (event.target === importModal) {
        hideImportModal();
    }
    if (event.target === detailsModal) {
        hideDetailsModal();
    }
    if (event.target === revokeModal) {
        hideRevokeModal();
    }
}

// Advanced Filtering Functions
function onFilterTypeChange() {
    const filterType = document.getElementById('filter-type').value;
    
    // Hide all filter sections
    document.getElementById('issuer-filter').style.display = 'none';
    document.getElementById('subject-filter').style.display = 'none';
    document.getElementById('trust-filter').style.display = 'none';
    
    // Show relevant filter section
    if (filterType === 'issuer') {
        document.getElementById('issuer-filter').style.display = 'block';
        loadIssuerOptions();
    } else if (filterType === 'subject') {
        document.getElementById('subject-filter').style.display = 'block';
        loadSubjectOptions();
    } else if (filterType === 'trust') {
        document.getElementById('trust-filter').style.display = 'block';
    }
}

async function loadIssuerOptions() {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) return;
        
        const data = await response.json();
        const select = document.getElementById('issuer-select');
        
        select.innerHTML = '<option value="">All Issuers</option>';
        
        if (data.persons && data.persons.length > 0) {
            data.persons.forEach(person => {
                const option = document.createElement('option');
                option.value = person.id;
                option.textContent = person.name || person.id;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading issuer options:', error);
    }
}

async function loadSubjectOptions() {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) return;
        
        const data = await response.json();
        const select = document.getElementById('subject-select');
        
        select.innerHTML = '<option value="">All Subjects</option>';
        
        if (data.persons && data.persons.length > 0) {
            data.persons.forEach(person => {
                const option = document.createElement('option');
                option.value = person.id;
                option.textContent = person.name || person.id;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading subject options:', error);
    }
}

async function applyFilter() {
    const filterType = document.getElementById('filter-type').value;
    
    if (filterType === 'all') {
        clearFilter();
        return;
    }
    
    let apiUrl = '/snm-webapp/api/pki/certificates';
    let params = new URLSearchParams();
    
    if (filterType === 'issuer') {
        apiUrl = '/snm-webapp/api/pki/certsByIssuer';
        const issuerId = document.getElementById('issuer-select').value;
        if (issuerId) params.append('issuerId', issuerId);
    } else if (filterType === 'subject') {
        apiUrl = '/snm-webapp/api/pki/certsBySubject';
        const subjectId = document.getElementById('subject-select').value;
        if (subjectId) params.append('subjectId', subjectId);
    } else if (filterType === 'trust') {
        filterByTrustLevel();
        return;
    }
    
    try {
        const url = params.toString() ? `${apiUrl}?${params.toString()}` : apiUrl;
        const response = await fetch(url);
        
        if (!response.ok) throw new Error('Failed to apply filter');
        
        const data = await response.json();
        certificates = data.certificates || [];
        displayCertificates();
        
        showFilterStatus(filterType);
        
    } catch (error) {
        console.error('Error applying filter:', error);
        alert('Failed to apply filter: ' + error.message);
    }
}

function filterByTrustLevel() {
    const trustLevel = document.getElementById('trust-select').value;
    
    if (!trustLevel) {
        displayCertificates();
        return;
    }
    
    const filtered = certificates.filter(cert => {
        return cert.trustLevel === parseInt(trustLevel);
    });
    
    displayFilteredCertificates(filtered);
    showFilterStatus('trust');
}

function displayFilteredCertificates(filteredCerts) {
    const tbody = document.getElementById('certificates-tbody');
    
    if (filteredCerts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading-state">No certificates found with current filter</td></tr>';
        return;
    }
    
    tbody.innerHTML = filteredCerts.map(cert => createCertificateRow(cert)).join('');
}

function clearFilter() {
    document.getElementById('filter-type').value = 'all';
    document.getElementById('issuer-filter').style.display = 'none';
    document.getElementById('subject-filter').style.display = 'none';
    document.getElementById('trust-filter').style.display = 'none';
    
    loadCertificates();
    hideFilterStatus();
}

function showFilterStatus(filterType) {
    hideFilterStatus();
    
    const status = document.createElement('span');
    status.className = 'filter-status active';
    status.textContent = `Filter: ${filterType.charAt(0).toUpperCase() + filterType.slice(1)}`;
    
    const header = document.querySelector('.trusted-section .card-title');
    if (header) {
        header.appendChild(status);
    }
}

function hideFilterStatus() {
    const existingStatus = document.querySelector('.filter-status');
    if (existingStatus) {
        existingStatus.remove();
    }
}

// Certificate Revocation Functions
function showRevokeModal(subjectId, subjectName) {
    document.getElementById('revoke-subject-id').value = subjectId;
    document.getElementById('revoke-subject-name').value = subjectName;
    document.getElementById('revoke-modal').classList.remove('hidden');
}

function hideRevokeModal() {
    document.getElementById('revoke-modal').classList.add('hidden');
    document.getElementById('revoke-subject-id').value = '';
    document.getElementById('revoke-subject-name').value = '';
}

async function revokeCertificate() {
    const subjectId = document.getElementById('revoke-subject-id').value;
    
    if (!subjectId) {
        alert('Subject ID is required for revocation');
        return;
    }
    
    if (!confirm('Are you sure you want to revoke this certificate? This action cannot be undone.')) {
        return;
    }
    
    try {
        const response = await fetch('/snm-webapp/api/pki/revokeCertificate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `subjectId=${encodeURIComponent(subjectId)}`
        });
        
        const result = await response.json();
        
        if (response.ok) {
            alert('Certificate revoked successfully!');
            hideRevokeModal();
            refreshCertificates();
        } else {
            alert('Failed to revoke certificate: ' + (result.msg || 'Unknown error'));
        }
        
    } catch (error) {
        console.error('Error revoking certificate:', error);
        alert('Error revoking certificate. Please try again.');
    }
}
