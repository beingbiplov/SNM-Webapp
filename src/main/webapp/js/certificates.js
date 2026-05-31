/**
 * certificates.js - Certificate Management JavaScript
 * Fully Updated to support Tailwind CSS and Mobile Responsiveness.
 */

let certificates = [];
let pendingCredentials = [];
let trustLevelCache = new Map();
let lastRefreshTime = 0;
const REFRESH_INTERVAL = 15000;

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

    if (/^\-?\d+$/.test(str)) {
        date = new Date(Number(str));
    } else {
        date = new Date(str);
        if (isNaN(date.getTime())) {
            const scrubbed = str.replace(/\s[A-Z]{3,4}\s/, ' ');
            date = new Date(scrubbed);
        }
    }

    if (isNaN(date.getTime())) return 'Unknown';

    try {
        const options = withTime ?
            {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit'} :
            {day: '2-digit', month: '2-digit', year: 'numeric'};
        return date.toLocaleDateString(undefined, options);
    } catch (e) {
        return 'Unknown';
    }
}

function escapeHtml(text) {
    if (!text) return '';
    return text.toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

document.addEventListener('DOMContentLoaded', function () {
    loadCertificates();
    loadPendingCredentials();
    loadOwnCertificate();

    setInterval(() => {
        const importModal = document.getElementById('import-modal');
        const detailsModal = document.getElementById('details-modal');
        const revokeModal = document.getElementById('revoke-modal');
        const now = Date.now();

        const isAnyModalOpen = (!importModal.classList.contains('hidden')) ||
            (!detailsModal.classList.contains('hidden')) ||
            (!revokeModal.classList.contains('hidden'));

        if (!isAnyModalOpen && (now - lastRefreshTime >= REFRESH_INTERVAL)) {
            lastRefreshTime = now;
            refreshDataSilently();
        }
    }, 5000);
});

async function refreshDataSilently() {
    try {
        await loadPendingCredentials();
        await loadCertificates(true);
    } catch (error) {
        console.error('Silent refresh error:', error);
    }
}

function refreshCertificates() {
    trustLevelCache.clear();
    lastRefreshTime = 0;
    loadCertificates();
    loadPendingCredentials();
}

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

async function loadCertificates(silent = false) {
    const tbody = document.getElementById('certificates-tbody');
    if (!silent) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Loading certificates...</td></tr>';
    }

    try {
        const peersResponse = await fetch('/snm-webapp/api/peer');
        if (!peersResponse.ok) throw new Error('Peers API not OK');

        const peers = await peersResponse.json();
        const activePeer = peers.find(p => p.active);

        if (!activePeer) {
            if (!silent) tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">No active peer found - Please login first.</td></tr>';
            return;
        }

        const certResponse = await fetch(`/snm-webapp/api/pki/certificates?peerId=${encodeURIComponent(activePeer.peerId)}`);
        if (!certResponse.ok) throw new Error('Certificate API not OK');

        const certData = await certResponse.json();
        certificates = certData.certificates || [];
        displayCertificates();

    } catch (error) {
        if (!silent) {
            tbody.innerHTML = `<tr><td colspan="5" class="px-6 py-8 text-center text-red-500">Error: ${escapeHtml(error.message)}</td></tr>`;
        }
    }
}

