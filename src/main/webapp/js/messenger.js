// messenger.js - Handles Channels and Messaging logic

// Global state
let currentChannelState = {
    uri: null,
    index: null, // needed for sending messages
    name: null
};

document.addEventListener('DOMContentLoaded', () => {
    loadChannels();
    loadPersonsForRecipient(); // Load available persons for recipient selection

    // Add enter key listener for textarea
    const input = document.getElementById('message-input');
    if (input) {
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    }
});

async function loadChannels() {
    console.log('Loading channels...');
    const container = document.getElementById('channel-list');
    if (!container) return;

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels');
        if (!response.ok) throw new Error('Failed to fetch channels');

        const data = await response.json();
        console.log('Channels data:', data);

        // Keep the header with create button
        container.innerHTML = `
            <div class="channels-header" style="display:flex; align-items:center; justify-content:space-between;">
                <h3>Channels</h3>
                <button class="btn-icon-small" onclick="showCreateChannelModal()" title="Create Channel">+</button>
            </div>
            <div class="channel-list">
        `;

        if (data.channels && data.channels.length > 0) {
            data.channels.forEach(channel => {
                const item = document.createElement('div');
                item.className = `channel-item ${currentChannelState.uri === channel.uri ? 'active' : ''}`;

                // Pass index, name, uri
                item.onclick = () => selectChannel(channel.uri, channel.name, channel.index);

                item.innerHTML = `
                    <div class="channel-info">
                        <div class="channel-name">${channel.name}</div>
                        <div class="channel-uri">${channel.uri}</div>
                    </div>
                    <div class="channel-meta">
                        <div class="channel-badge">${channel.messages}</div>
                        <button onclick="deleteChannel('${channel.uri}', event)" title="Delete Channel" class="btn-delete-channel">
                            ×
                        </button>
                    </div>
                `;
                container.querySelector('.channel-list').appendChild(item);
            });

            // Update info panel count
            const countEl = document.getElementById('active-channel-count');
            if (countEl) countEl.textContent = data.channels.length;

        } else {
            const empty = document.createElement('div');
            empty.style.padding = '20px';
            empty.style.textAlign = 'center';
            empty.style.color = '#999';
            empty.style.fontSize = '0.9rem';
            empty.textContent = 'No channels yet.';
            container.querySelector('.channel-list').appendChild(empty);

            const countEl = document.getElementById('active-channel-count');
            if (countEl) countEl.textContent = '0';
        }

    } catch (error) {
        console.error('Error loading channels:', error);
        container.innerHTML += `<div style="color: red; padding: 10px;">Failed to load channels</div>`;
    }
}

async function deleteChannel(uri, event) {
    if (event) event.stopPropagation();
    if (!confirm(`Delete channel ${uri}?`)) return;

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels', {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ uri: uri })
        });

        if (response.ok) {
            loadChannels();
            // If deleting current channel, clear view
            if (currentChannelState.uri === uri) {
                document.getElementById('chat-log').innerHTML = '<div style="text-align:center; padding:20px; color:#999;">Channel deleted.</div>';
                document.getElementById('current-channel-name').textContent = 'Select a channel';
                currentChannelState = { uri: null, index: null, name: null };
            }
        } else {
            alert('Failed to delete channel');
        }
    } catch (e) {
        console.error(e);
        alert('Error deleting channel');
    }
}

function showCreateChannelModal() {
    document.getElementById('create-channel-form').style.display = 'block';
    document.getElementById('new-channel-uri').focus();
}

function hideCreateChannelModal() {
    document.getElementById('create-channel-form').style.display = 'none';
}

