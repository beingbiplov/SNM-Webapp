/**
 * messenger.js - Handles Channels and Messaging logic
 * Updated with Advanced Filters (Search/Date/Sender) and Right-Click Context Menu.
 */

// --- Global State ---
let currentChannelState = {uri: null, index: null, name: null};
let currentMessages = [];
let editingMessageId = null;

// Context Menu Targets
let ctxTargetMsgId = null;
let ctxTargetMsgContent = null;

/**
 * Initializes listeners on DOM content loaded.
 */
document.addEventListener('DOMContentLoaded', () => {
    loadChannels();
    loadPersonsForRecipient();

    // Enter key listener for message input
    const input = document.getElementById('message-input');
    if (input) {
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    }

    // Hide context menu on global click
    document.addEventListener('click', hideContextMenu);
});

// Hide Create Modal if clicked outside
document.addEventListener('click', function (e) {
    const modal = document.getElementById('create-channel-form');
    const filterPanel = document.getElementById('filter-panel');

    if (modal && !modal.classList.contains('hidden') && e.target === modal) {
        hideCreateChannelModal();
    }

    // Hide filter panel if clicking outside of it
    if (filterPanel && !filterPanel.classList.contains('hidden') && !e.target.closest('#filter-panel') && !e.target.closest('#filter-toggle-btn')) {
        filterPanel.classList.add('hidden');
    }
});

// --- Channel Logic ---

/**
 * Shows the Create Channel modal.
 * @return {void}
 */
function showCreateChannelModal() {
    const modal = document.getElementById('create-channel-form');
    if (modal) {
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        setTimeout(() => {
            document.getElementById('new-channel-uri')?.focus();
        }, 100);
    }
}

/**
 * Hides the Create Channel modal and clears inputs.
 * @return {void}
 */
function hideCreateChannelModal() {
    const modal = document.getElementById('create-channel-form');
    if (modal) {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        document.getElementById('new-channel-uri').value = '';
        document.getElementById('new-channel-name').value = '';
    }
}

/**
 * Fetches and renders channels.
 * @return {Promise<void>}
 */
async function loadChannels() {
    const container = document.getElementById('channel-list');
    if (!container) return;

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels');
        if (!response.ok) throw new Error('Failed to fetch channels');

        const data = await response.json();
        container.innerHTML = `<div class="w-full text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-dark-card dark:border-dark-border dark:text-white shadow-sm" id="dynamic-channel-list"></div>`;
        const listGroup = document.getElementById('dynamic-channel-list');

        if (data.channels && data.channels.length > 0) {
            data.channels.forEach((channel, index) => {
                const isLast = index === data.channels.length - 1;
                const isActive = currentChannelState.uri === channel.uri;
                const item = document.createElement('a');

                let baseClasses = "channel-item flex justify-between items-center w-full px-4 py-3 cursor-pointer transition-colors ";
                if (!isLast) baseClasses += "border-b border-gray-200 dark:border-dark-border ";
                if (index === 0) baseClasses += "rounded-t-lg ";
                if (isLast) baseClasses += "rounded-b-lg ";

                if (isActive) {
                    baseClasses += "bg-gray-100 text-primary-600 dark:bg-gray-800 dark:text-primary-400";
                    item.setAttribute('aria-current', 'true');
                } else {
                    baseClasses += "hover:bg-gray-50 hover:text-primary-600 dark:hover:bg-gray-800 dark:hover:text-primary-400 text-gray-900 dark:text-white";
                }

                item.className = baseClasses;
                item.onclick = () => selectChannel(item, channel.uri, channel.name, channel.index);

                item.innerHTML = `
                    <div class="flex items-center truncate">
                        <i class="fas fa-hashtag w-4 h-4 mr-2 ${isActive ? '' : 'text-gray-400 dark:text-gray-500'} channel-icon"></i>
                        <span class="truncate name-text ${isActive ? 'font-bold' : ''}">${escapeHtml(channel.name)}</span>
                    </div>
                    <div class="flex items-center">
                        <span class="text-xs text-gray-400 mr-2 bg-gray-100 dark:bg-gray-700 px-2 py-0.5 rounded-full">${channel.messages || 0}</span>
                        <button onclick="deleteChannel('${escapeHtml(channel.uri)}', event)" class="text-gray-400 hover:text-red-500 transition-colors" title="Delete Channel">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                `;
                listGroup.appendChild(item);
            });

            document.getElementById('active-channel-count').textContent = data.channels.length;
        } else {
            listGroup.innerHTML = `<div class="p-5 text-center text-gray-500 dark:text-gray-400 text-sm">No channels available.<br>Create one using the <i class="fas fa-plus-circle text-primary-500 mx-1"></i> button.</div>`;
            document.getElementById('active-channel-count').textContent = '0';
        }
    } catch (error) {
        container.innerHTML = `<div class="p-4 text-center text-red-500 text-sm">Failed to load channels from server.</div>`;
    }
}

