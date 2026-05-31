// Utility to escape HTML and prevent XSS
function escapeHtml(text) {
    if (!text) return '';
    return text.toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

async function loadContacts() {
    const tableBody = document.getElementById('contactsTableBody');
    tableBody.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Loading peers...</td></tr>';

    try {
        const response = await fetch('api/peer');
        const peers = await response.json();

        tableBody.innerHTML = '';

        if (peers.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">No peers found. Create one to get started.</td></tr>';
            return;
        }

        peers.forEach(peer => {
            const row = document.createElement('tr');
            row.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";

            const isPeerActive = peer.active;
            const statusText = isPeerActive ? 'Active' : 'Inactive';
            const statusClass = isPeerActive
                ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-400';

            const actionBtn = isPeerActive
                ? `<button class="px-3 py-1.5 text-xs bg-yellow-100 hover:bg-yellow-200 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400 dark:hover:bg-yellow-900/50 font-medium rounded transition-colors" onclick="stopPeer('${escapeHtml(peer.peerId)}')"><i class="fas fa-stop mr-1"></i> Stop</button>`
                : `<button class="px-3 py-1.5 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 dark:hover:bg-blue-900/50 font-medium rounded transition-colors" onclick="startPeer('${escapeHtml(peer.peerId)}')"><i class="fas fa-play mr-1"></i> Start</button>`;

            row.innerHTML = `
                <td class="px-6 py-4">
                    <span class="px-2.5 py-0.5 text-xs font-bold rounded-full ${statusClass}">${statusText}</span>
                </td>
                <td class="px-6 py-4">
                    <div class="font-bold text-gray-900 dark:text-white">${escapeHtml(peer.name) || 'Unknown'}</div>
                    <div class="text-xs text-gray-500 dark:text-gray-400 font-mono mt-1 max-w-[200px] truncate" title="${escapeHtml(peer.peerId)}">${escapeHtml(peer.peerId)}</div>
                </td>
                <td class="px-6 py-4 text-right">
                    <div class="flex justify-end gap-2">
                        ${actionBtn}
                        <button class="px-3 py-1.5 text-xs bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 font-medium rounded transition-colors" onclick="deletePeer('${escapeHtml(peer.peerId)}')">
                            <i class="fas fa-trash mr-1"></i> Delete
                        </button>
                    </div>
                </td>
            `;
            tableBody.appendChild(row);
        });
    } catch (err) {
        tableBody.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-red-500">Error loading data.</td></tr>';
    }
}

async function startPeer(id) {
    await fetch('api/start/' + id, {method: 'POST'});
    location.reload();
}

async function stopPeer(id) {
    await fetch('api/stop/' + id, {method: 'POST'});
    location.reload();
}

async function deletePeer(id) {
    if (confirm('Are you sure you want to delete this peer?')) {
        await fetch('api/peer', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({peerId: id})
        });
        location.reload();
    }
}

// --- Modal Functions for Creating New Peer ---

function showCreatePeerModal() {
    const modal = document.getElementById('create-peer-modal');
    if (modal) {
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        // Auto-focus input after modal opens
        setTimeout(() => {
            const input = document.getElementById('new-peer-name');
            if (input) input.focus();
        }, 100);
    }
}

function hideCreatePeerModal() {
    const modal = document.getElementById('create-peer-modal');
    if (modal) {
        modal.classList.add('hidden');
        modal.classList.remove('flex');

        // Clear input when closing
        const input = document.getElementById('new-peer-name');
        if (input) input.value = '';
    }
}

function submitNewPeer() {
    const nameInput = document.getElementById('new-peer-name');
    const name = nameInput ? nameInput.value.trim() : '';

    if (!name) {
        alert('Peer Name is required');
        if (nameInput) nameInput.focus();
        return;
    }

    fetch('api/peer', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({name: name})
    })
        .then(() => location.reload())
        .catch(err => alert("Error creating peer: " + err));
}

// Event Listeners Initialization
document.addEventListener('DOMContentLoaded', () => {
    loadContacts();

    // Listen for 'Enter' key in the modal input
    const peerInput = document.getElementById('new-peer-name');
    if (peerInput) {
        peerInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                submitNewPeer();
            }
        });
    }
});