<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Persons - SharkNet</title>
    <link rel="stylesheet" href="css/style.css?v=3">
    <link rel="stylesheet" href="css/persons.css?v=1">
</head>

<body>
    <jsp:include page="header.jsp" />

    <div class="main-container">
        <% request.setAttribute("activePage", "persons" ); %>
        <jsp:include page="sidebar.jsp" />

        <div class="content-wrapper">
            <div class="page-container">
                <div class="page-header">
                    <div>
                        <div class="page-title">Persons Management</div>
                        <div class="page-subtitle">Manage PKI identities, trust levels, and contact information.</div>
                    </div>
                    <div>
                        <button class="btn-primary" onclick="refreshPersons()">Refresh</button>
                    </div>
                </div>

                <!-- Persons Overview -->
                <div class="card persons-overview">
                    <div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                        <h3>Known Persons</h3>
                    </div>

                    <div class="overview-stats">
                        <div class="stat-item">
                            <div class="stat-number" id="total-persons">0</div>
                            <div class="stat-label">Total Persons</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number" id="trusted-persons">0</div>
                            <div class="stat-label">Trusted</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number" id="unknown-persons">0</div>
                            <div class="stat-label">Unknown</div>
                        </div>
                    </div>
                </div>

                <!-- Persons List -->
                <div class="card">
                    <div style="margin-bottom:20px; border-bottom:1px solid var(--border-color); padding-bottom:16px;">
                        <h3>All Persons</h3>
                    </div>

                    <input type="text" id="person-search" class="search-bar" placeholder="🔍 Search by name or ID..." onkeyup="filterPersons()">

                    <table class="data-table" id="persons-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Peer ID</th>
                                <th>Trust Level</th>
                                <th>Signing Rate</th>
                                <th>Identity Assurance</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="persons-tbody">
                            <tr>
                                <td colspan="6" class="loading-state">Loading persons...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Rename Person Modal -->
    <div id="rename-modal" class="modal hidden">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Rename Person</h3>
                <button class="modal-close" onclick="hideRenameModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Current Name:</label>
                    <input type="text" id="current-name" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <label>New Name:</label>
                    <input type="text" id="new-name" class="form-control" placeholder="Enter new name">
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" onclick="hideRenameModal()">Cancel</button>
                <button class="btn-primary" onclick="renamePerson()">Rename</button>
            </div>
        </div>
    </div>

    <!-- Person Details Modal -->
    <div id="details-modal" class="modal hidden">
        <div class="modal-content wide">
            <div class="modal-header">
                <h3>Person Details</h3>
                <button class="modal-close" onclick="hideDetailsModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div id="person-details">
                    <!-- Details will be populated here -->
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" onclick="hideDetailsModal()">Close</button>
            </div>
        </div>
    </div>

    <script src="js/persons.js?v=1"></script>
</body>

</html>