function displayCertificates() {
    const tbody = document.getElementById('certificates-tbody');

    if (certificates.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">No certificates found</td></tr>';
        return;
    }

    tbody.innerHTML = '';
    certificates.forEach((cert, index) => {
        const subjectName = escapeHtml(cert.subject?.name || 'Unknown');
        const subjectId = escapeHtml(cert.subject?.id || 'Unknown');
        const issuerName = escapeHtml(cert.issuedBy?.name || 'Unknown');
        const issuerId = escapeHtml(cert.issuedBy?.id || 'Unknown');
        const validUntil = formatCertificateDate(cert.validUntil, false);

        const row = document.createElement('tr');
        row.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";

        row.innerHTML = `
            <td class="px-6 py-4">
                <div class="font-bold text-gray-900 dark:text-white">${subjectName}</div>
                <div class="font-mono text-xs text-gray-500 dark:text-gray-400 truncate max-w-[120px] sm:max-w-[150px]" title="${subjectId}">${subjectId}</div>
            </td>
            <td class="px-6 py-4">
                <div class="font-medium text-gray-900 dark:text-gray-300">${issuerName}</div>
                <div class="font-mono text-xs text-gray-500 dark:text-gray-400 truncate max-w-[120px] sm:max-w-[150px]" title="${issuerId}">${issuerId}</div>
            </td>
            <td class="px-6 py-4 text-gray-700 dark:text-gray-300 text-sm whitespace-nowrap">${validUntil}</td>
            <td class="px-6 py-4 text-center">
                <span class="px-2.5 py-0.5 text-xs font-bold rounded-full bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400 whitespace-nowrap" id="trust-badge-${index}">
                    Loading...
                </span>
            </td>
            <td class="px-6 py-4 text-right">
                <div class="flex justify-end gap-2">
                    <button class="px-3 py-1.5 text-xs bg-gray-200 hover:bg-gray-300 dark:bg-gray-600 dark:hover:bg-gray-500 rounded transition-colors font-medium text-gray-800 dark:text-gray-200" onclick="showCertificateDetails(${index})">Details</button>
                    <button class="px-3 py-1.5 text-xs bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 rounded transition-colors font-medium" onclick="showRevokeModal('${subjectId}', '${subjectName}')">Revoke</button>
                </div>
            </td>
        `;
        tbody.appendChild(row);
        loadTrustLevel(index, subjectId);
    });
}

async function loadTrustLevel(index, subjectId) {
    if (trustLevelCache.has(subjectId)) {
        updateTrustBadge(index, trustLevelCache.get(subjectId));
        return;
    }

    try {
        const response = await fetch(`/snm-webapp/api/pki/identityAssurance?subjectId=${encodeURIComponent(subjectId)}`);
        if (response.ok) {
            const data = await response.json();
            const trustLevel = data.identityAssuranceText || data.identityAssurance || 'Unknown';
            const trustBadge = getTrustBadgeTailwindClass(data.identityAssurance);

            trustLevelCache.set(subjectId, {level: trustLevel, badgeClass: trustBadge});
            updateTrustBadge(index, trustLevelCache.get(subjectId));
        }
    } catch (error) {
        trustLevelCache.set(subjectId, {
            level: 'Error',
            badgeClass: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
        });
        updateTrustBadge(index, trustLevelCache.get(subjectId));
    }
}

function updateTrustBadge(index, trustData) {
    const badgeEl = document.getElementById(`trust-badge-${index}`);
    if (badgeEl) {
        badgeEl.textContent = trustData.level;
        badgeEl.className = `px-2.5 py-0.5 text-xs font-bold rounded-full whitespace-nowrap ${trustData.badgeClass}`;
    }
}

function getTrustBadgeTailwindClass(ia) {
    if (ia === undefined || ia === null) return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400';
    if (ia >= 8) return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400';
    if (ia >= 4) return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-500';
    return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400';
}

async function loadPendingCredentials() {
    try {
        const response = await fetch('/snm-webapp/api/pki/pendingCredentials');
        if (response.ok) {
            const data = await response.json();
            pendingCredentials = data.pendingCredentials || [];
            displayPendingCredentials();
        }
    } catch (error) {
        console.error('Error loading pending credentials:', error);
    }
}

function displayPendingCredentials() {
    const container = document.getElementById('pending-credentials-container');
    const countBadge = document.getElementById('pending-count');

    countBadge.textContent = pendingCredentials.length;

    if (pendingCredentials.length === 0) {
        container.innerHTML = '<div class="text-gray-500 dark:text-gray-400 text-sm italic py-4 text-center border border-dashed border-gray-300 dark:border-gray-700 rounded-lg">No pending credential requests</div>';
        return;
    }

    container.innerHTML = '';
    pendingCredentials.forEach((cred, index) => {
        const sender = escapeHtml(cred.credential?.name || cred.credential?.id || 'Unknown Sender');

        const credDiv = document.createElement('div');
        credDiv.className = 'flex flex-col sm:flex-row justify-between items-start sm:items-center p-4 border border-gray-200 dark:border-gray-700 rounded-lg bg-gray-50 dark:bg-gray-800/50 gap-4';

        credDiv.innerHTML = `
            <div class="w-full">
                <div class="font-bold text-gray-900 dark:text-white break-all">${sender}</div>
                <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">Standard Credential Request</div>
            </div>
            <div class="flex gap-2 w-full sm:w-auto">
                <button class="flex-1 sm:flex-none bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors" onclick="acceptCredential(${index})">Accept</button>
                <button class="flex-1 sm:flex-none bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 px-4 py-2 rounded-lg text-sm font-medium transition-colors" onclick="refuseCredential(${index})">Refuse</button>
            </div>
        `;
        container.appendChild(credDiv);
    });
}

