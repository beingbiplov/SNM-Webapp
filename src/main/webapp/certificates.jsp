<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Certificates - SharkNet</title>
        <link rel="stylesheet" href="css/style.css?v=3">
    </head>

    <body>
        <jsp:include page="header.jsp" />

        <div class="main-container">
            <% request.setAttribute("activePage", "certificates" ); %>
                <jsp:include page="sidebar.jsp" />

                <div class="content-wrapper">
                    <div class="page-container">
                        <div class="page-header">
                            <div>
                                <div class="page-title">Certificate Management</div>
                                <div class="page-subtitle">Manage PKI credentials, trust stores, and identity
                                    certificates.</div>
                            </div>
                            <div>
                                <button class="btn-secondary">Import Certificate</button>
                                <button class="btn-primary" style="margin-left:8px;">Generate New</button>
                            </div>
                        </div>

                      
                        <!-- <div class="card">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <div>
                                    <div class="card-title"
                                        style="font-weight:600; font-size:1.1rem; margin-bottom:4px;">Your Identity
                                        Certificate</div>
                                    <div style="color:var(--text-muted); font-size:0.9rem;">Fingerprint: <span
                                            style="font-family:var(--font-mono); color:var(--text-main);">0x1A2B3C4D5E6F7A8B</span>
                                    </div>
                                </div>
                                <button class="btn-secondary">Export Public Key</button>
                            </div>
                        </div>

                      
                        <div class="card">
                            <div class="card-title" style="font-weight:600; font-size:1.1rem; margin-bottom:16px;">
                                Trusted Peer Certificates</div>
                            <input type="text" class="search-bar" placeholder="🔍 Search Certificates...">

                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Subject</th>
                                        <th>Issuer</th>
                                        <th>Valid Until</th>
                                        <th>Trust Level</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><span style="font-family:var(--font-mono)">sn_peer_alice_123</span></td>
                                        <td>SharkNet CA</td>
                                        <td>2025-12-31</td>
                                        <td><span class="badge badge-green">Trusted</span></td>
                                        <td>
                                            <button class="btn-secondary">Details</button>
                                            <button class="btn-outline-danger"
                                                style="margin-left:8px; border:1px solid var(--red); color:var(--red); padding:8px 12px; border-radius:6px; background:white;">Revoke</button>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span style="font-family:var(--font-mono)">sn_peer_bob_456</span></td>
                                        <td>SharkNet CA</td>
                                        <td>2024-06-30</td>
                                        <td><span class="badge badge-green">Trusted</span></td>
                                        <td>
                                            <button class="btn-secondary">Details</button>
                                            <button class="btn-outline-danger"
                                                style="margin-left:8px; border:1px solid var(--red); color:var(--red); padding:8px 12px; border-radius:6px; background:white;">Revoke</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div> -->
                    </div>
                </div>
        </div>
    </body>

    </html>