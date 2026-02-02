// messenger.js - Handles Channels and Messaging logic

// Global state
let currentChannelState = {
    uri: null,
    index: null, // needed for sending messages
    name: null
};

document.addEventListener('DOMContentLoaded', () => {
    loadChannels();

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

        // Keep the header
        container.innerHTML = `
            <div style="font-weight: 700; margin-bottom: 20px; font-family: 'JetBrains Mono', monospace; display: flex; justify-content: space-between; align-items: center;">
                <span>Channels</span>
                <button onclick="showCreateChannelModal()" style="font-size: 0.8rem; padding: 4px 8px; background: var(--primary-color); color: white; border: none; border-radius: 4px; cursor: pointer;">+</button>
            </div>
            <div id="create-channel-form" style="display: none; margin-bottom: 10px; padding: 10px; background: #f3f4f6; border-radius: 8px;">
                <input type="text" id="new-channel-uri" placeholder="URI (e.g. #dev)" style="width: 100%; margin-bottom: 5px; padding: 5px; border-radius: 4px; border: 1px solid #ddd;">
                <input type="text" id="new-channel-name" placeholder="Name" style="width: 100%; margin-bottom: 5px; padding: 5px; border-radius: 4px; border: 1px solid #ddd;">
                <div style="display: flex; gap: 5px;">
                    <button onclick="createChannel()" style="flex: 1; background: var(--primary-color); color: white; border: none; padding: 5px; border-radius: 4px; cursor: pointer;">Create</button>
                    <button onclick="hideCreateChannelModal()" style="flex: 1; background: #ddd; color: #333; border: none; padding: 5px; border-radius: 4px; cursor: pointer;">Cancel</button>
                </div>
            </div>
        `;

        if (data.channels && data.channels.length > 0) {
            data.channels.forEach(channel => {
                const item = document.createElement('div');
                item.className = `channel-item ${currentChannelState.uri === channel.uri ? 'active' : ''}`;

                // Pass index, name, uri
                item.onclick = () => selectChannel(channel.uri, channel.name, channel.index);

                // Determine dot color
                const dotColor = 'dot-green';

                item.innerHTML = `
                    <div class="status-dot ${dotColor}"></div>
                    <div style="flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" onclick="selectChannel('${channel.uri}', '${channel.name}', ${channel.index})">
                        <div style="font-weight: 600;">${channel.name}</div>
                        <div style="font-size: 0.8rem; color: #666;">${channel.uri}</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:5px;">
                         <div style="font-size: 0.75rem; background: #eee; padding: 2px 6px; border-radius: 10px;">${channel.messages}</div>
                         <button onclick="deleteChannel('${channel.uri}', event)" style="background:none; border:none; color:#ef4444; font-weight:bold; cursor:pointer; font-size:1.1rem; padding:0 4px;">&times;</button>
                    </div>
                `;
                container.appendChild(item);
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
            container.appendChild(empty);

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

    // POST /api/messenger/messages
    // Body: { content, channelIndex, ... }

    try {
        const payload = {
            content: content,
            channelIndex: currentChannelState.index,
            contentType: "ASAP_CHARACTER_SEQUENCE", // Optional default
            sign: true,
            encrypt: false
        };

        const response = await fetch('/snm-webapp/api/messenger/messages', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const result = await response.json();

        if (response.ok) {
            console.log('Message sent:', result);
            input.value = ''; // Clear input
            // Reload messages to see the new one
            // We need to wait a tiny bit perhaps? Or just reload immediately.
            loadMessages(currentChannelState.uri);
        } else {
            console.error('Send failed:', result);
            alert('Failed to send message: ' + (result.error || 'Unknown error'));
        }

    } catch (error) {
        console.error('Error sending message:', error);
        alert('Error sending message');
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
