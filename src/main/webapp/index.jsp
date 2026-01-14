<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <!DOCTYPE html>
  <html lang="en">

  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SharkNet Messenger</title>
    <link rel="stylesheet" href="css/style.css?v=4">
  </head>

  <body>
    <jsp:include page="header.jsp" />

    <div class="main-container">
      <% request.setAttribute("activePage", "messenger" ); %>
        <jsp:include page="sidebar.jsp" />

        <div class="content-wrapper">
          <div class="page-container">
            <!-- Main Header (Welcome Message) -->
            <div style="margin-bottom: 32px">
              <h1
                style="font-family: 'JetBrains Mono', monospace; font-size: 1.5rem; font-weight: 700; margin-bottom: 8px;">
                Welcome to SharkNetMessenger</h1>
              <p style="color: var(--text-muted);">Your decentralized research communication platform.</p>
            </div>

            
            <!-- <div class="messenger-grid">
        
              <div class="col-channels">
                <div style="font-weight: 700; margin-bottom: 20px; font-family: 'JetBrains Mono', monospace;">Channels /
                  Contacts</div>
                <div class="channel-item active">
                  <div class="status-dot dot-green"></div> #research-devs
                </div>
                <div class="channel-item">
                  <div class="status-dot dot-green"></div> #protocol-design
                </div>
                <div class="channel-item">
                  <div class="status-dot dot-yellow"></div> Dr. Ada Lovelace
                </div>
                <div class="channel-item">
                  <div class="status-dot dot-green"></div> Alan Turing
                </div>
                <div class="channel-item">
                  <div class="status-dot dot-yellow"></div> Grace Hopper
                </div>
                <div class="channel-item">
                  <div class="status-dot dot-yellow"></div> Vannevar Bush
                </div>
                <div class="channel-item">
                  <div class="status-dot dot-green"></div> Claude Shannon
                </div>
              </div>

            
              <div class="col-chat">
                <div style="font-weight: 700; margin-bottom: 20px; font-family: 'JetBrains Mono', monospace;">Message
                  View</div>

                <div class="chat-log">
                  <p>
                    <span class="chat-time">14:30:15 -</span>
                    <span class="chat-sender">You:</span><br>
                    Initiating data exchange protocol. All peers ready?
                  </p>
                  <p>
                    <span class="chat-time">14:30:22 -</span>
                    <span class="chat-sender">Dr. Ada Lovelace:</span><br>
                    Confirmed. Awaiting your signal to begin the transmission.
                  </p>
                  <p>
                    <span class="chat-time">14:30:30 -</span>
                    <span class="chat-sender">Grace Hopper:</span><br>
                    Ready on my end. Bandwidth utilization looks optimal.
                  </p>
                  <p>
                    <span class="chat-time">14:30:45 -</span>
                    <span class="chat-sender">You:</span><br>
                    Excellent. Sending batch #1. Monitor for any anomalies.
                  </p>
                  <p>
                    <span class="chat-time">14:31:01 -</span>
                    <span class="chat-sender">Dr. Ada Lovelace:</span><br>
                    Receiving batch #1. CRC checks passed. Initial analysis shows expected data integrity.
                  </p>
                  <p>
                    <span class="chat-time">14:31:05 -</span>
                    <span class="chat-sender">Grace Hopper:</span><br>
                    Acknowledged. Data stream stable.
                  </p>
                </div>

                <div class="chat-input-wrapper">
                  <textarea placeholder="Type your message here..."></textarea>
                  <button class="btn-primary" style="width: 100%;">Send Message</button>
                </div>
              </div>

          
              <div class="col-info">
                <div style="font-weight: 700; margin-bottom: 20px; font-family: 'JetBrains Mono', monospace;">Technical
                  Info</div>

                <span class="tech-label">Selected Peer ID:</span>
                <span class="tech-value">0x1A2B3C4D5E6F7A8B</span>

                <span class="tech-label">Routing Path:</span>
                <span class="tech-value">Local -> Peer A -> Peer B</span>

                <span class="tech-label">Encryption Status:</span>
                <span class="tech-value">AES-256 (E2EE) - Active</span>

                <span class="tech-label">Protocol Version:</span>
                <span class="tech-value">ASAP/1.0.3-beta</span>

                <span class="tech-label">Message Size (avg):</span>
                <span class="tech-value">1024 bytes</span>

                <span class="tech-label">Latency (last ping):</span>
                <span class="tech-value">25 ms</span>

                <span class="tech-label">Certificate Validity:</span>
                <span class="tech-value">2023-01-01 to 2024-01-01</span>

                <span class="tech-label">Session Start Time:</span>
                <span class="tech-value">14:28:00 UTC</span>

                <span class="tech-label">Active Channels:</span>
                <span class="tech-value">3</span>

                <span class="tech-label">Ephemeral Key Status:</span>
                <span class="tech-value">Refreshed</span>
              </div>
            </div> -->
          </div>
        </div>
    </div>
  </body>

  </html>