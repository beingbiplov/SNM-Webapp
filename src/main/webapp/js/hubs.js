// hubs.js - Hub Connection Management (Tailwind CSS Updated)

document.addEventListener('DOMContentLoaded', () => {
    loadActiveHubs();
});

function getActivePeerId() {
    return window.currentActivePeerId || null;
}

// Connect to a remote peer via TCP
async function connectNewHub() {
    const address = document.getElementById('hubAddress').value.trim();
    const portVal = document.getElementById('hubPort').value.trim();
    const peerId = getActivePeerId();

    if (!address || !portVal) {
        showMessage('error', 'Please enter both Hub Address and Port.');
        return;
    }
    if (!peerId) {
        showMessage('error', 'No active peer. Please select a peer first.');
        return;
    }

    const port = parseInt(portVal);
    if (isNaN(port)) {
        showMessage('error', 'Port must be a number.');
        return;
    }

    try {
        const res = await fetch('/snm-webapp/api/tcp/connect', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({peerId, host: address, port})
        });
        const data = await res.json();
        if (res.ok) {
            showMessage('success', `Connected to ${address}:${port}`);
            document.getElementById('hubAddress').value = '';
            document.getElementById('hubPort').value = '';
            loadActiveHubs();
        } else {
            showMessage('error', data.msg || 'Failed to connect.');
        }
    } catch (err) {
        showMessage('error', 'Network error. Could not reach server.');
        console.error(err);
    }
}

// Open a local TCP port
async function openLocalPort() {
    const portVal = document.getElementById('openPort').value.trim();
    const peerId = getActivePeerId();

    if (!portVal) {
        showMessage('error', 'Please enter a port number.');
        return;
    }
    if (!peerId) {
        showMessage('error', 'No active peer. Please select a peer first.');
        return;
    }

    const port = parseInt(portVal);
    if (isNaN(port)) {
        showMessage('error', 'Port must be a number.');
        return;
    }

    try {
        const res = await fetch('/snm-webapp/api/tcp/open', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({peerId, port})
        });
        const data = await res.json();
        if (res.ok) {
            showMessage('success', `Port ${port} opened successfully.`);
            document.getElementById('openPort').value = '';
            loadActiveHubs();
        } else {
            showMessage('error', data.msg || 'Failed to open port.');
        }
    } catch (err) {
        showMessage('error', 'Network error. Could not reach server.');
        console.error(err);
    }
}

// List open ports and active connections
function loadActiveHubs() {
    const peerId = getActivePeerId();
    const tbody = document.getElementById('active-hubs-list');
    if (!tbody) return;

    if (!peerId) {
        tbody.innerHTML = `<tr><td colspan="4" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">No active peer selected.</td></tr>`;
        return;
    }

    fetch('/snm-webapp/api/tcp/list', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({peerId})
    })
        .then(res => {
            if (!res.ok) throw new Error('Server error: ' + res.status);
            return res.json();
        })
        .then(data => {
            tbody.innerHTML = '';
            const openPorts = data.openPorts || [];
            const connections = data.connections || [];

            openPorts.forEach(port => {
                const tr = document.createElement('tr');
                tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                tr.innerHTML = `
                <td class="px-6 py-4 font-mono font-medium text-gray-900 dark:text-white">localhost</td>
                <td class="px-6 py-4 font-mono text-gray-600 dark:text-gray-300">${port}</td>
                <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">Listening</span></td>
                <td class="px-6 py-4 text-right">
                    <button class="px-3 py-1.5 text-xs bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 rounded transition-colors font-medium" onclick="closePort(${port})">Close</button>
                </td>`;
                tbody.appendChild(tr);
            });

            connections.forEach(conn => {
                const tr = document.createElement('tr');
                tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                tr.innerHTML = `
                <td class="px-6 py-4 font-mono font-medium text-gray-900 dark:text-white">${escapeHtml(conn.remoteAddress)}</td>
                <td class="px-6 py-4 font-mono text-gray-600 dark:text-gray-300">${conn.remotePort}</td>
                <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-bold rounded-full">Connected</span></td>
                <td class="px-6 py-4 text-right">
                    <button class="px-3 py-1.5 text-xs bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 rounded transition-colors font-medium" onclick="closePort(${conn.remotePort})">Disconnect</button>
                </td>`;
                tbody.appendChild(tr);
            });

            if (openPorts.length === 0 && connections.length === 0) {
                tbody.innerHTML = `<tr><td colspan="4" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">No active connections.</td></tr>`;
            }
        })
        .catch(err => {
            console.error('loadActiveHubs error:', err);
            tbody.innerHTML = `<tr><td colspan="4" class="px-6 py-8 text-center text-red-500">Failed to load connections.</td></tr>`;
        });
}

// Close a local TCP port
async function closePort(port) {
    const peerId = getActivePeerId();
    if (!confirm(`Close port ${port}?`)) return;

    try {
        const res = await fetch('/snm-webapp/api/tcp/close', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({peerId, port})
        });
        const data = await res.json();
        showMessage(res.ok ? 'success' : 'error', data.msg || `Port ${port} closed.`);
        loadActiveHubs();
    } catch (err) {
        showMessage('error', 'Failed to close port.');
        console.error(err);
    }
}

// Show message using Tailwind classes
function showMessage(type, text) {
    const isError = type === 'error';
    let container = document.getElementById('msg-container');

    if (!container) return; // Failsafe

    let el = document.getElementById('hub-msg');
    if (!el) {
        el = document.createElement('div');
        el.id = 'hub-msg';
        container.appendChild(el);
    }

    // Tailwind classes for success/error alerts
    const baseClasses = "p-4 mb-4 text-sm rounded-lg border flex items-center gap-2 shadow-sm transition-opacity duration-300";
    const errorClasses = "text-red-800 border-red-300 bg-red-50 dark:bg-red-900/20 dark:text-red-400 dark:border-red-800";
    const successClasses = "text-green-800 border-green-300 bg-green-50 dark:bg-green-900/20 dark:text-green-400 dark:border-green-800";

    const icon = isError ? '<i class="fas fa-exclamation-circle"></i>' : '<i class="fas fa-check-circle"></i>';

    el.className = `${baseClasses} ${isError ? errorClasses : successClasses}`;
    el.innerHTML = `${icon} <span>${escapeHtml(text)}</span>`;
    el.style.display = 'flex';

    clearTimeout(el._timer);
    el._timer = setTimeout(() => el.style.display = 'none', isError ? 5000 : 3000);
}

// Utility to prevent XSS
function escapeHtml(text) {
    if (!text) return '';
    return text.toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Auto-refresh every 15 seconds
setInterval(() => {
    if (getActivePeerId()) loadActiveHubs();
}, 15000);
window.addEventListener('peerReady', () => loadActiveHubs());