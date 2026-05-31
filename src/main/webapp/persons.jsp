<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 640' fill='%233b82f6'%3E%3Cpath d='M474.6 188.1C495.3 203.7 520.6 218.8 548.8 222.6C561.9 224.4 574 215.1 575.8 202C577.6 188.9 568.3 176.8 555.2 175C539.3 172.9 522 163.7 503.5 149.8C465.1 120.8 413 120.8 374.5 149.8C350.5 167.9 333.8 176.1 320 176.1C306.2 176.1 289.5 167.9 265.5 149.8C227.1 120.8 175 120.8 136.5 149.8C118 163.7 100.7 172.9 84.8 175C71.7 176.8 62.4 188.8 64.2 202C66 215.2 78 224.4 91.2 222.6C119.4 218.8 144.8 203.7 165.4 188.1C186.7 172 215.3 172 236.6 188.1C260.8 206.4 288.9 224 320 224C351.1 224 379.1 206.3 403.4 188.1C424.7 172 453.3 172 474.6 188.1zM474.6 332.1C495.3 347.7 520.6 362.8 548.8 366.6C561.9 368.4 574 359.1 575.8 346C577.6 332.9 568.3 320.8 555.2 319C539.3 316.9 522 307.7 503.5 293.8C465.1 264.8 413 264.8 374.5 293.8C350.5 311.9 333.8 320.1 320 320.1C306.2 320.1 289.5 311.9 265.5 293.8C227.1 264.8 175 264.8 136.5 293.8C118 307.7 100.7 316.9 84.8 319C71.7 320.7 62.4 332.8 64.2 346C66 359.2 78 368.4 91.2 366.6C119.4 362.8 144.8 347.7 165.4 332.1C186.7 316 215.3 316 236.6 332.1C260.8 350.4 288.9 368 320 368C351.1 368 379.1 350.3 403.4 332.1C424.7 316 453.3 316 474.6 332.1zM403.4 476.1C424.7 460 453.3 460 474.6 476.1C495.3 491.7 520.6 506.8 548.8 510.6C561.9 512.4 574 503.1 575.8 490C577.6 476.9 568.3 464.8 555.2 463C539.3 460.9 522 451.7 503.5 437.8C465.1 408.8 413 408.8 374.5 437.8C350.5 455.9 333.8 464.1 320 464.1C306.2 464.1 289.5 455.9 265.5 437.8C227.1 408.8 175 408.8 136.5 437.8C118 451.7 100.7 460.9 84.8 463C71.7 464.8 62.4 476.8 64.2 490C66 503.2 78 512.4 91.2 510.6C119.4 506.8 144.8 491.7 165.4 476.1C186.7 460 215.3 460 236.6 476.1C260.8 494.4 288.9 512 320 512C351.1 512 379.1 494.3 403.4 476.1z'/%3E%3C/svg%3E">
    <title>Persons - SharkNet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { darkMode: 'class' }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "persons"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-6xl mx-auto space-y-4 md:space-y-6">

                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold">Persons Management</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Manage PKI identities, trust levels, and contact information.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshPersons()">
                        <i class="fas fa-sync-alt"></i> Refresh Data
                    </button>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                        <h3 class="text-lg font-bold">Known Persons Overview</h3>
                    </div>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col items-center justify-center border border-gray-100 dark:border-gray-700">
                            <div class="text-3xl font-bold text-blue-600 dark:text-blue-400" id="total-persons">0</div>
                            <div class="text-sm text-gray-500 dark:text-gray-400 mt-1 font-medium">Total Persons</div>
                        </div>
                        <div class="bg-green-50 dark:bg-green-900/20 rounded-lg p-4 flex flex-col items-center justify-center border border-green-100 dark:border-green-800/30">
                            <div class="text-3xl font-bold text-green-600 dark:text-green-400" id="trusted-persons">0</div>
                            <div class="text-sm text-green-600 dark:text-green-400 mt-1 font-medium">Trusted</div>
                        </div>
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col items-center justify-center border border-gray-100 dark:border-gray-700">
                            <div class="text-3xl font-bold text-gray-600 dark:text-gray-400" id="unknown-persons">0</div>
                            <div class="text-sm text-gray-500 dark:text-gray-400 mt-1 font-medium">Unknown</div>
                        </div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <h3 class="text-lg font-bold">All Persons</h3>
                        <div class="w-full sm:w-64 relative">
                            <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                            <input type="text" id="person-search" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg py-2 pl-10 pr-4 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow text-gray-900 dark:text-white" placeholder="Search name or ID..." onkeyup="filterPersons()">
                        </div>
                    </div>

                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap" id="persons-table">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">
                                <tr>
                                    <th class="px-6 py-4 font-semibold">Name</th>
                                    <th class="px-6 py-4 font-semibold">Peer ID</th>
                                    <th class="px-6 py-4 font-semibold text-center">Trust Level</th>
                                    <th class="px-6 py-4 font-semibold text-center">Signing Rate</th>
                                    <th class="px-6 py-4 font-semibold">Identity Assurance</th>
                                    <th class="px-6 py-4 font-semibold text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="persons-tbody" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="6" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Loading persons...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <div id="rename-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white">Rename Person</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideRenameModal()">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Current Name:</label>
                    <input type="text" id="current-name" class="w-full bg-gray-100 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed" readonly>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">New Name:</label>
                    <input type="text" id="new-name" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Enter new name">
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end gap-3">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideRenameModal()">Cancel</button>
                <button class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium shadow-sm transition-colors" onclick="renamePerson()">Rename</button>
            </div>
        </div>
    </div>

    <div id="details-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-2xl rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden max-h-[90vh]">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white">Person Details</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideDetailsModal()">&times;</button>
            </div>
            <div class="p-6 overflow-y-auto">
                <div id="person-details" class="text-sm text-gray-700 dark:text-gray-300 space-y-4">
                    </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideDetailsModal()">Close</button>
            </div>
        </div>
    </div>

    <script src="js/persons.js?v=2.0"></script>
</body>

</html>