async function createChannel() {
    const uriInput = document.getElementById('new-channel-uri');
    const nameInput = document.getElementById('new-channel-name');

    const uri = uriInput.value.trim();
    const name = nameInput.value.trim() || uri;

    if (!uri) {
        alert('URI is required');
        return;
    }

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ uri, name })
        });

        const result = await response.json();

        if (response.ok) {
            hideCreateChannelModal();
            uriInput.value = '';
            nameInput.value = '';
            loadChannels(); // Refresh list
        } else {
            alert('Error: ' + (result.error || result.message || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error creating channel:', error);
        alert('Request failed');
    }
}

function selectChannel(uri, name, index) {
    currentChannelState = { uri, name, index };
    console.log('Selected channel:', currentChannelState);

    // Update Header
    const headerName = document.getElementById('current-channel-name');
    if (headerName) headerName.textContent = name || uri;

    // Update UI active state
    document.querySelectorAll('.channel-item').forEach(el => {
        el.classList.remove('active');
        if (el.innerHTML.includes(uri)) el.classList.add('active');
    });

    loadMessages(uri);
}

async function loadMessages(uri) {
    const chatLog = document.getElementById('chat-log');
    if (!chatLog) return;

    chatLog.innerHTML = '<div style="text-align:center; padding: 20px;">Loading messages...</div>';

    try {
        // GET /api/messenger/messages/{uri}
        // Note: The servlet maps to /api/messenger/messages/* so we append the uri
        // We must encode the URI component twice? No, path parameter.
        // If the uri contains slashes, it might be tricky. But usually channel URIs are like saved queries or just strings.
        // Let's assume simple encoding.
        const encodedUri = encodeURIComponent(uri);

        // We use a query parameter 'uri' to avoid Tomcat's security blocking of encoded slashes (%2F) in the path

        // We use a trailing slash '/' to ensure we hit the ListMessagesServlet (mapped to /api/messenger/messages/*)
        // instead of the MessageServlet (mapped to exact /messages).
        // The path info will be '/' which our servlet logic ignores (length <= 1), 
        // causing it to correctly use the 'uri' query parameter.
        const response = await fetch(`/snm-webapp/api/messenger/messages/?uri=${encodedUri}`);
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Status ${response.status}: ${errorText}`);
        }

        const data = await response.json();

        if (data.channel && data.channel.messages) {
            renderMessages(data.channel.messages);
        } else {
            chatLog.innerHTML = '<div style="text-align:center; padding: 20px;">No messages.</div>';
        }

    } catch (error) {
        console.error('Error loading messages:', error);
        chatLog.innerHTML = `<div style="text-align:center; color:red; padding: 20px;">Error loading messages: ${error.message}</div>`;
    }
}

function renderMessages(messages) {
    const chatLog = document.getElementById('chat-log');
    chatLog.innerHTML = '';

    if (messages.length === 0) {
        chatLog.innerHTML = '<div style="text-align:center; padding: 20px; color:#999;">No messages here yet. Say hello!</div>';
        return;
    }

    messages.forEach(msg => {
        const line = document.createElement('div');
        // Simple message styling
        // We can differentiate 'you' vs others
        const isMe = msg.sender === 'you';

        line.innerHTML = `
                    <div style="margin-bottom: 12px; max-width: 80%; ${isMe ? 'margin-left: auto; text-align: right;' : 'margin-right: auto;'}">
                <div style="font-size: 0.75rem; color: #888; margin-bottom: 2px;">
                    ${msg.timestamp.split(' ')[1] || msg.timestamp} - ${msg.sender}
                </div>
                <div style="
                    background: ${isMe ? 'var(--primary-color)' : '#f0f0f0'}; 
                    color: ${isMe ? '#fff' : '#000'}; 
                    padding: 8px 12px; 
                    border-radius: 8px; 
                    display: inline-block;
                    text-align: left;
                ">
                    ${escapeHtml(msg.content)}
                </div>
            </div>
                    `;
        chatLog.appendChild(line);
    });

    // Scroll to bottom
    chatLog.scrollTop = chatLog.scrollHeight;
}

async function sendMessage() {
    if (!currentChannelState.index) {
        alert('Please select a channel first.');
        return;
    }

    const input = document.getElementById('message-input');
    const content = input.value.trim();

    if (!content) return;

    try {
        const payload = {
            content: content,
            channelIndex: currentChannelState.index,
            contentType: "ASAP_CHARACTER_SEQUENCE",
            sign: document.getElementById('sign-message')?.checked !== false,
            encrypt: document.getElementById('encrypt-message')?.checked === true,
            receiver: document.getElementById('message-receiver')?.value || "ANY_SHARKNET_PEER"
        };

        console.log('Sending message:', payload);

        const response = await fetch('/snm-webapp/api/messenger/messages', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const result = await response.json();

        if (response.ok) {
            console.log('Message sent:', result);
            input.value = ''; // Clear input

            // Show success feedback
            showSendSuccess(result);

            // Reload messages to see the new one
            setTimeout(() => {
                loadMessages(currentChannelState.uri);
            }, 500);
        } else {
            console.error('Send failed:', result);
            alert('Failed to send message: ' + (result.error || 'Unknown error'));
        }

    } catch (error) {
        console.error('Error sending message:', error);
        alert('Error sending message');
    }
}

// Show send success feedback
function showSendSuccess(result) {
    const sendBtn = document.getElementById('send-btn');
    const originalText = sendBtn.textContent;

    sendBtn.textContent = '✓ Sent!';
    sendBtn.style.background = 'var(--green)';

    setTimeout(() => {
        sendBtn.textContent = originalText;
        sendBtn.style.background = '';
    }, 2000);
}

// Load available persons for recipient selection
async function loadPersonsForRecipient() {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) return;

        const data = await response.json();
        const select = document.getElementById('message-receiver');

        if (select && data.persons && data.persons.length > 0) {
            // Clear existing options except "Anyone"
            select.innerHTML = '<option value="ANY_SHARKNET_PEER">Anyone</option>';

            data.persons.forEach(person => {
                const option = document.createElement('option');
                option.value = person.name;
                option.textContent = `${person.name} (${person.id.substring(0, 8)}...)`;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading persons for recipient selection:', error);
    }
}

function escapeHtml(text) {
    if (!text) return '';
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
