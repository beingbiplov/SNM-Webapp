<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Settings - SharkNet</title>
        <link rel="stylesheet" href="css/style.css?v=3">
    </head>

    <body>
        <jsp:include page="header.jsp" />

        <div class="main-container">
            <% request.setAttribute("activePage", "settings" ); %>
                <jsp:include page="sidebar.jsp" />

                <!-- <div class="content-wrapper">
                    <div class="page-container">
                        <div class="page-header">
                            <div>
                                <div class="page-title">Settings & Configuration</div>
                                <div class="page-subtitle">Adjust application parameters for network, security, and UI.
                                </div>
                            </div>
                        </div>

                     
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3 style="font-size:1.1rem; font-weight:600;">Network Settings</h3>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Default Network Mode</label>
                                <select
                                    style="width:100%; padding:10px 12px; border:1px solid var(--border-color); border-radius:6px; background:white;">
                                    <option value="internet">Internet</option>
                                    <option value="adhoc">Ad-hoc Wi-Fi</option>
                                    <option value="bluetooth">Bluetooth</option>
                                </select>
                                <div class="form-hint">Choose how SharkNetMessenger connects to peers.</div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Peer Discovery Mechanism</label>
                                <input type="text" value="DNS-SD, DHT" disabled style="background:#f3f4f6;">
                                <div class="form-hint">Comma-separated list of discovery methods.</div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Listen Port</label>
                                <input type="number" value="9800">
                            </div>
                        </div>

                    
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3 style="font-size:1.1rem; font-weight:600;">PKI & Security Settings</h3>
                            </div>

                            <div class="form-group">
                                <label class="form-label" style="display:flex; align-items:center;">
                                    <input type="checkbox" checked style="margin-right:10px; width:auto;">
                                    Auto-verify new certificates
                                </label>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Default Key Algorithm</label>
                                <input type="text" value="RSA-4096">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Trust Store Path</label>
                                <input type="text" value="/etc/sharknet/trust">
                            </div>
                        </div>

                 
                        <div class="card settings-section">
                            <div
                                style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                                <h3 style="font-size:1.1rem; font-weight:600;">Configuration Management</h3>
                            </div>

                            <div style="display:flex; gap:12px;">
                                <button class="btn-secondary">Export Configuration</button>
                                <button class="btn-secondary">Import Configuration</button>
                                <button class="btn-danger" style="margin-left:auto;">Reset to Defaults</button>
                            </div>
                        </div>

                    </div>
                </div> -->
        </div>
    </body>

    </html>