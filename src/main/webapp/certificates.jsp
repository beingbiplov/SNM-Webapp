<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Certificates - SharkNet</title>
    <link rel="stylesheet" href="css/style.css?v=3">
    <link rel="stylesheet" href="css/certificates.css?v=1">
</head>

<body>
    <jsp:include page="header.jsp" />

    <div class="main-container">
        <% request.setAttribute("activePage", "certificates" ); %>
        <jsp:include page="sidebar.jsp" />

        <div class="content-wrapper">
            <div class="page-container">
                <div class="page-header certificates-header">
                    <div>
                        <div class="page-title">Certificate Management</div>
                        <div class="page-subtitle">Manage PKI credentials, trust stores, and identity certificates.</div>
                    </div>
                    <div>
                        <button class="btn-secondary" onclick="showImportModal()">Import Certificate</button>
                        <button class="btn-primary" onclick="refreshCertificates()">Refresh</button>
                    </div>
                </div>

                <!-- Your Identity Certificate -->
                <div class="card identity-section">
                    <div class="identity-header">
                        <div>
                            <div class="card-title identity-title">Your Identity Certificate</div>
                            <div class="identity-peer-id">
                                Peer ID: <span id="your-peer-id">Loading...</span>
                            </div>
                        </div>
                        <button class="btn-secondary" onclick="exportOwnCertificate()">Export Public Key</button>
                    </div>
                </div>

                <!-- Pending Credentials -->
                <div class="card pending-section">
                    <div class="card-title pending-title">
                        Pending Credential Requests
                        <span id="pending-count" class="badge badge-yellow pending-count">0</span>
                    </div>
                    <div id="pending-credentials-container">
                        <div class="pending-empty">No pending credential requests</div>
                    </div>
                </div>

                <!-- Advanced Certificate Filtering -->
                <div class="card">
                    <div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                        <h3>Advanced Filtering</h3>
                    </div>

                    <div class="filter-controls">
                        <div class="filter-group">
                            <label>Filter by:</label>
                            <select id="filter-type" class="form-control" onchange="onFilterTypeChange()">
                                <option value="all">All Certificates</option>
                                <option value="issuer">By Issuer</option>
                                <option value="subject">By Subject</option>
                                <option value="trust">By Trust Level</option>
                            </select>
                        </div>

                        <div class="filter-group" id="issuer-filter" style="display:none;">
                            <label>Issuer:</label>
                            <select id="issuer-select" class="form-control">
                                <option value="">All Issuers</option>
                            </select>
                        </div>

                        <div class="filter-group" id="subject-filter" style="display:none;">
                            <label>Subject:</label>
                            <select id="subject-select" class="form-control">
                                <option value="">All Subjects</option>
                            </select>
                        </div>

                        <div class="filter-group" id="trust-filter" style="display:none;">
                            <label>Trust Level:</label>
                            <select id="trust-select" class="form-control">
                                <option value="">All Levels</option>
                                <option value="0">Unknown</option>
                                <option value="1">Self-Signed</option>
                                <option value="2">Verified</option>
                                <option value="3">Highly Verified</option>
                            </select>
                        </div>

                        <div class="filter-actions">
                            <button class="btn-primary" onclick="applyFilter()">Apply Filter</button>
                            <button class="btn-secondary" onclick="clearFilter()">Clear</button>
                        </div>
                    </div>
                </div>

                <!-- Trusted Peer Certificates -->
                <div class="card trusted-section">
                    <div class="card-title">Trusted Peer Certificates</div>
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
                                <td colspan="5" class="loading-state">Loading certificates...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Revoke Certificate Modal -->
    <div id="revoke-modal" class="modal hidden">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Revoke Certificate</h3>
                <button class="modal-close" onclick="hideRevokeModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Subject ID:</label>
                    <input type="text" id="revoke-subject-id" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <label>Certificate Subject:</label>
                    <input type="text" id="revoke-subject-name" class="form-control" readonly>
                </div>
                <div class="warning-message">
                    <strong>⚠️ Warning:</strong> This action cannot be undone. The certificate will be revoked and can no longer be used for verification.
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" onclick="hideRevokeModal()">Cancel</button>
                <button class="btn-danger" onclick="revokeCertificate()">Revoke Certificate</button>
            </div>
        </div>
    </div>

    <!-- Import Certificate Modal -->
    <div id="import-modal" class="modal hidden">
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
    <div id="details-modal" class="modal hidden">
        <div class="modal-content wide">
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
</body>
</html>