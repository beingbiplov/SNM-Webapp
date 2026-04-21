<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
    <%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
      <% PeerRuntimeManager manager=PeerRuntimeManager.getInstance(); PeerRuntime activePeer=manager.getActivePeer(); if
        (activePeer==null) { response.sendRedirect("login.jsp"); return; } %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>SharkNet Messenger</title>
          <link rel="stylesheet" href="css/style.css?v=8">
          <link rel="stylesheet" href="css/messenger.css?v=2">
        </head>

        <body>
          <jsp:include page="header.jsp" />

          <div class="main-container">
            <% request.setAttribute("activePage", "messenger" ); %>
              <jsp:include page="sidebar.jsp" />

              <div class="content-wrapper">
                <div class="messenger-grid">
                  <!-- Channels Column -->
                  <div class="col-channels" id="channel-list">
                    <div class="channels-header">
                      <h3>Channels</h3>
                    </div>
                    <div class="channel-list">
                      <div style="text-align: center; padding: 20px; color: #666;">
                        Loading channels...
                      </div>
                    </div>
                  </div>

                  <!-- Chat Column -->
                  <div class="col-chat">
                    <div class="chat-header">
                      <div class="chat-title" id="current-channel-name">Select a channel</div>
                      <div class="chat-subtitle">
                        <div class="chat-status">
                          <span class="status-dot"></span>
                          <span id="current-channel-pki-status">Ready</span>
                        </div>
                      </div>
                    </div>

                    <div class="chat-log" id="chat-log">
                      <div class="chat-welcome">
                        <div class="chat-welcome-icon">💬</div>
                        <h3>Welcome to SharkNet Messenger</h3>
                        <p>Select a channel from the left to start messaging</p>
                      </div>
                    </div>

                    <div class="chat-input-wrapper">
                      <div class="message-options">
                        <select id="message-receiver" class="recipient-select">
                          <option value="ANY_SHARKNET_PEER">Anyone</option>
                        </select>
                        <div class="security-options">
                          <div class="security-option">
                            <input type="checkbox" id="sign-message" checked>
                            <label for="sign-message">🔐 Sign</label>
                          </div>
                          <div class="security-option">
                            <input type="checkbox" id="encrypt-message">
                            <label for="encrypt-message">🔒 Encrypt</label>
                          </div>
                        </div>
                      </div>
                      <div class="message-input-container">
                        <textarea id="message-input" class="message-input"
                          placeholder="Type your message here..."></textarea>
                        <button id="send-btn" class="send-button" onclick="sendMessage()">Send</button>
                      </div>
                    </div>
                  </div>

                  <!-- Info Column -->
                  <div class="col-info">
                    <div class="info-header">
                      <h3>Technical Info</h3>
                    </div>
                    <div class="info-content">
                      <div class="info-section">
                        <h4>Peer Information</h4>
                        <div class="info-item">
                          <span class="info-label">Peer ID:</span>
                          <span class="info-value">
                            <%= activePeer !=null ? activePeer.getPeerID() : "Unknown" %>
                          </span>
                        </div>
                        <div class="info-item">
                          <span class="info-label">Status:</span>
                          <span class="info-value">Active</span>
                        </div>
                      </div>

                      <div class="info-section">
                        <h4>Channel Statistics</h4>
                        <div class="info-item">
                          <span class="info-label">Active Channels:</span>
                          <span class="info-value" id="active-channel-count">Loading...</span>
                        </div>
                      </div>

                      <div class="info-section">
                        <h4>Network Status</h4>
                        <div class="info-item">
                          <span class="info-label">Open Ports:</span>
                          <span class="info-value">
                            <%= activePeer !=null ? activePeer.getOpenSockets().size() : 0 %>
                          </span>
                        </div>
                        <div class="info-item">
                          <span class="info-label">Active Connections:</span>
                          <span class="info-value">
                            <%= activePeer !=null ? activePeer.getActiveConnections().size() : 0 %>
                          </span>
                        </div>
                      </div>

                      <div class="info-section">
                        <h4>Identity Key</h4>
                        <div class="info-item">
                          <span class="info-label">Fingerprint:</span>
                          <span class="info-value"
                            title="<%= activePeer != null ? activePeer.getPublicKeyFingerprint() : "" %>">
                            <% String fp=activePeer !=null ? activePeer.getPublicKeyFingerprint() : "" ; if
                              (fp.length()> 16) fp = fp.substring(0, 8) + "..." + fp.substring(fp.length() - 8);
                              %>
                              <%= fp %>
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
          </div>
          </div>
          <script src="js/messenger.js?v=13"></script>
          <div id="create-channel-form" class="modal hidden"
            style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.5);">
            <div class="modal-content"
              style="background:var(--bg-card); margin:10% auto; padding:20px; border-radius:8px; width:90%; max-width:400px; box-shadow:0 4px 20px rgba(0,0,0,0.3);">
              <div class="modal-header"
                style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--border-color); padding-bottom:10px; margin-bottom:20px;">
                <h3 style="margin:0;">Create Channel</h3>
                <button onclick="hideCreateChannelModal()"
                  style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-muted);">&times;</button>
              </div>
              <div class="modal-body">
                <div class="form-group" style="margin-bottom:15px;">
                  <label style="display:block; margin-bottom:5px; font-weight:600;">Channel URI:</label>
                  <input type="text" id="new-channel-uri" class="form-control" placeholder="e.g. shark://my-channel"
                    style="width:100%; padding:8px; border:1px solid var(--border-color); border-radius:4px;">
                </div>
                <div class="form-group" style="margin-bottom:15px;">
                  <label style="display:block; margin-bottom:5px; font-weight:600;">Name (optional):</label>
                  <input type="text" id="new-channel-name" class="form-control" placeholder="My Channel"
                    style="width:100%; padding:8px; border:1px solid var(--border-color); border-radius:4px;">
                </div>
              </div>
              <div class="modal-footer"
                style="display:flex; justify-content:flex-end; gap:10px; border-top:1px solid var(--border-color); padding-top:15px;">
                <button onclick="hideCreateChannelModal()" class="btn-secondary">Cancel</button>
                <button onclick="createChannel()" class="btn-primary">Create</button>
              </div>
            </div>
          </div>
          <script src="js/messenger.js?v=14"></script>
        </body>

        </html>