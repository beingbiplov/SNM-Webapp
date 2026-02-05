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
          <link rel="stylesheet" href="css/messenger-enhanced.css?v=1">
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
                        <textarea id="message-input" class="message-input" placeholder="Type your message here..."></textarea>
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
                          <span class="info-value"><%= activePeer !=null ? activePeer.getPeerID() : "Unknown" %></span>
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
                        <div class="info-item">
                          <span class="info-label">Total Messages:</span>
                          <span class="info-value" id="total-messages">0</span>
                        </div>
                      </div>
                      
                      <div class="info-section">
                        <h4>Security Settings</h4>
                        <div class="info-item">
                          <span class="info-label">Default Signing:</span>
                          <span class="info-value">Enabled</span>
                        </div>
                        <div class="info-item">
                          <span class="info-label">Default Encryption:</span>
                          <span class="info-value">Disabled</span>
                        </div>
                      </div>
                      
                      <div class="info-section">
                        <h4>Protocol Information</h4>
                        <div class="info-item">
                          <span class="info-label">Protocol:</span>
                          <span class="info-value">ASAP/1.0</span>
                        </div>
                        <div class="info-item">
                          <span class="info-label">Encryption:</span>
                          <span class="info-value">E2EE Available</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <script src="js/messenger.js?v=13"></script>
        </body>

        </html>