async function acceptCredential(index) {
    try {
        const cred = pendingCredentials[index];
        const response = await fetch(`/snm-webapp/api/pki/pendingCredentials/accept?index=${cred.index}`, {method: 'POST'});
        if (response.ok) {
            trustLevelCache.clear();
            await loadPendingCredentials();
            await loadCertificates();
        } else {
            throw new Error('Failed to accept credential');
        }
    } catch (error) {
        alert('Error accepting credential: ' + error.message);
    }
}

async function refuseCredential(index) {
    try {
        const cred = pendingCredentials[index];
        const response = await fetch(`/snm-webapp/api/pki/pendingCredentials/refuse?index=${cred.index}`, {method: 'POST'});
        if (response.ok) {
            await loadPendingCredentials();
        } else {
            throw new Error('Failed to refuse credential');
        }
    } catch (error) {
        alert('Error refusing credential: ' + error.message);
    }
}

// --- Action Modals ---

function showCertificateDetails(index) {
    const cert = certificates[index];
    const detailsDiv = document.getElementById('certificate-details');

    const subjectName = escapeHtml(cert.subject?.name || 'Unknown');
    const subjectId = escapeHtml(cert.subject?.id || 'Unknown');
    const issuerName = escapeHtml(cert.issuedBy?.name || 'Unknown');
    const issuerId = escapeHtml(cert.issuedBy?.id || 'Unknown');
    const validSince = formatCertificateDate(cert.validSince, true);
    const validUntil = formatCertificateDate(cert.validUntil, true);
    const fingerprint = escapeHtml(cert.publicKeyFingerprint || 'Not available');

    // Using grid & break-all to ensure long hashes don't break the modal width on mobile
    detailsDiv.innerHTML = `
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-4 gap-x-6 w-full">
            <div class="w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Subject Name</span>
                <div class="font-medium text-gray-900 dark:text-white break-all">${subjectName}</div>
            </div>
            <div class="w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Subject ID</span>
                <div class="font-mono text-xs break-all bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-300 p-2 rounded border border-gray-200 dark:border-gray-700">${subjectId}</div>
            </div>
            <div class="w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Issuer Name</span>
                <div class="font-medium text-gray-900 dark:text-white break-all">${issuerName}</div>
            </div>
            <div class="w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Issuer ID</span>
                <div class="font-mono text-xs break-all bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-300 p-2 rounded border border-gray-200 dark:border-gray-700">${issuerId}</div>
            </div>
            <div class="w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Valid From</span>
                <div class="text-gray-900 dark:text-white">${validSince}</div>
            </div>
            <div class="w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Valid Until</span>
                <div class="text-gray-900 dark:text-white">${validUntil}</div>
            </div>
            <div class="sm:col-span-2 w-full">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Public Key Fingerprint</span>
                <div class="font-mono text-xs break-all bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-300 p-2.5 rounded border border-gray-200 dark:border-gray-700">${fingerprint}</div>
            </div>
        </div>
    `;

    document.getElementById('details-modal').classList.remove('hidden');
}

function exportOwnCertificate() {
    const peerId = document.getElementById('your-peer-id').textContent;
    if (peerId && peerId !== 'Loading...') {
        navigator.clipboard.writeText(`SharkNet Peer ID: ${peerId}`).then(() => {
            alert('Peer ID copied to clipboard!');
        });
    }
}

async function sendCredentials() {
    const peerName = document.getElementById('import-peer-name').value.trim();
    try {
        const response = await fetch(`/snm-webapp/api/pki/sendCredentials?targetPeerId=${encodeURIComponent(peerName)}`, {method: 'POST'});
        if (response.ok) {
            hideImportModal();
            document.getElementById('import-peer-name').value = '';
            document.getElementById('import-message').value = '';
            alert('Credentials sent successfully!');
        } else {
            throw new Error('Failed to send credentials');
        }
    } catch (error) {
        alert('Error sending credentials: ' + error.message);
    }
}