/**
 * Handles channel selection and UI updates.
 * @param {HTMLElement} element - Clicked channel element
 * @param {string} uri - Channel URI
 * @param {string} name - Channel Display Name
 * @param {number} index - Channel backend index
 * @return {void}
 */
function selectChannel(element, uri, name, index) {
    currentChannelState = {uri, name, index};

    document.querySelectorAll('.channel-item').forEach(el => {
        el.removeAttribute('aria-current');
        el.classList.remove('bg-gray-100', 'text-primary-600', 'dark:bg-gray-800', 'dark:text-primary-400');
        el.classList.add('hover:bg-gray-50', 'hover:text-primary-600', 'dark:hover:bg-gray-800', 'dark:hover:text-primary-400', 'text-gray-900', 'dark:text-white');
        el.querySelector('.name-text')?.classList.remove('font-bold');
        el.querySelector('.channel-icon')?.classList.add('text-gray-400', 'dark:text-gray-500');
    });

    if (element) {
        element.setAttribute('aria-current', 'true');
        element.classList.remove('hover:bg-gray-50', 'hover:text-primary-600', 'dark:hover:bg-gray-800', 'dark:hover:text-primary-400', 'text-gray-900', 'dark:text-white');
        element.classList.add('bg-gray-100', 'text-primary-600', 'dark:bg-gray-800', 'dark:text-primary-400');
        element.querySelector('.name-text')?.classList.add('font-bold');
        element.querySelector('.channel-icon')?.classList.remove('text-gray-400', 'dark:text-gray-500');
    }

    document.getElementById('current-channel-name').textContent = name || uri;
    document.getElementById('current-channel-pki-status').innerText = 'Connected to ' + escapeHtml(name || uri);

    const indicator = document.getElementById('status-indicator');
    if (indicator) {
        indicator.classList.remove('bg-gray-400');
        indicator.classList.add('bg-green-500', 'shadow-[0_0_5px_#22c55e]');
    }

    // Enable Search & Filters
    document.getElementById('message-search').disabled = false;
    document.getElementById('filter-toggle-btn').disabled = false;
    clearFilters();
    cancelEditMode();

    loadMessages(uri);
}

// --- Messages & Advanced Filtering (Task F) ---

/**
 * Fetches messages for the active channel.
 * @param {string} uri - Channel URI
 * @return {Promise<void>}
 */
async function loadMessages(uri) {
    const chatLog = document.getElementById('chat-log');
    chatLog.innerHTML = `<div class="flex flex-col items-center justify-center h-full text-center space-y-3 opacity-60"><i class="fas fa-spinner fa-spin text-3xl text-primary-500"></i><p class="text-sm">Loading messages...</p></div>`;

    try {
        const response = await fetch(`/snm-webapp/api/messenger/messages/?uri=${encodeURIComponent(uri)}`);
        if (!response.ok) throw new Error(`Status ${response.status}`);

        const data = await response.json();

        if (data.channel && data.channel.messages) {
            currentMessages = data.channel.messages;
            applyFilters(); // Render with current filters if any
        } else {
            currentMessages = [];
            chatLog.innerHTML = '<div class="text-center p-5 text-gray-400 text-sm">No messages. Be the first to say hello!</div>';
        }
    } catch (error) {
        chatLog.innerHTML = `<div class="text-center text-red-500 p-5 text-sm">Error loading messages.</div>`;
    }
}

/**
 * Toggles the visibility of the message filter panel.
 * @return {void}
 */
function toggleFilterPanel() {
    const panel = document.getElementById('filter-panel');
    if (panel) {
        panel.classList.toggle('hidden');
    }
}

/**
 * Applies search text, sender filter, and date range filters to current messages.
 * @return {void}
 */
