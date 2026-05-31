<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 640' fill='%233b82f6'%3E%3Cpath d='M474.6 188.1C495.3 203.7 520.6 218.8 548.8 222.6C561.9 224.4 574 215.1 575.8 202C577.6 188.9 568.3 176.8 555.2 175C539.3 172.9 522 163.7 503.5 149.8C465.1 120.8 413 120.8 374.5 149.8C350.5 167.9 333.8 176.1 320 176.1C306.2 176.1 289.5 167.9 265.5 149.8C227.1 120.8 175 120.8 136.5 149.8C118 163.7 100.7 172.9 84.8 175C71.7 176.8 62.4 188.8 64.2 202C66 215.2 78 224.4 91.2 222.6C119.4 218.8 144.8 203.7 165.4 188.1C186.7 172 215.3 172 236.6 188.1C260.8 206.4 288.9 224 320 224C351.1 224 379.1 206.3 403.4 188.1C424.7 172 453.3 172 474.6 188.1zM474.6 332.1C495.3 347.7 520.6 362.8 548.8 366.6C561.9 368.4 574 359.1 575.8 346C577.6 332.9 568.3 320.8 555.2 319C539.3 316.9 522 307.7 503.5 293.8C465.1 264.8 413 264.8 374.5 293.8C350.5 311.9 333.8 320.1 320 320.1C306.2 320.1 289.5 311.9 265.5 293.8C227.1 264.8 175 264.8 136.5 293.8C118 307.7 100.7 316.9 84.8 319C71.7 320.7 62.4 332.8 64.2 346C66 359.2 78 368.4 91.2 366.6C119.4 362.8 144.8 347.7 165.4 332.1C186.7 316 215.3 316 236.6 332.1C260.8 350.4 288.9 368 320 368C351.1 368 379.1 350.3 403.4 332.1C424.7 316 453.3 316 474.6 332.1zM403.4 476.1C424.7 460 453.3 460 474.6 476.1C495.3 491.7 520.6 506.8 548.8 510.6C561.9 512.4 574 503.1 575.8 490C577.6 476.9 568.3 464.8 555.2 463C539.3 460.9 522 451.7 503.5 437.8C465.1 408.8 413 408.8 374.5 437.8C350.5 455.9 333.8 464.1 320 464.1C306.2 464.1 289.5 455.9 265.5 437.8C227.1 408.8 175 408.8 136.5 437.8C118 451.7 100.7 460.9 84.8 463C71.7 464.8 62.4 476.8 64.2 490C66 503.2 78 512.4 91.2 510.6C119.4 506.8 144.8 491.7 165.4 476.1C186.7 460 215.3 460 236.6 476.1C260.8 494.4 288.9 512 320 512C351.1 512 379.1 494.3 403.4 476.1z'/%3E%3C/svg%3E">
    <title>Network Overview - SharkNet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { darkMode: 'class' }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "network"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold">Network Overview</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Manage direct TCP connections and open ports.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshData()">
                        <i class="fas fa-sync-alt"></i> Refresh Network
                    </button>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <h3 class="text-lg font-bold border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">Direct TCP Connections</h3>

                    <div class="mb-6">
                        <h4 class="font-semibold text-gray-800 dark:text-gray-200 mb-3 text-sm md:text-base">Listen on New Port</h4>
                        <div class="flex flex-col sm:flex-row gap-3 items-end">
                            <div class="w-full sm:flex-1">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Port Number</label>
                                <input type="number" id="newTcpPort" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 8080" value="8080">
                            </div>
                            <button class="w-full sm:w-auto bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white font-medium py-2.5 px-5 rounded-lg transition-colors flex justify-center items-center" onclick="openTcpPort()">
                                Open Port
                            </button>
                        </div>
                    </div>

                    <hr class="border-gray-100 dark:border-gray-700 my-6">

                    <div>
                        <h4 class="font-semibold text-gray-800 dark:text-gray-200 mb-3 text-sm md:text-base">Connect to Peer</h4>
                        <div class="flex flex-col sm:flex-row gap-3 items-end">

                            <div class="w-full sm:flex-[3]">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Peer Address</label>
                                <input type="text" id="peerAddress" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., localhost" value="localhost">
                            </div>

                            <div class="w-full sm:flex-[2]">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Port</label>
                                <input type="number" id="peerPort" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 8080">
                            </div>

                            <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg transition-colors flex justify-center items-center" onclick="connectToPeer()">
                                Connect
                            </button>

                        </div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-lg font-bold">Active TCP Ports</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold">Port</th>
                                    <th class="px-6 py-4 font-semibold">Status</th>
                                    <th class="px-6 py-4 font-semibold text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="activePortsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Loading active ports...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-lg font-bold">Established Connections</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold">Remote Address</th>
                                    <th class="px-6 py-4 font-semibold">Remote Port</th>
                                    <th class="px-6 py-4 font-semibold">Status</th>
                                </tr>
                            </thead>
                            <tbody id="activeConnectionsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Loading connections...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 py-4 justify-center md:justify-start">
                    <i class="fas fa-signal text-green-500"></i>
                    <span>Network Status: All systems operational</span>
                </div>
            </div>
        </div>
    </div>

    <script>
        /**
         * Fetches and refreshes the network data (ports and connections)
         * @return {void}
         */
        function refreshData() {
            if (!window.currentActivePeerId) return;

            const peerId = window.currentActivePeerId;

            // Load TCP Ports from Backend
            fetch('/snm-webapp/api/tcp/list', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ peerId: peerId })
            })
            .then(r => r.json())
            .then(data => {
                // 1. Update Active Ports Table
                const list = document.getElementById('activePortsList');
                list.innerHTML = "";

                if (data.openPorts && data.openPorts.length > 0) {
                    data.openPorts.forEach(port => {
                        const tr = document.createElement('tr');
                        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";

                        tr.innerHTML = `
                            <td class="px-6 py-4 font-mono font-medium">${port}</td>
                            <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">Listening</span></td>
                            <td class="px-6 py-4 text-right">
                                <button class="px-3 py-1.5 text-xs bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 rounded transition-colors font-medium" onclick="closePort(${port})">Close</button>
                            </td>
                        `;
                        list.appendChild(tr);
                    });
                } else {
                    list.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">No active TCP ports.</td></tr>';
                }

                // 2. Update Established Connections Table
                const connList = document.getElementById('activeConnectionsList');
                connList.innerHTML = "";

                if (data.connections && data.connections.length > 0) {
                    data.connections.forEach(conn => {
                        const tr = document.createElement('tr');
                        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";

                        tr.innerHTML = `
                            <td class="px-6 py-4 font-mono">${conn.remoteAddress || 'Unknown'}</td>
                            <td class="px-6 py-4 font-mono">${conn.remotePort || '-'}</td>
                            <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-bold rounded-full">Connected</span></td>
                        `;
                        connList.appendChild(tr);
                    });
                } else {
                    connList.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">No outgoing connections visible.</td></tr>';
                }
            })
            .catch(err => console.error("Error refreshing network data:", err));
        }

        /**
         * Opens a new TCP port
         * @return {void}
         */
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
            }).catch(err => {
                alert("Error opening port: " + err.message);
            });
        }

        /**
         * Connects to a remote peer via IP/Port
         * @return {void}
         */
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

        /**
         * Closes a currently listening port
         * @param {number} port - The port number to close
         * @return {void}
         */
        function closePort(port) {
            if (!confirm(`Are you sure you want to close port ${port}?`)) return;

            fetch('/snm-webapp/api/tcp/close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ peerId: window.currentActivePeerId, port: port })
            }).then(r => r.json()).then(data => {
                alert(data.msg);
                refreshData();
            }).catch(err => {
                alert("Error closing port: " + err.message);
            });
        }

        // Initialize Data on Page Load
        window.addEventListener('peerReady', () => refreshData());

        // Fallback if peer was already ready
        setTimeout(() => { if (window.currentActivePeerId) refreshData(); }, 500);
    </script>
</body>

</html>