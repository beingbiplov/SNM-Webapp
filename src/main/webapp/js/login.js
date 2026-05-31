/**
 * login.js - Handles Authentication, Peer Selection, and Creation
 * Updated for Tailwind CSS UI integration
 */

let peers = [];
let selectedPeerId = null;

// Initialize and load existing peers on page load
document.addEventListener('DOMContentLoaded', function () {
    loadExistingPeers();
});

// Close dropdown when clicking outside of it
document.addEventListener('click', function (event) {
    const dropdown = document.getElementById('peer-dropdown-options');
    const dropdownContainer = document.querySelector('.custom-dropdown');
    const arrow = document.getElementById('dropdown-arrow');

    if (dropdown && !dropdown.classList.contains('hidden') && dropdownContainer && !dropdownContainer.contains(event.target)) {
        dropdown.classList.add('hidden');
        if (arrow) arrow.classList.remove('rotate-180');
    }
});

/**
 * Toggles the visibility of the custom dropdown menu
 */
function toggleDropdown() {
    const dropdown = document.getElementById('peer-dropdown-options');
    const arrow = document.getElementById('dropdown-arrow');

    if (dropdown) {
        dropdown.classList.toggle('hidden');
        if (arrow) arrow.classList.toggle('rotate-180');
    }
}

/**
 * Fetches the list of peers from the backend API
 */
function loadExistingPeers() {
    console.log('Loading existing peers...');
    fetch('/snm-webapp/api/peer')
        .then(response => response.json())
        .then(data => {
            peers = data;
            updatePeerDropdown();
        })
        .catch(error => {
            console.error('Error loading peers:', error);
            console.warn('Failed to load existing peers (backend might be warming up)');
        });
}

/**
 * Populates the dropdown menu with fetched peers using Tailwind classes
 */
function updatePeerDropdown() {
    const optionsContainer = document.getElementById('peer-dropdown-options');
    if (!optionsContainer) return;

    optionsContainer.innerHTML = '';

    if (!peers || !Array.isArray(peers) || peers.length === 0) {
        const noPeersOption = document.createElement('div');
        noPeersOption.className = 'px-4 py-3 text-sm text-gray-500 dark:text-gray-400 cursor-default text-center italic';
        noPeersOption.textContent = '-- No peers available --';
        optionsContainer.appendChild(noPeersOption);
        return;
    }

    peers.forEach((peer) => {
        const option = document.createElement('div');
        // Tailwind classes for dropdown items
        option.className = 'px-4 py-3 text-sm cursor-pointer border-b border-gray-100 dark:border-dark-border last:border-0 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-900 dark:text-white transition-colors flex justify-between items-center';

        const displayName = peer.name || peer.peerId || 'Unnamed Peer';
        const activeBadge = peer.active ? '<span class="px-2 py-0.5 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 text-[10px] uppercase font-bold rounded-full">Active</span>' : '';

        option.innerHTML = `<span class="truncate pr-2">${escapeHtml(displayName)}</span> ${activeBadge}`;

        option.onclick = function () {
            selectPeerFromDropdown(peer.peerId, displayName);
        };
        optionsContainer.appendChild(option);
    });
}

/**
 * Handles the selection of a peer from the dropdown
 */
function selectPeerFromDropdown(peerId, peerName) {
    selectedPeerId = peerId;
    document.getElementById('selected-peer-text').textContent = peerName;
    document.getElementById('peer-dropdown-options').classList.add('hidden');

    const arrow = document.getElementById('dropdown-arrow');
    if (arrow) arrow.classList.remove('rotate-180');
}

/**
 * Activates the selected existing peer
 */
function selectExistingPeer() {
    if (!selectedPeerId) {
        showError('Please select a peer from the list first.');
        return;
    }

    showLoading(true);

    fetch(`/snm-webapp/api/start/${encodeURIComponent(selectedPeerId)}`, { method: 'POST' })
        .then(response => {
            if (response.ok) {
                showSuccess('Peer activated successfully! Redirecting...');
                setTimeout(() => { window.location.href = '/snm-webapp/'; }, 1000);
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

/**
 * Creates a new peer instance
 */
function createNewPeer() {
    const peerName = document.getElementById('peer-name').value.trim();

    if (!peerName) {
        showError('Please enter a peer name.');
        return;
    }

    if (peerName.length < 2) {
        showError('Peer name must be at least 2 characters long.');
        return;
    }

    showLoading(true);

    fetch('/snm-webapp/api/peer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: peerName })
    })
        .then(response => {
            if (response.ok) return response.json();
            throw new Error('Failed to create peer');
        })
        .then(() => {
            showSuccess('Peer created successfully! Redirecting...');
            setTimeout(() => { window.location.href = '/snm-webapp/'; }, 1000);
        })
        .catch(error => {
            console.error('Error creating peer:', error);
            showError('Failed to create peer. Please try again.');
            showLoading(false);
        });
}

/**
 * Refreshes the peer list manually
 */
function refreshPeers() {
    loadExistingPeers();
    showSuccess('Peer list refreshed successfully!');
}

/**
 * Displays an error message using Tailwind styling
 */
function showError(message) {
    const errorDiv = document.getElementById('error-message');
    if (errorDiv) {
        errorDiv.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${escapeHtml(message)}`;
        errorDiv.classList.remove('hidden');
        document.getElementById('success-message')?.classList.add('hidden');

        setTimeout(() => { errorDiv.classList.add('hidden'); }, 5000);
    }
}

/**
 * Displays a success message using Tailwind styling
 */
function showSuccess(message) {
    const successDiv = document.getElementById('success-message');
    if (successDiv) {
        successDiv.innerHTML = `<i class="fas fa-check-circle"></i> ${escapeHtml(message)}`;
        successDiv.classList.remove('hidden');
        document.getElementById('error-message')?.classList.add('hidden');

        setTimeout(() => { successDiv.classList.add('hidden'); }, 3000);
    }
}

/**
 * Toggles the loading spinner and hides forms
 */
function showLoading(show) {
    const loadingDiv = document.getElementById('loading');
    const forms = document.querySelectorAll('.login-form');

    if (show) {
        loadingDiv?.classList.remove('hidden');
        forms.forEach(form => form.classList.add('hidden'));
    } else {
        loadingDiv?.classList.add('hidden');
        forms.forEach(form => form.classList.remove('hidden'));
    }
}

// Utility to escape HTML to prevent XSS
function escapeHtml(text) {
    if (!text) return '';
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
}