<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Hub Connections - SharkNet</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .hub-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        @media (max-width: 768px) {
            .hub-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
    <jsp:include page="header.jsp" />

    <div class="main-container">
        <% request.setAttribute("activePage", "hubs"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="content-wrapper">
            <div class="page-container">
                <div class="page-header">
                    <div>
                        <div class="page-title">ASAP Hub Management</div>
                        <div class="page-subtitle">Connect and manage your ASAP Hub connections.</div>
                    </div>
                </div>

                <div class="hub-grid">
                    <!-- Connect to Remote Peer -->
                    <div class="card">
                        <div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                            <h3>Connect to Hub</h3>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Hub Address</label>
                            <input type="text" id="hubAddress" class="form-control" placeholder="e.g., 192.168.1.50 or hub.sharknet.org">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Port</label>
                            <input type="number" id="hubPort" class="form-control" placeholder="e.g., 9001">
                        </div>
                        <button class="btn-primary" onclick="connectNewHub()">Connect</button>
                    </div>

                    <!-- Open Local Port -->
                    <div class="card">
                        <div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                            <h3>Open Local Port</h3>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Port</label>
                            <input type="number" id="openPort" class="form-control" placeholder="e.g., 9001">
                        </div>
                        <button class="btn-primary" onclick="openLocalPort()">Open Port</button>
                    </div>
                </div>

                <!-- Active Hubs Dashboard -->
                <div class="card" style="margin-top: 20px;">
                    <div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px; display:flex; justify-content:space-between; align-items:center;">
                        <h3>Active Hub Connections</h3>
                        <button class="btn-secondary" style="padding:6px 12px; font-size:0.85rem;" onclick="loadActiveHubs()">🔄 Refresh</button>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Hub Address</th>
                                <th>Port</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="active-hubs-list">
                            <tr>
                                <td colspan="4" style="text-align: center; color: var(--text-muted);">Loading active connections...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </div>

    <script src="js/hubs.js?v=3.0"></script>
</body>

</html>
