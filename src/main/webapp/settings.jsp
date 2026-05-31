<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 640' fill='%233b82f6'%3E%3Cpath d='M474.6 188.1C495.3 203.7 520.6 218.8 548.8 222.6C561.9 224.4 574 215.1 575.8 202C577.6 188.9 568.3 176.8 555.2 175C539.3 172.9 522 163.7 503.5 149.8C465.1 120.8 413 120.8 374.5 149.8C350.5 167.9 333.8 176.1 320 176.1C306.2 176.1 289.5 167.9 265.5 149.8C227.1 120.8 175 120.8 136.5 149.8C118 163.7 100.7 172.9 84.8 175C71.7 176.8 62.4 188.8 64.2 202C66 215.2 78 224.4 91.2 222.6C119.4 218.8 144.8 203.7 165.4 188.1C186.7 172 215.3 172 236.6 188.1C260.8 206.4 288.9 224 320 224C351.1 224 379.1 206.3 403.4 188.1C424.7 172 453.3 172 474.6 188.1zM474.6 332.1C495.3 347.7 520.6 362.8 548.8 366.6C561.9 368.4 574 359.1 575.8 346C577.6 332.9 568.3 320.8 555.2 319C539.3 316.9 522 307.7 503.5 293.8C465.1 264.8 413 264.8 374.5 293.8C350.5 311.9 333.8 320.1 320 320.1C306.2 320.1 289.5 311.9 265.5 293.8C227.1 264.8 175 264.8 136.5 293.8C118 307.7 100.7 316.9 84.8 319C71.7 320.7 62.4 332.8 64.2 346C66 359.2 78 368.4 91.2 366.6C119.4 362.8 144.8 347.7 165.4 332.1C186.7 316 215.3 316 236.6 332.1C260.8 350.4 288.9 368 320 368C351.1 368 379.1 350.3 403.4 332.1C424.7 316 453.3 316 474.6 332.1zM403.4 476.1C424.7 460 453.3 460 474.6 476.1C495.3 491.7 520.6 506.8 548.8 510.6C561.9 512.4 574 503.1 575.8 490C577.6 476.9 568.3 464.8 555.2 463C539.3 460.9 522 451.7 503.5 437.8C465.1 408.8 413 408.8 374.5 437.8C350.5 455.9 333.8 464.1 320 464.1C306.2 464.1 289.5 455.9 265.5 437.8C227.1 408.8 175 408.8 136.5 437.8C118 451.7 100.7 460.9 84.8 463C71.7 464.8 62.4 476.8 64.2 490C66 503.2 78 512.4 91.2 510.6C119.4 506.8 144.8 491.7 165.4 476.1C186.7 460 215.3 460 236.6 476.1C260.8 494.4 288.9 512 320 512C351.1 512 379.1 494.3 403.4 476.1z'/%3E%3C/svg%3E">
    <title>Settings - SharkNet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { darkMode: 'class' }
    </script>
</head>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "settings"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-4xl mx-auto space-y-4 md:space-y-6">

                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold">Settings & Configuration</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Manage peer configuration and application settings.</p>
                    </div>
                    <div class="w-full sm:w-auto">
                        <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="saveSettings()">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                        <h3 class="text-lg font-bold">Peer Status</h3>
                    </div>
                    <div id="peer-status-content">
                        <div class="animate-pulse text-gray-500 dark:text-gray-400 text-sm">Loading peer status...</div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4 md:mb-6">
                        <h3 class="text-lg font-bold">Application Settings</h3>
                    </div>

                    <h4 class="font-semibold text-base mb-4 text-gray-800 dark:text-gray-200">Message Defaults</h4>
                    <div class="space-y-4 mb-6">
                        <label class="inline-flex items-center cursor-pointer">
                            <input type="checkbox" id="defaultSignMsg" class="sr-only peer">
                            <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                            <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Sign messages by default</span>
                        </label>
                        <br> <label class="inline-flex items-center cursor-pointer mt-2">
                            <input type="checkbox" id="defaultEncryptMsg" class="sr-only peer">
                            <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                            <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Encrypt messages by default</span>
                        </label>
                    </div>

                    <hr class="border-gray-100 dark:border-gray-700 my-6">

                    <h4 class="font-semibold text-base mb-4 text-gray-800 dark:text-gray-200">Hub Connection Settings</h4>
                    <div class="space-y-5 mb-6">
                        <div>
                            <label class="inline-flex items-center cursor-pointer">
                                <input type="checkbox" id="rememberNewHubConnections" class="sr-only peer">
                                <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                                <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Remember new hub connections</span>
                            </label>
                            <div class="text-xs sm:text-sm text-gray-500 dark:text-gray-400 ml-14 mt-1">
                                Automatically save and reconnect to previously used hub connections.
                            </div>
                        </div>

                        <div>
                            <label class="inline-flex items-center cursor-pointer">
                                <input type="checkbox" id="hubReconnect" class="sr-only peer">
                                <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                                <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Enable hub reconnection</span>
                            </label>
                            <div class="text-xs sm:text-sm text-gray-500 dark:text-gray-400 ml-14 mt-1">
                                Automatically attempt to reconnect to hubs when connection is lost.
                            </div>
                        </div>
                    </div>

                    <hr class="border-gray-100 dark:border-gray-700 my-6">

                    <h4 class="font-semibold text-base mb-3 text-gray-800 dark:text-gray-200">Display Preferences</h4>
                    <div class="mb-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Peer Display Name Customization</label>
                        <input type="text" id="customDisplayName" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="Enter custom display name...">
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 w-full overflow-hidden">
                        <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                            <h3 class="text-lg font-bold">PKI Status</h3>
                        </div>
                        <div id="pki-status-content" class="w-full">
                            <div class="animate-pulse text-gray-500 dark:text-gray-400 text-sm">Loading PKI status...</div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 w-full overflow-hidden">
                        <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                            <h3 class="text-lg font-bold">Network Status</h3>
                        </div>
                        <div id="network-status-content" class="w-full">
                            <div class="animate-pulse text-gray-500 dark:text-gray-400 text-sm">Loading network status...</div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="js/settings.js?v=6"></script>
</body>

</html>