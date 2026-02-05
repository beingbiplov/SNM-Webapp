<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Settings - SharkNet</title>
        <link rel="stylesheet" href="css/style.css?v=3">
        <link rel="stylesheet" href="css/settings.css?v=1">
    </head>

    <body>
        <jsp:include page="header.jsp" />

        <div class="main-container">
            <% request.setAttribute("activePage", "settings" ); %>
                <jsp:include page="sidebar.jsp" />

                <div class="content-wrapper">
                    <div class="page-container">
                        <div class="page-header">
                            <div>
                                <div class="page-title">Settings & Configuration</div>
                                <div class="page-subtitle">Manage peer configuration and application settings.</div>
                            </div>
                            <div>
                                <button class="btn-primary" onclick="saveSettings()">Save Changes</button>
                            </div>
                        </div>

                        <!-- Peer Status -->
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3>Peer Status</h3>
                            </div>

                            <div id="peer-status-content">
                                <div class="loading">Loading peer status...</div>
                            </div>
                        </div>

                        <!-- App Settings -->
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3>Application Settings</h3>
                            </div>

                            <!-- Hub settings disabled for future implementation
                    <div class="form-group">
                        <label class="form-label" style="display:flex; align-items:center;">
                            <input type="checkbox" id="rememberNewHubConnections">
                            Remember new hub connections
                        </label>
                        <div class="form-hint">Automatically save and reconnect to previously used hub connections.</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" style="display:flex; align-items:center;">
                            <input type="checkbox" id="hubReconnect">
                            Enable hub reconnection
                        </label>
                        <div class="form-hint">Automatically attempt to reconnect to hubs when connection is lost.</div>
                    </div>
                    -->
                        </div>

                        <!-- PKI Status -->
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3>PKI Status</h3>
                            </div>

                            <div id="pki-status-content">
                                <div class="loading">Loading PKI status...</div>
                            </div>
                        </div>

                        <!-- Network Status -->
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3>Network Status</h3>
                            </div>

                            <div id="network-status-content">
                                <div class="loading">Loading network status...</div>
                            </div>
                        </div>

                    </div>
                </div>
        </div>

        <script src="js/settings.js?v=1"></script>
    </body>

    </html>