function applyFilters() {
    const textTerm = document.getElementById('message-search').value.toLowerCase();
    const senderTerm = document.getElementById('filter-sender').value.toLowerCase();
    const startDateVal = document.getElementById('filter-date-start').value;
    const endDateVal = document.getElementById('filter-date-end').value;

    let filtered = currentMessages;

    if (textTerm) {
        filtered = filtered.filter(m => m.content.toLowerCase().includes(textTerm));
    }

    if (senderTerm) {
        filtered = filtered.filter(m => m.sender.toLowerCase().includes(senderTerm));
    }

    if (startDateVal || endDateVal) {
        const startDate = startDateVal ? new Date(startDateVal) : new Date('1970-01-01');
        const endDate = endDateVal ? new Date(endDateVal) : new Date('2100-01-01');
        endDate.setHours(23, 59, 59, 999);

        filtered = filtered.filter(m => {
            const msgDateStr = m.timestamp.replace(' ', 'T');
            const msgDate = new Date(msgDateStr);
            if (isNaN(msgDate.getTime())) return true;
            return msgDate >= startDate && msgDate <= endDate;
        });
    }

    renderMessages(filtered, textTerm);
}

/**
 * Clears all filters and resets the search panel.
 * @return {void}
 */
function clearFilters() {
    document.getElementById('message-search').value = '';
    document.getElementById('filter-sender').value = '';
    document.getElementById('filter-date-start').value = '';
    document.getElementById('filter-date-end').value = '';
    applyFilters();
}

/**
 * Highlights a specific search term within text.
 * @param {string} text - The original text
 * @param {string} term - The search term to highlight
 * @return {string} Highlighted HTML string
 */
