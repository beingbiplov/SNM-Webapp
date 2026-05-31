// persons.js - Persons Management JavaScript (Tailwind CSS Updated)

let persons = [];
let filteredPersons = [];

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

// Initialize page
document.addEventListener('DOMContentLoaded', () => {
    loadPersons();
});

// Load persons from backend
async function loadPersons() {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) throw new Error('Failed to fetch persons');

        const data = await response.json();
        persons = data.persons || [];
        filteredPersons = [...persons];

        displayPersons();
        updateOverviewStats();

    } catch (error) {
        console.error('Error loading persons:', error);
        document.getElementById('persons-tbody').innerHTML =
            '<tr><td colspan="6" class="px-6 py-8 text-center text-red-500">Failed to load persons</td></tr>';
    }
}

// Display persons in table
function displayPersons() {
    const tbody = document.getElementById('persons-tbody');

    if (filteredPersons.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="6" class="px-6 py-12 text-center">
                    <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200">No persons found</h3>
                    <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">No PKI persons are known to this peer yet.</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = filteredPersons.map(person => createPersonRow(person)).join('');
}

// Create person table row
function createPersonRow(person) {
    const trustLevel = person.identityAssurance?.value || 0;
    const trustClass = getTrustLevelTailwindClass(trustLevel);
    const signingRate = person.signingFailureRate || 0;
    const signingClass = getSigningRateTailwindClass(signingRate);

    const safeName = escapeHtml(person.name || 'Unknown');
    const safeId = escapeHtml(person.id || 'Unknown ID');
    const safeExp = escapeHtml(person.identityAssurance?.explanation || 'Unknown');

    return `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4">
                <div class="font-bold text-gray-900 dark:text-white">${safeName}</div>
            </td>
            <td class="px-6 py-4">
                <div class="font-mono text-xs text-gray-500 dark:text-gray-400 truncate max-w-[150px]" title="${safeId}">${safeId}</div>
            </td>
            <td class="px-6 py-4 text-center">
                <span class="px-2.5 py-0.5 text-xs font-bold rounded-full ${trustClass}">Level ${trustLevel}</span>
            </td>
            <td class="px-6 py-4 text-center">
                <span class="font-semibold text-sm ${signingClass}">${signingRate.toFixed(2)}%</span>
            </td>
            <td class="px-6 py-4">
                <div class="flex flex-col">
                    <span class="font-medium text-gray-900 dark:text-gray-200">${trustLevel}</span>
                    <span class="text-xs text-gray-500 dark:text-gray-400 truncate max-w-[200px]" title="${safeExp}">${safeExp}</span>
                </div>
            </td>
            <td class="px-6 py-4 text-right">
                <div class="flex justify-end gap-2">
                    <button class="px-3 py-1.5 text-xs bg-gray-200 hover:bg-gray-300 dark:bg-gray-600 dark:hover:bg-gray-500 text-gray-800 dark:text-gray-200 font-medium rounded transition-colors" onclick="showPersonDetails('${safeId}')">Details</button>
                    <button class="px-3 py-1.5 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 dark:hover:bg-blue-900/50 font-medium rounded transition-colors" onclick="showRenameModal('${safeId}', '${safeName}')">Rename</button>
                </div>
            </td>
        </tr>
    `;
}

// Get trust level CSS class
function getTrustLevelTailwindClass(level) {
    if (level >= 3) return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400';
    if (level === 2) return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400';
    if (level === 1) return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-500';
    return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400';
}

// Get signing rate CSS class
function getSigningRateTailwindClass(rate) {
    if (rate < 10) return 'text-green-600 dark:text-green-400';
    if (rate < 50) return 'text-yellow-600 dark:text-yellow-500';
    return 'text-red-600 dark:text-red-400';
}

// Update overview statistics
function updateOverviewStats() {
    const total = persons.length;
    const trusted = persons.filter(p => (p.identityAssurance?.value || 0) >= 2).length;
    const unknown = persons.filter(p => (p.identityAssurance?.value || 0) === 0).length;

    document.getElementById('total-persons').textContent = total;
    document.getElementById('trusted-persons').textContent = trusted;
    document.getElementById('unknown-persons').textContent = unknown;
}

// Filter persons based on search input
function filterPersons() {
    const searchTerm = document.getElementById('person-search').value.toLowerCase();

    if (!searchTerm) {
        filteredPersons = [...persons];
    } else {
        filteredPersons = persons.filter(person =>
            (person.name || '').toLowerCase().includes(searchTerm) ||
            (person.id || '').toLowerCase().includes(searchTerm)
        );
    }

    displayPersons();
}

// Refresh persons data
function refreshPersons() {
    loadPersons();
}

// Show rename modal
function showRenameModal(personId, currentName) {
    document.getElementById('current-name').value = currentName;
    document.getElementById('new-name').value = '';
    document.getElementById('rename-modal').classList.remove('hidden');

    // Store person ID for later use
    window.currentRenamePersonId = personId;

    // Focus on new name input
    setTimeout(() => {
        document.getElementById('new-name').focus();
    }, 100);
}

// Hide rename modal
function hideRenameModal() {
    document.getElementById('rename-modal').classList.add('hidden');
    window.currentRenamePersonId = null;
}

// Rename person
async function renamePerson() {
    const oldName = document.getElementById('current-name').value;
    const newName = document.getElementById('new-name').value.trim();

    if (!newName) {
        alert('Please enter a new name');
        return;
    }

    if (newName === oldName) {
        alert('New name must be different from current name');
        return;
    }

    try {
        const response = await fetch('/snm-webapp/api/persons/rename', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                oldName: oldName,
                newName: newName
            })
        });

        const result = await response.json();

        if (response.ok) {
            alert('Person renamed successfully!');
            hideRenameModal();
            loadPersons(); // Refresh the list
        } else {
            alert('Error: ' + (result.error || 'Failed to rename person'));
        }

    } catch (error) {
        console.error('Error renaming person:', error);
        alert('Failed to rename person. Please try again.');
    }
}

