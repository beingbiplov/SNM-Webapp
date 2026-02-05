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
                        <div class="page-subtitle">Manage PKI credentials, trust stores, and identity certificates.</div>
                    </div>
                    <div>
                        <button class="btn-secondary" onclick="showImportModal()">Import Certificate</button>
                        <button class="btn-primary" style="margin-left:8px;" onclick="refreshCertificates()">Refresh</button>
                    </div>
                </div>

                <!-- Your Identity Certificate -->
                <div class="card" style="margin-bottom: 24px;">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <div>
                            <div class="card-title" style="font-weight:600; font-size:1.1rem; margin-bottom:4px;">
                                Your Identity Certificate
                            </div>
                            <div style="color:var(--text-muted); font-size:0.9rem;">
                                Peer ID: <span id="your-peer-id" style="font-family:var(--font-mono); color:var(--text-main);">Loading...</span>
                            </div>
                        </div>
                        <button class="btn-secondary" onclick="exportOwnCertificate()">Export Public Key</button>
                    </div>
                </div>

                <!-- Pending Credentials -->
                <div class="card" style="margin-bottom: 24px;">
                    <div class="card-title" style="font-weight:600; font-size:1.1rem; margin-bottom:16px;">
                        Pending Credential Requests
                        <span id="pending-count" class="badge badge-yellow" style="margin-left:8px;">0</span>
                    </div>
                    <div id="pending-credentials-container">
                        <div style="text-align:center; padding:20px; color:var(--text-muted);">
                            No pending credential requests
                        </div>
                    </div>
                </div>

                <!-- Trusted Peer Certificates -->
                <div class="card">
                    <div class="card-title" style="font-weight:600; font-size:1.1rem; margin-bottom:16px;">
                        Trusted Peer Certificates
                    </div>
                    <input type="text" id="certificate-search" class="search-bar" placeholder="🔍 Search Certificates..." onkeyup="filterCertificates()">

                    <table class="data-table" id="certificates-table">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Issuer</th>
                                <th>Valid Until</th>
                                <th>Trust Level</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="certificates-tbody">
                            <tr>
                                <td colspan="5" style="text-align:center; padding:20px; color:var(--text-muted);">
                                    Loading certificates...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Import Certificate Modal -->
    <div id="import-modal" class="modal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Import Certificate</h3>
                <button class="modal-close" onclick="hideImportModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Peer Name/ID:</label>
                    <input type="text" id="import-peer-name" class="form-control" placeholder="Enter peer name or ID">
                </div>
                <div class="form-group">
                    <label>Message (optional):</label>
                    <textarea id="import-message" class="form-control" placeholder="Optional message to send with credentials"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" onclick="hideImportModal()">Cancel</button>
                <button class="btn-primary" onclick="sendCredentials()">Send Credentials</button>
            </div>
        </div>
    </div>

    <!-- Certificate Details Modal -->
    <div id="details-modal" class="modal" style="display: none;">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3>Certificate Details</h3>
                <button class="modal-close" onclick="hideDetailsModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div id="certificate-details">
                    <!-- Details will be populated here -->
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" onclick="hideDetailsModal()">Close</button>
            </div>
        </div>
    </div>

    <script src="js/certificates.js?v=1"></script>

    <style>
        .modal {
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal-content {
            background-color: var(--bg-card);
            margin: 5% auto;
            padding: 0;
            border-radius: 8px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .modal-header h3 {
            margin: 0;
            color: var(--text-main);
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: var(--text-muted);
        }

        .modal-close:hover {
            color: var(--text-main);
        }

        .modal-body {
            padding: 20px;
        }

        .modal-footer {
            padding: 20px;
            border-top: 1px solid var(--border-color);
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: var(--text-main);
        }

        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-family: var(--font-mono);
            font-size: 0.9rem;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
        }

        textarea.form-control {
            resize: vertical;
            min-height: 80px;
        }

        .badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge-green {
            background: #dcfce7;
            color: #16a34a;
        }

        .badge-yellow {
            background: #fef3c7;
            color: #d97706;
        }

        .btn-outline-danger {
            border: 1px solid var(--red);
            color: var(--red);
            padding: 8px 12px;
            border-radius: 6px;
            background: white;
            cursor: pointer;
            font-size: 0.8rem;
        }

        .btn-outline-danger:hover {
            background: var(--red);
            color: white;
        }
    </style>
</body>
</html>