function highlightText(text, term) {
    let escaped = escapeHtml(text);
    if (!term) return escaped;
    const regex = new RegExp(`(${term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    return escaped.replace(regex, '<mark class="bg-yellow-200 dark:bg-yellow-800/80 text-gray-900 dark:text-white rounded px-1">$1</mark>');
}

/**
 * Renders the messages to the DOM.
 * @param {Array} messages - Array of message objects
 * @param {string} searchTerm - Active search term for highlighting
 * @return {void}
 */
function renderMessages(messages, searchTerm = '') {
    const chatLog = document.getElementById('chat-log');
    chatLog.innerHTML = '';

    if (messages.length === 0) {
        chatLog.innerHTML = `<div class="text-center p-5 text-gray-400 text-sm">No matching messages found.</div>`;
        return;
    }

    messages.forEach(msg => {
        const line = document.createElement('div');
        const isMe = msg.sender === 'you';
        const msgId = msg.id || msg.timestamp;

        const highlightedContent = highlightText(msg.content, searchTerm);
        const escapedContentForJS = escapeHtml(msg.content).replace(/'/g, "\\'").replace(/"/g, '&quot;');
        const isMeStr = isMe ? 'true' : 'false';

        line.innerHTML = `
            <div class="mb-4 max-w-[85%] ${isMe ? 'ml-auto text-right' : 'mr-auto text-left'}">
                <div class="text-[0.7rem] text-gray-500 dark:text-gray-400 mb-1 px-1">
                    ${escapeHtml(msg.timestamp.split(' ')[1] || msg.timestamp)} - ${escapeHtml(msg.sender)}
                    ${msg.edited ? '<span class="italic text-gray-400 text-[0.65rem] ml-1">(edited)</span>' : ''}
                </div>
                <div oncontextmenu="handleContextMenu(event, '${escapeHtml(msgId)}', '${escapedContentForJS}', ${isMeStr})" 
                     class="${isMe ? 'cursor-context-menu bg-primary-500 text-white rounded-l-xl rounded-tr-xl hover:brightness-110' : 'bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border text-gray-800 dark:text-gray-200 rounded-r-xl rounded-tl-xl'} px-4 py-2 inline-block text-sm shadow-sm text-left break-words max-w-full transition-all"
                     title="${isMe ? 'Right-click to Edit or Delete' : ''}">
                    ${highlightedContent}
                </div>
            </div>
        `;
        chatLog.appendChild(line);
    });

    chatLog.scrollTop = chatLog.scrollHeight;
}

// --- Context Menu Logic (Task G) ---

/**
 * Handles the right-click context menu for messages.
 * @param {Event} event - The contextmenu event
 * @param {string} msgId - The ID of the message
 * @param {string} content - The content of the message
 * @param {boolean} isMe - Indicates if the user is the sender
 * @return {void}
 */
function handleContextMenu(event, msgId, content, isMe) {
    if (!isMe) return;

    event.preventDefault();

    ctxTargetMsgId = msgId;
    ctxTargetMsgContent = content;

    const menu = document.getElementById('message-context-menu');
    menu.classList.remove('hidden', 'opacity-0', 'pointer-events-none');
    menu.classList.add('opacity-100', 'pointer-events-auto');

    let x = event.clientX;
    let y = event.clientY;

    // Prevent menu from going off-screen
    if (x + menu.offsetWidth > window.innerWidth) x = window.innerWidth - menu.offsetWidth;
    if (y + menu.offsetHeight > window.innerHeight) y = window.innerHeight - menu.offsetHeight;

    menu.style.left = `${x}px`;
    menu.style.top = `${y}px`;
}

/**
 * Hides the custom context menu.
 * @return {void}
 */
function hideContextMenu() {
    const menu = document.getElementById('message-context-menu');
    if (menu && !menu.classList.contains('hidden')) {
        menu.classList.add('hidden', 'opacity-0', 'pointer-events-none');
        menu.classList.remove('opacity-100', 'pointer-events-auto');
    }
    ctxTargetMsgId = null;
    ctxTargetMsgContent = null;
}

/**
 * Triggers the edit process from the context menu.
 * @return {void}
 */
function triggerEditFromMenu() {
    if (ctxTargetMsgId && ctxTargetMsgContent) {
        startEditMessage(ctxTargetMsgId, ctxTargetMsgContent);
    }
    hideContextMenu();
}

/**
 * Triggers the delete process from the context menu.
 * @return {void}
 */
function triggerDeleteFromMenu() {
    if (ctxTargetMsgId) {
        deleteMessage(ctxTargetMsgId);
    }
    hideContextMenu();
}

// --- Edit & Delete Logic (Optimistic UI) ---

/**
 * Initializes the message edit mode in the UI.
 * @param {string} id - Message ID
 * @param {string} content - Original Message Content
 * @return {void}
 */
function startEditMessage(id, content) {
    editingMessageId = id;
    const input = document.getElementById('message-input');
    input.value = content;
    input.focus();

    const sendBtn = document.getElementById('send-btn');
    sendBtn.innerHTML = `<i class="fas fa-save text-base"></i><span class="text-xs">Update</span>`;
    sendBtn.classList.remove('bg-primary-500', 'hover:bg-primary-600');
    sendBtn.classList.add('bg-yellow-500', 'hover:bg-yellow-600');

    if (!document.getElementById('cancel-edit-btn')) {
        const cancelBtn = document.createElement('button');
        cancelBtn.id = 'cancel-edit-btn';
        cancelBtn.className = 'text-xs text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 transition-colors font-medium mt-1';
        cancelBtn.innerText = 'Cancel Edit';
        cancelBtn.onclick = cancelEditMode;
        document.getElementById('action-buttons-container').appendChild(cancelBtn);
    }
}

/**
 * Cancels the message edit mode.
 * @return {void}
 */
function cancelEditMode() {
    editingMessageId = null;
    document.getElementById('message-input').value = '';

    const sendBtn = document.getElementById('send-btn');
    sendBtn.innerHTML = `<i class="fas fa-paper-plane text-base"></i><span class="text-xs">Send</span>`;
    sendBtn.classList.add('bg-primary-500', 'hover:bg-primary-600');
    sendBtn.classList.remove('bg-yellow-500', 'hover:bg-yellow-600');

    document.getElementById('cancel-edit-btn')?.remove();
}

/**
 * Gathers input and sends (or updates) a message.
 * @return {Promise<void>}
 */
async function sendMessage() {
    if (currentChannelState.index === null || currentChannelState.index === undefined) {
        alert('Please select a channel from the list first.');
        return;
    }

    const input = document.getElementById('message-input');
    const content = input.value.trim();
    if (!content) return;

    // Edit Mode Handling (Optimistic UI)
    if (editingMessageId) {
        try {
            const payload = {messageId: editingMessageId, channelIndex: currentChannelState.index, content: content};
            const response = await fetch('/snm-webapp/api/messenger/messages', {
                method: 'PUT',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            });

            if (response.ok) {
                cancelEditMode();
                loadMessages(currentChannelState.uri);
            } else {
                const msgIndex = currentMessages.findIndex(m => (m.id || m.timestamp) === editingMessageId);
                if (msgIndex !== -1) {
                    currentMessages[msgIndex].content = content;
                    currentMessages[msgIndex].edited = true;
                }
                cancelEditMode();
                applyFilters();
            }
        } catch (error) {
            const msgIndex = currentMessages.findIndex(m => (m.id || m.timestamp) === editingMessageId);
            if (msgIndex !== -1) {
                currentMessages[msgIndex].content = content;
                currentMessages[msgIndex].edited = true;
            }
            cancelEditMode();
            applyFilters();
        }
        return;
    }

    // Normal Send Handling
    try {
        const payload = {
            content: content,
            channelIndex: currentChannelState.index,
            contentType: "ASAP_CHARACTER_SEQUENCE",
            sign: document.getElementById('sign-message')?.checked !== false,
            encrypt: document.getElementById('encrypt-message')?.checked === true,
            receiver: document.getElementById('message-receiver')?.value || "ANY_SHARKNET_PEER"
        };

        const response = await fetch('/snm-webapp/api/messenger/messages', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });

        if (response.ok) {
            input.value = '';
            showSendSuccess();
            setTimeout(() => {
                loadMessages(currentChannelState.uri);
            }, 500);
        } else {
            const result = await response.json();
            alert('Failed to send message: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Error sending message');
    }
}

/**
 * Deletes a message (Optimistic UI fallback).
 * @param {string} msgId - Message ID
 * @return {Promise<void>}
 */
async function deleteMessage(msgId) {
    if (!confirm('Are you sure you want to delete this message?')) return;

    try {
        const response = await fetch(`/snm-webapp/api/messenger/messages?msgId=${encodeURIComponent(msgId)}&channelIndex=${currentChannelState.index}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            loadMessages(currentChannelState.uri);
        } else {
            currentMessages = currentMessages.filter(m => (m.id || m.timestamp) !== msgId);
            applyFilters();
        }
    } catch (e) {
        currentMessages = currentMessages.filter(m => (m.id || m.timestamp) !== msgId);
        applyFilters();
    }
}