// Show person details modal (BUG FIXED: was using undefined 'playerId')
function showPersonDetails(personId) {
    const person = persons.find(p => p.id === personId);

    if (!person) {
        alert('Person not found');
        return;
    }

    const detailsHtml = `
        <div class="grid grid-cols-1 md:grid-cols-2 gap-y-4 gap-x-6">
            <div>
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Name</span>
                <div class="font-medium text-gray-900 dark:text-white">${escapeHtml(person.name || 'Unknown')}</div>
            </div>
            <div>
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Index</span>
                <div class="font-medium text-gray-900 dark:text-white">${person.index || 'N/A'}</div>
            </div>
            <div class="md:col-span-2">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Peer ID</span>
                <div class="font-mono text-xs break-all bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-300 p-2.5 rounded border border-gray-200 dark:border-gray-800">${escapeHtml(person.id || 'Unknown')}</div>
            </div>
            <div class="md:col-span-2">
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Identity Assurance</span>
                <div class="font-medium text-gray-900 dark:text-white">${person.identityAssurance?.value || 'Unknown'} - ${escapeHtml(person.identityAssurance?.explanation || 'No explanation')}</div>
            </div>
            <div>
                <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-1">Signing Failure Rate</span>
                <div class="font-medium ${getSigningRateTailwindClass(person.signingFailureRate || 0)}">${(person.signingFailureRate || 0).toFixed(2)}%</div>
            </div>
        </div>
    `;

    document.getElementById('person-details').innerHTML = detailsHtml;
    document.getElementById('details-modal').classList.remove('hidden');
}

// Hide details modal
function hideDetailsModal() {
    document.getElementById('details-modal').classList.add('hidden');
}

// Close modals when clicking outside
window.onclick = function (event) {
    const renameModal = document.getElementById('rename-modal');
    const detailsModal = document.getElementById('details-modal');

    if (event.target === renameModal) {
        hideRenameModal();
    }
    if (event.target === detailsModal) {
        hideDetailsModal();
    }
}

// Handle Enter key in rename modal
document.addEventListener('DOMContentLoaded', () => {
    const newNameInput = document.getElementById('new-name');
    if (newNameInput) {
        newNameInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                renamePerson();
            }
        });
    }
});

//TEST =>

/*
// حقن بيانات وهمية لاختبار الواجهة
persons = [
    { id: "hash-12345", name: "Osama", identityAssurance: { value: 3, explanation: "Highly Verified" }, signingFailureRate: 0.5 },
    { id: "hash-67890", name: "Yigit", identityAssurance: { value: 2, explanation: "Verified" }, signingFailureRate: 15.2 },
    { id: "hash-11111", name: "Unknown User", identityAssurance: { value: 0, explanation: "No trust data" }, signingFailureRate: 60.0 }
];
filteredPersons = [...persons];
displayPersons();
updateOverviewStats();
 */