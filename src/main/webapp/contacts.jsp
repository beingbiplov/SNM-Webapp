<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Peer Management - SharkNet</title>
        <link rel="stylesheet" href="css/style.css?v=3">
    </head>

    <body>
        <jsp:include page="header.jsp" />

        <div class="main-container">
            <% request.setAttribute("activePage", "contacts" ); %>
                <jsp:include page="sidebar.jsp" />

                <div class="content-wrapper">
                    <div class="page-container">
                        <div class="page-header">
                            <div>
                                <div class="page-title">Peer Management</div>
                                <div class="page-subtitle">Manage SharkNet peer instances and their status.</div>
                            </div>
                            <button class="btn-primary" onclick="createNewPeer()">Add New Peer</button>
                        </div>

                        <div class="card">
                            <input type="text" class="search-bar" placeholder="🔍 Search Peer ID or Name...">

                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Status</th>
                                        <th>Peer ID / Name</th>
                                        <th>Certificate Status</th>
                                        <th>Connection Type</th>

                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="contactsTableBody">
                                    <tr>
                                        <td colspan="5"
                                            style="text-align:center; padding:20px; color:var(--text-muted);">
                                            Loading peers...
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
        </div>

        <script>
            async function loadContacts() {
                const tableBody = document.getElementById('contactsTableBody');

                try {
                    const response = await fetch('api/peer');
                    if (!response.ok) throw new Error("Failed to fetch");

                    const peers = await response.json();
                    tableBody.innerHTML = ''; // Clear loading message

                    if (peers.length === 0) {
                        tableBody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 20px;">No peers found. Create one via API!</td></tr>';
                        return;
                    }

                    peers.forEach(peer => {
                        // Determine Status Badge
                        const statusBadge = peer.active
                            ? '<span class="badge badge-green">Active</span>'
                            : '<span class="badge badge-gray">Inactive</span>';

                        // Determine Connection Badge (Mock for now since API only gives basic info)
                        const connType = peer.active ? 'P2P' : 'N/A';

                        const row =
                            '<tr>' +
                            '<td>' + statusBadge + '</td>' +
                            '<td>' +
                            '<div style="font-weight:600; color:var(--text-main);">' + (peer.name || 'Unknown') + '</div>' +
                            '<div style="font-family:var(--font-mono); font-size:0.8em; color:var(--text-muted);">' + peer.peerId + '</div>' +
                            '</td>' +
                            '<td><span class="badge badge-blue">Self-Signed</span></td>' +
                            '<td>' + connType + '</td>' +

                            '<td style="display:flex; gap:8px;">' +
                            (peer.active
                                ? '<button class="btn-secondary" onclick="stopPeer(\'' + peer.peerId + '\')">Stop Peer</button>'
                                : '<button class="btn-primary" onclick="startPeer(\'' + peer.peerId + '\')">Start Peer</button>') +
                            '<button class="btn-outline-danger" onclick="deletePeer(\'' + peer.peerId + '\')" style="border:1px solid var(--red); color:var(--red); padding:8px 12px; border-radius:6px; background:white;">Delete</button>' +
                            '</td>' +
                            '</tr>';

                        tableBody.innerHTML += row;
                    });

                } catch (err) {
                    console.error(err);
                    tableBody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:red;">Error loading peers. Ensure backend is running.</td></tr>';
                }
            }

            async function startPeer(peerId) {
                try {
                    const res = await fetch('api/start/' + encodeURIComponent(peerId), { method: 'POST' });
                    if (res.ok) {
                        loadContacts();
                        location.reload();
                    } else {
                        const errorMsg = await res.text();
                        alert("Failed to start peer: " + errorMsg);
                    }
                } catch (e) {
                    console.error(e);
                    alert("Request failed: " + e.message);
                }
            }

            async function stopPeer(peerId) {
                try {
                    const res = await fetch('api/stop/' + encodeURIComponent(peerId), { method: 'POST' });
                    if (res.ok) {
                        loadContacts();
                        location.reload();
                    } else {
                        const errorMsg = await res.text();
                        alert("Failed to stop peer: " + errorMsg);
                    }
                } catch (e) {
                    console.error(e);
                    alert("Request failed: " + e.message);
                }
            }

            async function createNewPeer() {
                const name = prompt("Enter peer name:");
                if (!name) return;

                try {
                    const res = await fetch('api/peer', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ name: name })
                    });

                    if (res.ok) {
                        alert('Peer created!');
                        loadContacts();
                    } else {
                        const txt = await res.text();
                        alert('Error: ' + txt);
                    }
                } catch (err) {
                    alert('Request failed');
                }
            }

            async function deletePeer(peerId) {
                if (!confirm("Are you sure you want to delete this peer?")) return;

                try {
                    const res = await fetch('api/peer', {
                        method: 'DELETE',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ peerId: peerId })
                    });

                    if (res.ok) {
                        loadContacts();
                    } else {
                        alert("Failed to delete");
                    }
                } catch (e) {
                    console.error(e);
                }
            }

            // Load on page load
            document.addEventListener('DOMContentLoaded', loadContacts);
        </script>
    </body>

    </html>