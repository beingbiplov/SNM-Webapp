<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Network Overview - SharkNet</title>
        <link rel="stylesheet" href="css/style.css?v=5">
        <style>
            .network-section {
                margin-bottom: 32px;
            }

            .section-title {
                font-size: 1.25rem;
                font-weight: 700;
                margin-bottom: 20px;
                color: var(--text-main);
            }

            .status-line {
                display: flex;
                align-items: center;
                gap: 8px;
                color: var(--text-muted);
                margin-bottom: 20px;
                font-size: 0.95rem;
            }

            .form-group {
                margin-bottom: 16px;
            }

            .form-label {
                display: block;
                font-weight: 600;
                font-size: 0.9rem;
                margin-bottom: 6px;
            }

            .form-control {
                width: 100%;
                border: 1px solid var(--border-color);
                border-radius: 6px;
                padding: 10px 12px;
                font-family: var(--font-mono);
                font-size: 0.9rem;
            }

            .active-ports-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 12px;
            }

            .active-ports-table th {
                text-align: left;
                padding: 12px;
                border-bottom: 1px solid var(--border-color);
                color: var(--text-muted);
                font-size: 0.8rem;
                text-transform: uppercase;
            }

            .active-ports-table td {
                padding: 12px;
                border-bottom: 1px solid var(--border-color);
                font-size: 0.9rem;
            }

            .status-footer {
                margin-top: 40px;
                padding-top: 20px;
                border-top: 1px solid var(--border-color);
                display: flex;
                align-items: center;
                gap: 8px;
                color: var(--text-muted);
                font-size: 0.85rem;
            }
        </style>
    </head>

    <body>
        <jsp:include page="header.jsp" />

        <div class="main-container">
            <% request.setAttribute("activePage", "network" ); %>
                <jsp:include page="sidebar.jsp" />

                <div class="content-wrapper">
                    <div class="page-container">
                        <h1 class="page-title" style="margin-bottom: 24px;">Network Overview</h1>

                        <!-- Hub Connections -->
                        <div class="card network-section">
                            <div class="section-title">Hub Connections</div>
                            <div class="status-line">
                                <span style="font-size: 1.2rem;">🌐</span>
                                <span id="hubStatusText">Awaiting peer status...</span>
                            </div>
                            <div style="display: flex; gap: 12px;">
                                <button class="btn-primary" onclick="alert('Hub connection triggered')">Connect to
                                    Hub</button>
                                <button class="btn-secondary" onclick="alert('Hub sync triggered')">Sync Hub</button>
                            </div>
                        </div>

                        <!-- Direct TCP Connections -->
                        <div class="card network-section">
                            <div class="section-title">Direct TCP Connections</div>

                            <div style="font-weight: 700; margin-bottom: 16px;">Listen on New Port</div>
                            <div class="form-group" style="display: flex; gap: 12px; align-items: flex-end;">
                                <div style="flex: 1;">
                                    <label class="form-label">Port Number</label>
                                    <input type="number" id="newTcpPort" class="form-control" placeholder="e.g., 8080"
                                        value="8080">
                                </div>
                                <button class="btn-primary" onclick="openTcpPort()" style="height: 40px;">Open
                                    Port</button>
                            </div>

                            <div class="info-section-divider" style="margin: 24px 0;"></div>

                            <div style="font-weight: 700; margin-bottom: 16px;">Connect to Peer</div>
                            <div class="form-group">
                                <label class="form-label">Peer Address</label>
                                <input type="text" id="peerAddress" class="form-control"
                                    placeholder="e.g., 192.168.1.100">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Port</label>
                                <input type="number" id="peerPort" class="form-control" placeholder="e.g., 8080">
                            </div>
                            <button class="btn-primary" onclick="connectToPeer()">Connect</button>
                        </div>

                        <!-- Active TCP Ports -->
                        <div class="card network-section">
                            <div class="section-title">Active TCP Ports</div>
                            <table class="active-ports-table">
                                <thead>
                                    <tr>
                                        <th>Port</th>
                                        <th>Status</th>
                                        <th style="text-align: right;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="activePortsList">
                                    <tr>
                                        <td colspan="3" style="text-align: center; color: var(--text-muted);">Loading
                                            active ports...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Network Status Footer -->
                        <div class="status-footer">
                            <span style="font-size: 1rem;">📶</span>
                            <span>Network Status: All systems operational</span>
                        </div>
                    </div>
                </div>
        </div>

        <script>
            function refreshData() {
                if (!window.currentActivePeerId) return;

                const peerId = window.currentActivePeerId;

                // Load Hub Status
                fetch("/snm-webapp/api/peer/status/" + peerId)
                    .then(r => r.json())
                    .then(data => {
                        const statusText = document.getElementById('hubStatusText');
                        if (data.hubConnections) {
                            const count = data.hubConnections.hubsConnected || 0;
                            statusText.innerText = count > 0
                                ? `Connected to ${count} Hub(s) (ASAP Protocol active)`
                                : "No hubs connected. System is in P2P mode.";
                        }
                    });

                // Load TCP Ports
                fetch('/snm-webapp/api/tcp/list', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ peerId: peerId })
                })
                    .then(r => r.json())
                    .then(data => {
                        const list = document.getElementById('activePortsList');
                        list.innerHTML = "";
                        if (data.openPorts && data.openPorts.length > 0) {
                            data.openPorts.forEach(port => {
                                const tr = document.createElement('tr');
                                tr.innerHTML =
                                    '<td>' + port + '</td>' +
                                    '<td><span class="badge badge-green">Listening</span></td>' +
                                    '<td style="text-align: right;">' +
                                    '<button class="btn-secondary" style="color: var(--red); border-color: var(--red); padding: 4px 8px; font-size: 0.8rem;" onclick="closePort(' + port + ')">Close</button>' +
                                    '</td>';
                                list.appendChild(tr);
                            });
                        } else {
                            list.innerHTML = '<tr><td colspan="3" style="text-align: center; color: var(--text-muted);">No active TCP ports.</td></tr>';
                        }
                    });
            }

            function openTcpPort() {
                const portInput = document.getElementById('newTcpPort');
                const port = portInput.value;
                if (!port) {
                    alert("Please enter a port number.");
                    return;
                }

                fetch('/snm-webapp/api/tcp/open', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        peerId: window.currentActivePeerId,
                        port: parseInt(port)
                    })
                }).then(r => r.json()).then(data => {
                    alert(data.msg);
                    refreshData();
                });
            }

            function connectToPeer() {
                const host = document.getElementById('peerAddress').value;
                const port = document.getElementById('peerPort').value;

                if (!host || !port) {
                    alert("Please enter both address and port.");
                    return;
                }

                fetch('/snm-webapp/api/tcp/connect', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        peerId: window.currentActivePeerId,
                        host: host,
                        port: parseInt(port)
                    })
                }).then(r => {
                    if (r.ok) return r.json();
                    throw new Error("Connection failed");
                }).then(data => {
                    alert(data.msg);
                    refreshData();
                }).catch(err => {
                    alert(err.message);
                });
            }

            function closePort(port) {
                if (!confirm(`Are you sure you want to close port ${port}?`)) return;

                fetch('/snm-webapp/api/tcp/close', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ peerId: window.currentActivePeerId, port: port })
                }).then(r => r.json()).then(data => {
                    alert(data.msg);
                    refreshData();
                });
            }

            // Init
            window.addEventListener('peerReady', () => refreshData());
            // Fallback if peer was already ready
            setTimeout(() => { if (window.currentActivePeerId) refreshData(); }, 500);
        </script>
    </body>

    </html>