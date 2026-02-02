// Global variables
let peers = [];
let selectedPeerId = null;

// Load existing peers on page load
document.addEventListener('DOMContentLoaded', function () {
    loadExistingPeers();
});

// Close dropdown when clicking outside
document.addEventListener('click', function (event) {
    const dropdown = document.getElementById('peer-dropdown-options');
    const dropdownContainer = document.querySelector('.custom-dropdown');

    if (dropdown && dropdownContainer && !dropdownContainer.contains(event.target)) {
        dropdown.classList.remove('show');
    }
});

function toggleDropdown() {
    const dropdown = document.getElementById('peer-dropdown-options');
    if (dropdown) {
        dropdown.classList.toggle('show');
        console.log('Dropdown toggled. Classes:', dropdown.className);
    } else {
        console.error('Dropdown element not found!');
    }
}

function loadExistingPeers() {
    console.log('Loading existing peers...');
    fetch('/snm-webapp/api/peer')
        .then(response => {
            console.log('Response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('Peers data received:', data);
            peers = data; // Assign to global variable
            updatePeerDropdown(); // No arguments needed, uses global variable
        })
        .catch(error => {
            console.error('Error loading peers:', error);
            // Don't show error immediately to avoid alarming user if backend is just starting
            console.warn('Failed to load existing peers (backend might be warming up)');
        });
}

function updatePeerDropdown() {
    const optionsContainer = document.getElementById('peer-dropdown-options');
    if (!optionsContainer) return;

    optionsContainer.innerHTML = '';

    if (!peers || !Array.isArray(peers) || peers.length === 0) {
        const noPeersOption = document.createElement('div');
        noPeersOption.className = 'dropdown-option';
        noPeersOption.textContent = '-- No peers available --';
        noPeersOption.style.color = '#6b7280';
        noPeersOption.style.cursor = 'default';
        optionsContainer.appendChild(noPeersOption);
        return;
    }

    peers.forEach((peer, index) => {
        const option = document.createElement('div');
        option.className = 'dropdown-option';

        // Use peer.name directly with fallback
        const displayName = peer.name || peer.peerId || 'Unnamed Peer';
        const activeText = peer.active ? ' (Active)' : '';
        const fullText = displayName + activeText;

        option.textContent = fullText;

        option.onclick = function () {
            selectPeerFromDropdown(peer.peerId, displayName);
        };
        optionsContainer.appendChild(option);
    });
    console.log('Dropdown updated. Options count:', optionsContainer.children.length);
}

function selectPeerFromDropdown(peerId, peerName) {
    selectedPeerId = peerId;
    document.getElementById('selected-peer-text').textContent = peerName;
    document.getElementById('peer-dropdown-options').classList.remove('show');
}

function selectExistingPeer() {
    if (!selectedPeerId) {
        showError('Please select a peer');
        return;
    }

    showLoading(true);

    // Start the selected peer
    fetch(`/snm-webapp/api/start/${encodeURIComponent(selectedPeerId)}`, {
        method: 'POST'
    })
        .then(response => {
            if (response.ok) {
                showSuccess('Peer activated successfully! Redirecting...');
                setTimeout(() => {
                    window.location.href = '/snm-webapp/';
                }, 1500);
            } else {
                throw new Error('Failed to activate peer');
            }
        })
        .catch(error => {
            console.error('Error activating peer:', error);
            showError('Failed to activate peer. Please try again.');
            showLoading(false);
        });
}

function createNewPeer() {
    const peerName = document.getElementById('peer-name').value.trim();

    if (!peerName) {
        showError('Please enter a peer name');
        return;
    }

    if (peerName.length < 2) {
        showError('Peer name must be at least 2 characters');
        return;
    }

    showLoading(true);

    fetch('/snm-webapp/api/peer', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            name: peerName
        })
    })
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error('Failed to create peer');
            }
        })
        .then(data => {
            showSuccess('Peer created successfully! Redirecting...');
            setTimeout(() => {
                window.location.href = '/snm-webapp/';
            }, 1500);
        })
        .catch(error => {
            console.error('Error creating peer:', error);
            showError('Failed to create peer. Please try again.');
            showLoading(false);
        });
}

function refreshPeers() {
    loadExistingPeers();
    showSuccess('Peer list refreshed!');
}

function showError(message) {
    const errorDiv = document.getElementById('error-message');
    if (errorDiv) {
        errorDiv.textContent = message;
        errorDiv.style.display = 'block';
        const successDiv = document.getElementById('success-message');
        if (successDiv) successDiv.style.display = 'none';

        setTimeout(() => {
            errorDiv.style.display = 'none';
        }, 5000);
    }
}

function showSuccess(message) {
    const successDiv = document.getElementById('success-message');
    if (successDiv) {
        successDiv.textContent = message;
        successDiv.style.display = 'block';
        const errorDiv = document.getElementById('error-message');
        if (errorDiv) errorDiv.style.display = 'none';

        setTimeout(() => {
            successDiv.style.display = 'none';
        }, 3000);
    }
}

function showLoading(show) {
    const loadingDiv = document.getElementById('loading');
    const forms = document.querySelectorAll('.login-form');

    if (show) {
        if (loadingDiv) loadingDiv.style.display = 'block';
        forms.forEach(form => form.style.display = 'none');
    } else {
        if (loadingDiv) loadingDiv.style.display = 'none';
        forms.forEach(form => form.style.display = 'block');
    }
}
