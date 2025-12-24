<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>SharkNet – Peers</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 40px;
      }

      h1 {
        margin-bottom: 10px;
      }

      button {
        padding: 6px 12px;
        margin-bottom: 20px;
        cursor: pointer;
      }

      table {
        border-collapse: collapse;
        width: 100%;
        max-width: 800px;
      }

      th,
      td {
        border: 1px solid #ddd;
        padding: 10px;
      }

      th {
        background-color: #f5f5f5;
        text-align: left;
      }

      .active {
        color: green;
        font-weight: bold;
      }

      .inactive {
        color: red;
        font-weight: bold;
      }
    </style>
  </head>
  <body>
    <h1>SharkNet Peers</h1>
    <p>List of peers known to the system.</p>

    <button onclick="loadPeers()">Refresh</button>

    <table>
      <thead>
        <tr>
          <th>Peer Name</th>
          <th>Peer ID</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody id="peerTableBody">
        <!-- rows added dynamically -->
      </tbody>
    </table>

    <script>
      async function loadPeers() {
        const tableBody = document.getElementById("peerTableBody");
        tableBody.innerHTML = "<tr><td colspan='3'>Loading...</td></tr>";

        try {
          const response = await fetch("/snm-webapp/api/peer");
          const peers = await response.json();

          tableBody.innerHTML = "";

          if (!peers || peers.length === 0) {
            tableBody.innerHTML = "<tr><td colspan='3'>No peers found</td></tr>";
            return;
          }

          peers.forEach((peer) => {
            const row = document.createElement("tr");

            const nameCell = document.createElement("td");
            nameCell.textContent = peer.name;

            const idCell = document.createElement("td");
            idCell.textContent = peer.peerId;

            const statusCell = document.createElement("td");
            statusCell.textContent = peer.active ? "ACTIVE" : "INACTIVE";
            statusCell.className = peer.active ? "active" : "inactive";

            row.appendChild(nameCell);
            row.appendChild(idCell);
            row.appendChild(statusCell);

            tableBody.appendChild(row);
          });
        } catch (err) {
          tableBody.innerHTML = "<tr><td colspan='3'>Failed to load peers</td></tr>";
          console.error(err);
        }
      }

      // Load peers on page load
      loadPeers();
    </script>
  </body>
</html>
