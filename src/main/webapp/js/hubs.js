// hubs.js - Hub Connection Management

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
        tbody.innerHTML = `<tr><td colspan="4" style="text-align:center; color:var(--text-muted);">No active peer selected.</td></tr>`;
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
                tr.innerHTML = `
                <td style="font-family:var(--font-mono);">localhost</td>
                <td>${port}</td>
                <td><span class="badge badge-green">Listening</span></td>
                <td><button class="btn-secondary"
                    style="color:var(--red);border-color:var(--red);padding:4px 8px;font-size:0.8rem;"
                    onclick="closePort(${port})">Close</button></td>`;
                tbody.appendChild(tr);
            });

            connections.forEach(conn => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                <td style="font-family:var(--font-mono);">${conn.remoteAddress}</td>
                <td>${conn.remotePort}</td>
                <td><span class="badge badge-green">Connected</span></td>
                <td><button class="btn-secondary"
                    style="color:var(--red);border-color:var(--red);padding:4px 8px;font-size:0.8rem;"
                    onclick="closePort(${conn.remotePort})">Disconnect</button></td>`;
                tbody.appendChild(tr);
            });

            if (openPorts.length === 0 && connections.length === 0) {
                tbody.innerHTML = `<tr><td colspan="4" style="text-align:center; color:var(--text-muted);">No active connections.</td></tr>`;
            }
        })
        .catch(err => {
            console.error('loadActiveHubs error:', err);
            tbody.innerHTML = `<tr><td colspan="4" style="text-align:center; color:red;">Failed to load connections.</td></tr>`;
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

// Show message
function showMessage(type, text) {
    const isError = type === 'error';
    let el = document.getElementById('hub-msg');
    if (!el) {
        el = document.createElement('div');
        el.id = 'hub-msg';
        const pageHeader = document.querySelector('.page-header');
        if (pageHeader) pageHeader.insertAdjacentElement('afterend', el);
    }
    el.style.cssText = `padding:10px 16px; margin:10px 0; border-radius:6px; font-size:0.9rem;
        background:${isError ? '#fef2f2' : '#f0fdf4'};
        color:${isError ? '#dc2626' : '#16a34a'};
        border:1px solid ${isError ? '#fecaca' : '#bbf7d0'};`;
    el.textContent = text;
    el.style.display = 'block';
    clearTimeout(el._timer);
    el._timer = setTimeout(() => el.style.display = 'none', isError ? 5000 : 3000);
}

// Auto-refresh every 15 seconds
setInterval(() => {
    if (getActivePeerId()) loadActiveHubs();
}, 15000);
window.addEventListener('peerReady', () => loadActiveHubs());