async function revokeCertificate() {
    const subjectId = document.getElementById('revoke-subject-id').value;
    try {
        const response = await fetch(`/snm-webapp/api/pki/revokeCertificate?subjectId=${encodeURIComponent(subjectId)}`, {method: 'POST'});
        if (response.ok) {
            hideRevokeModal();
            trustLevelCache.clear();
            await loadCertificates();
        } else {
            throw new Error('Failed to revoke certificate');
        }
    } catch (error) {
        alert('Error revoking certificate: ' + error.message);
    }
}

// --- Filtering logic ---

function filterCertificates() {
    const searchTerm = document.getElementById('certificate-search').value.toLowerCase();
    const rows = document.querySelectorAll('#certificates-tbody tr');

    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

function onFilterTypeChange() {
    const type = document.getElementById('filter-type').value;

    document.getElementById('issuer-filter').classList.add('hidden');
    document.getElementById('subject-filter').classList.add('hidden');
    document.getElementById('trust-filter').classList.add('hidden');

    if (type === 'issuer') {
        document.getElementById('issuer-filter').classList.remove('hidden');
        loadDropdownOptions('issuer-select');
    } else if (type === 'subject') {
        document.getElementById('subject-filter').classList.remove('hidden');
        loadDropdownOptions('subject-select');
    } else if (type === 'trust') {
        document.getElementById('trust-filter').classList.remove('hidden');
    }
}

async function loadDropdownOptions(elementId) {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) return;
        const data = await response.json();
        const select = document.getElementById(elementId);

        select.innerHTML = `<option value="">All ${elementId.includes('issuer') ? 'Issuers' : 'Subjects'}</option>`;
        if (data.persons) {
            data.persons.forEach(p => {
                select.innerHTML += `<option value="${escapeHtml(p.id)}">${escapeHtml(p.name || p.id)}</option>`;
            });
        }
    } catch (e) {
        console.error('Dropdown load error', e);
    }
}

async function applyFilter() {
    const type = document.getElementById('filter-type').value;
    if (type === 'all') {
        clearFilter();
        return;
    }

    let url = '/snm-webapp/api/pki/certificates';
    let params = new URLSearchParams();

    if (type === 'issuer') {
        url = '/snm-webapp/api/pki/certsByIssuer';
        const val = document.getElementById('issuer-select').value;
        if (val) params.append('issuerId', val);
    } else if (type === 'subject') {
        url = '/snm-webapp/api/pki/certsBySubject';
        const val = document.getElementById('subject-select').value;
        if (val) params.append('subjectId', val);
    }

    try {
        const response = await fetch(params.toString() ? `${url}?${params.toString()}` : url);
        if (!response.ok) throw new Error('Filter failed');
        const data = await response.json();
        certificates = data.certificates || [];
        displayCertificates();
    } catch (e) {
        console.error(e);
    }
}

function clearFilter() {
    document.getElementById('filter-type').value = 'all';
    onFilterTypeChange();
    loadCertificates();
}

// --- Modal Display Toggles ---

function showImportModal() {
    document.getElementById('import-modal').classList.remove('hidden');
}

function hideImportModal() {
    document.getElementById('import-modal').classList.add('hidden');
}

function hideDetailsModal() {
    document.getElementById('details-modal').classList.add('hidden');
}

function showRevokeModal(id, name) {
    document.getElementById('revoke-subject-id').value = id;
    document.getElementById('revoke-subject-name').value = name;
    document.getElementById('revoke-modal').classList.remove('hidden');
}

function hideRevokeModal() {
    document.getElementById('revoke-modal').classList.add('hidden');
    document.getElementById('revoke-subject-id').value = '';
    document.getElementById('revoke-subject-name').value = '';
}

window.onclick = function (event) {
    if (event.target === document.getElementById('import-modal')) hideImportModal();
    if (event.target === document.getElementById('details-modal')) hideDetailsModal();
    if (event.target === document.getElementById('revoke-modal')) hideRevokeModal();
}