// --- Utils ---

/**
 * Creates a new channel via API.
 * @return {Promise<void>}
 */
async function createChannel() {
    const uriInput = document.getElementById('new-channel-uri');
    const nameInput = document.getElementById('new-channel-name');
    const uri = uriInput.value.trim();
    const name = nameInput.value.trim() || uri;

    if (!uri) return alert('Channel URI is required');

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({uri, name})
        });

        if (response.ok) {
            hideCreateChannelModal();
            loadChannels();
        } else {
            const result = await response.json();
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Request failed');
    }
}

/**
 * Deletes a channel via API.
 * @param {string} uri - Channel URI
 * @param {Event} event - Click event
 * @return {Promise<void>}
 */
async function deleteChannel(uri, event) {
    if (event) event.stopPropagation();
    if (!confirm(`Are you sure you want to delete the channel:\n${uri}?`)) return;

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({uri: uri})
        });

        if (response.ok) {
            if (currentChannelState.uri === uri) {
                document.getElementById('chat-log').innerHTML = '<div class="text-center p-5 text-gray-400 text-sm">Channel deleted.</div>';
                document.getElementById('current-channel-name').textContent = 'Select a channel';
                document.getElementById('current-channel-pki-status').innerText = 'Waiting for selection...';
                document.getElementById('status-indicator')?.classList.add('bg-gray-400');
                document.getElementById('status-indicator')?.classList.remove('bg-green-500');
                currentChannelState = {uri: null, index: null, name: null};
                document.getElementById('message-search').disabled = true;
                document.getElementById('filter-toggle-btn').disabled = true;
            }
            loadChannels();
        } else {
            alert('Failed to delete channel.');
        }
    } catch (e) {
        alert('Error deleting channel');
    }
}

/**
 * Temporarily shows a success state on the send button.
 * @return {void}
 */
function showSendSuccess() {
    const sendBtn = document.getElementById('send-btn');
    if (!sendBtn) return;
    const originalContent = sendBtn.innerHTML;
    sendBtn.innerHTML = `<i class="fas fa-check text-base"></i><span class="text-xs">Sent!</span>`;
    sendBtn.classList.replace('bg-primary-500', 'bg-green-500');
    sendBtn.classList.replace('hover:bg-primary-600', 'hover:bg-green-600');
    setTimeout(() => {
        sendBtn.innerHTML = originalContent;
        sendBtn.classList.replace('bg-green-500', 'bg-primary-500');
        sendBtn.classList.replace('hover:bg-green-600', 'hover:bg-primary-600');
    }, 2000);
}

/**
 * Fetches available persons to populate the receiver dropdown.
 * @return {Promise<void>}
 */
async function loadPersonsForRecipient() {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) return;
        const data = await response.json();
        const select = document.getElementById('message-receiver');
        if (select && data.persons && data.persons.length > 0) {
            select.innerHTML = '<option value="ANY_SHARKNET_PEER">Anyone</option>';
            data.persons.forEach(person => {
                const option = document.createElement('option');
                option.value = person.name;
                option.textContent = `${escapeHtml(person.name)} (${escapeHtml(person.id.substring(0, 8))}...)`;
                select.appendChild(option);
            });
        }
    } catch (error) {
    }
}

/**
 * Escapes HTML characters to prevent XSS attacks.
 * @param {string} text - Raw input text
 * @return {string} Escaped safe text
 */
function escapeHtml(text) {
    if (!text) return '';
    return text.toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
}