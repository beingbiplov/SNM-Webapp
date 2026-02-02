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
        </head>

        <body>
          <jsp:include page="header.jsp" />

          <div class="main-container">
            <% request.setAttribute("activePage", "messenger" ); %>
              <jsp:include page="sidebar.jsp" />

              <div class="content-wrapper">
                <div class="page-container">
                  <!-- Main Header (Welcome Message) -->
                  <div style="margin-bottom: 16px">
                    <h1
                      style="font-family: 'JetBrains Mono', monospace; font-size: 1.5rem; font-weight: 700; margin-bottom: 8px;">
                      Welcome to SharkNetMessenger
                    </h1>
                    <p style="color: var(--text-muted);">Your decentralized research communication platform.</p>
                  </div>

                  <div class="messenger-grid">
                    <!-- 1. Channels Col -->
                    <div class="col-channels" id="channel-list">
                      <div style="text-align: center; padding: 20px; color: #666;">
                        Loading channels...
                      </div>
                    </div>

                    <!-- 2. Chat Col -->
                    <div class="col-chat">
                      <div class="chat-header">
                        <span id="current-channel-name">Select a channel</span>
                        <span id="current-channel-pki-status"
                          style="font-size: 0.8rem; font-weight: normal; color: #666;"></span>
                      </div>

                      <div class="chat-log" id="chat-log">
                        <div
                          style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: #999;">
                          <p>Select a channel from the left to view messages.</p>
                        </div>
                      </div>

                      <div class="chat-input-wrapper">
                        <textarea id="message-input" placeholder="Type your message here..."></textarea>
                        <button id="send-btn" class="btn-primary" style="width: 100%;" onclick="sendMessage()">Send
                          Message</button>
                      </div>
                    </div>

                    <!-- 3. Info Col -->
                    <div class="col-info">
                      <div
                        style="font-weight: 700; margin-bottom: 20px; font-family: 'JetBrains Mono', monospace; color: #6b7280;">
                        Technical Info
                      </div>

                      <span class="tech-label">Selected Peer ID:</span>
                      <span class="tech-value">
                        <%= activePeer !=null ? activePeer.getPeerID() : "Unknown" %>
                      </span>

                      <span class="tech-label">Active Channels:</span>
                      <!-- We can update this via JS or just count initial ones. For now, let's leave it static or updated by JS if we want perfect sync. -->
                      <span class="tech-value" id="active-channel-count">Loading...</span>

                      <%-- <!-- Commented out as per user request to keep only available info -->
                        <span class="tech-label">Routing Path:</span>
                        <span class="tech-value">Local -> Peer A -> Peer B</span>

                        <span class="tech-label">Encryption Status:</span>
                        <span class="tech-value">AES-256 (E2EE) - Active</span>

                        <span class="tech-label">Protocol Version:</span>
                        <span class="tech-value">ASAP/1.0.3-beta</span>

                        <span class="tech-label">Certificate Validity:</span>
                        <span class="tech-value">2023-01-01 to 2024-01-01</span>

                        <span class="tech-label">Session Start Time:</span>
                        <span class="tech-value">14:28:00 UTC</span>

                        <span class="tech-label">Ephemeral Key Status:</span>
                        <span class="tech-value">Refreshed</span>
                        --%>
                    </div>
                  </div>
                </div>
              </div>
              <script src="js/messenger.js?v=13"></script>
        </body>

        </html>