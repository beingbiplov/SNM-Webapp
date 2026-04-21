// persons.js - Persons Management JavaScript

let persons = [];
let filteredPersons = [];

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
            '<tr><td colspan="6" class="loading-state">Failed to load persons</td></tr>';
    }
}

// Display persons in table
function displayPersons() {
    const tbody = document.getElementById('persons-tbody');
    
    if (filteredPersons.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><h3>No persons found</h3><p>No PKI persons are known to this peer yet.</p></td></tr>';
        return;
    }
    
    tbody.innerHTML = filteredPersons.map(person => createPersonRow(person)).join('');
}

// Create person table row
function createPersonRow(person) {
    const trustLevel = person.identityAssurance?.value || 0;
    const trustClass = getTrustLevelClass(trustLevel);
    const signingRate = person.signingFailureRate || 0;
    const signingClass = getSigningRateClass(signingRate);
    
    return `
        <tr>
            <td>
                <div class="person-name">${person.name || 'Unknown'}</div>
                <div class="person-id">${person.id || 'Unknown ID'}</div>
            </td>
            <td class="person-id">${person.id || 'Unknown'}</td>
            <td><span class="badge ${trustClass}">Level ${trustLevel}</span></td>
            <td><span class="signing-rate ${signingClass}">${signingRate.toFixed(2)}%</span></td>
            <td>
                <div class="identity-assurance">
                    <span class="ia-value">${trustLevel}</span>
                    <span class="ia-explanation">${person.identityAssurance?.explanation || 'Unknown'}</span>
                </div>
            </td>
            <td>
                <div class="action-buttons">
                    <button class="btn-small" onclick="showPersonDetails('${person.id}')">Details</button>
                    <button class="btn-small primary" onclick="showRenameModal('${person.id}', '${person.name || ''}')">Rename</button>
                </div>
            </td>
        </tr>
    `;
}

// Get trust level CSS class
function getTrustLevelClass(level) {
    switch(level) {
        case 0: return 'trust-level-0';
        case 1: return 'trust-level-1';
        case 2: return 'trust-level-2';
        case 3: return 'trust-level-3';
        default: return 'trust-level-unknown';
    }
}

// Get signing rate CSS class
function getSigningRateClass(rate) {
    if (rate === 0) return 'signing-rate.good';
    if (rate < 10) return 'signing-rate.good';
    if (rate < 50) return 'signing-rate.warning';
    return 'signing-rate.bad';
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

// Show person details modal
function showPersonDetails(personId) {
    const person = persons.find(p => p.id === playerId);
    if (!person) {
        alert('Person not found');
        return;
    }
    
    const detailsHtml = `
        <div class="person-details-grid">
            <div class="detail-row">
                <span class="detail-label">Name:</span>
                <span class="detail-value">${person.name || 'Unknown'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Peer ID:</span>
                <span class="detail-value">${person.id || 'Unknown'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Index:</span>
                <span class="detail-value">${person.index || 'N/A'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Identity Assurance:</span>
                <span class="detail-value">${person.identityAssurance?.value || 'Unknown'} - ${person.identityAssurance?.explanation || 'No explanation'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Signing Failure Rate:</span>
                <span class="detail-value">${(person.signingFailureRate || 0).toFixed(2)}%</span>
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
window.onclick = function(event) {
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
        newNameInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                renamePerson();
            }
        });
    }
});
