<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    // Initialize peer manager and check for active peer session
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();

    // Redirect to login if no active peer is found
    if (activePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- SharkNet Tab Favicon -->
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 640' fill='%233b82f6'%3E%3Cpath d='M474.6 188.1C495.3 203.7 520.6 218.8 548.8 222.6C561.9 224.4 574 215.1 575.8 202C577.6 188.9 568.3 176.8 555.2 175C539.3 172.9 522 163.7 503.5 149.8C465.1 120.8 413 120.8 374.5 149.8C350.5 167.9 333.8 176.1 320 176.1C306.2 176.1 289.5 167.9 265.5 149.8C227.1 120.8 175 120.8 136.5 149.8C118 163.7 100.7 172.9 84.8 175C71.7 176.8 62.4 188.8 64.2 202C66 215.2 78 224.4 91.2 222.6C119.4 218.8 144.8 203.7 165.4 188.1C186.7 172 215.3 172 236.6 188.1C260.8 206.4 288.9 224 320 224C351.1 224 379.1 206.3 403.4 188.1C424.7 172 453.3 172 474.6 188.1zM474.6 332.1C495.3 347.7 520.6 362.8 548.8 366.6C561.9 368.4 574 359.1 575.8 346C577.6 332.9 568.3 320.8 555.2 319C539.3 316.9 522 307.7 503.5 293.8C465.1 264.8 413 264.8 374.5 293.8C350.5 311.9 333.8 320.1 320 320.1C306.2 320.1 289.5 311.9 265.5 293.8C227.1 264.8 175 264.8 136.5 293.8C118 307.7 100.7 316.9 84.8 319C71.7 320.7 62.4 332.8 64.2 346C66 359.2 78 368.4 91.2 366.6C119.4 362.8 144.8 347.7 165.4 332.1C186.7 316 215.3 316 236.6 332.1C260.8 350.4 288.9 368 320 368C351.1 368 379.1 350.3 403.4 332.1C424.7 316 453.3 316 474.6 332.1zM403.4 476.1C424.7 460 453.3 460 474.6 476.1C495.3 491.7 520.6 506.8 548.8 510.6C561.9 512.4 574 503.1 575.8 490C577.6 476.9 568.3 464.8 555.2 463C539.3 460.9 522 451.7 503.5 437.8C465.1 408.8 413 408.8 374.5 437.8C350.5 455.9 333.8 464.1 320 464.1C306.2 464.1 289.5 455.9 265.5 437.8C227.1 408.8 175 408.8 136.5 437.8C118 451.7 100.7 460.9 84.8 463C71.7 464.8 62.4 476.8 64.2 490C66 503.2 78 512.4 91.2 510.6C119.4 506.8 144.8 491.7 165.4 476.1C186.7 460 215.3 460 236.6 476.1C260.8 494.4 288.9 512 320 512C351.1 512 379.1 494.3 403.4 476.1z'/%3E%3C/svg%3E">
    <title>SharkNet Messenger</title>

    <style>
        /* Custom scrollbar styling for chat logs */
        .chat-scroll::-webkit-scrollbar { width: 6px; }
        .chat-scroll::-webkit-scrollbar-track { background: transparent; }
        .chat-scroll::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 20px; }
        .dark .chat-scroll::-webkit-scrollbar-thumb { background-color: #475569; }
    </style>
</head>

<body class="bg-gray-50 dark:bg-dark-bg text-gray-900 dark:text-gray-100 min-h-screen flex flex-col transition-colors duration-300">

    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row flex-1 relative">

        <% request.setAttribute("activePage", "messenger"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden relative">

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                <!-- Channels List -->
                <div class="lg:col-span-4 xl:col-span-3 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col h-[400px] lg:h-[calc(100vh-140px)]">

                    <div class="p-4 border-b border-gray-200 dark:border-dark-border flex justify-between items-center bg-gray-50 dark:bg-gray-800/50 rounded-t-xl">
                        <h3 class="font-bold text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-list-ul text-primary-500"></i> Channels
                        </h3>
                        <button onclick="showCreateChannelModal()" class="text-primary-500 hover:text-primary-600 transition-colors" title="Create Channel">
                            <i class="fas fa-plus-circle text-xl"></i>
                        </button>
                    </div>

                    <div id="channel-list" class="flex-1 overflow-y-auto chat-scroll p-4">
                        <div class="w-full text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-dark-card dark:border-dark-border dark:text-white shadow-sm" id="dynamic-channel-list">
                            <!-- Injected by JS -->
                        </div>
                    </div>
                </div>

                <!-- Chat Area -->
                <div class="lg:col-span-8 xl:col-span-6 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col h-[600px] lg:h-[calc(100vh-140px)] relative">

                    <!-- Chat Header with Advanced Search & Filters -->
                    <div class="p-4 border-b border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 rounded-t-xl flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3 relative">
                        <div>
                            <div class="font-bold text-lg text-gray-800 dark:text-white" id="current-channel-name">Select a channel</div>
                            <div class="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400 mt-1">
                                <span class="w-2 h-2 rounded-full bg-gray-400" id="status-indicator"></span>
                                <span id="current-channel-pki-status">Waiting for selection...</span>
                            </div>
                        </div>

                        <!-- Search Bar & Filters -->
                        <div class="relative w-full sm:w-auto flex items-center gap-2">
                            <div class="relative w-full sm:w-48 lg:w-64">
                                <i class="fas fa-search absolute left-3 top-2.5 text-gray-400 text-sm"></i>
                                <input type="text" id="message-search" class="w-full bg-white dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded-lg pl-9 pr-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow disabled:opacity-50 text-gray-900 dark:text-white" placeholder="Search text..." disabled onkeyup="applyFilters()">
                            </div>
                            <button id="filter-toggle-btn" class="p-1.5 text-gray-500 hover:text-primary-500 dark:text-gray-400 dark:hover:text-primary-400 disabled:opacity-50 transition-colors" disabled onclick="toggleFilterPanel()" title="Advanced Filters">
                                <i class="fas fa-sliders-h"></i>
                            </button>

                            <!-- Filter Dropdown Panel -->
                            <div id="filter-panel" class="hidden absolute right-0 top-full mt-2 w-72 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-lg shadow-xl z-50 p-4 space-y-3">
                                <h4 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2 border-b border-gray-100 dark:border-dark-border pb-1">Filters</h4>
                                <div>
                                    <label class="block text-xs text-gray-700 dark:text-gray-300 mb-1">Sender Name</label>
                                    <input type="text" id="filter-sender" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded px-2 py-1 text-sm outline-none focus:ring-1 focus:ring-primary-500 text-gray-900 dark:text-white" placeholder="e.g. Yigit" onkeyup="applyFilters()">
                                </div>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <label class="block text-xs text-gray-700 dark:text-gray-300 mb-1">From Date</label>
                                        <input type="date" id="filter-date-start" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded px-2 py-1 text-[11px] outline-none focus:ring-1 focus:ring-primary-500 text-gray-900 dark:text-white" onchange="applyFilters()">
                                    </div>
                                    <div>
                                        <label class="block text-xs text-gray-700 dark:text-gray-300 mb-1">To Date</label>
                                        <input type="date" id="filter-date-end" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded px-2 py-1 text-[11px] outline-none focus:ring-1 focus:ring-primary-500 text-gray-900 dark:text-white" onchange="applyFilters()">
                                    </div>
                                </div>
                                <div class="pt-2 flex justify-end">
                                    <button onclick="clearFilters()" class="text-xs text-primary-500 hover:text-primary-600 font-medium">Clear Filters</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Chat Log -->
                    <div class="flex-1 overflow-y-auto chat-scroll p-4 bg-gray-50/50 dark:bg-dark-bg/50 relative" id="chat-log">
                        <div class="flex flex-col items-center justify-center h-full text-center space-y-3 opacity-60">
                            <i class="fas fa-comments text-5xl text-primary-500"></i>
                            <h3 class="text-xl font-bold">Welcome to SharkNet Messenger</h3>
                            <p class="text-sm">Select a channel from the left to start messaging</p>
                        </div>
                    </div>

                    <!-- Input Area -->
                    <div class="p-3 border-t border-gray-200 dark:border-dark-border bg-white dark:bg-dark-card rounded-b-xl relative z-10">
                        <div class="flex flex-wrap items-center gap-4 mb-2 text-sm">
                            <select id="message-receiver" class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-dark-border text-gray-700 dark:text-gray-300 rounded px-2 py-1 outline-none focus:ring-1 focus:ring-primary-500 cursor-pointer">
                                <option value="ANY_SHARKNET_PEER">Anyone</option>
                            </select>

                            <div class="flex items-center gap-4">
                                <label class="flex items-center gap-1.5 cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 transition-colors">
                                    <input type="checkbox" id="sign-message" checked class="rounded border-gray-300 text-primary-500 focus:ring-primary-500">
                                    <span><i class="fas fa-signature text-xs"></i> Sign</span>
                                </label>
                                <label class="flex items-center gap-1.5 cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 transition-colors">
                                    <input type="checkbox" id="encrypt-message" class="rounded border-gray-300 text-primary-500 focus:ring-primary-500">
                                    <span><i class="fas fa-lock text-xs"></i> Encrypt</span>
                                </label>
                            </div>
                        </div>

                        <div class="flex gap-2 items-end">
                            <textarea id="message-input" rows="2" class="flex-1 resize-none border border-gray-300 dark:border-dark-border rounded-lg p-2 text-sm bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500" placeholder="Type your message here..."></textarea>

                            <!-- Action Buttons Container -->
                            <div class="flex flex-col gap-1" id="action-buttons-container">
                                <button id="send-btn" onclick="sendMessage()" class="bg-primary-500 hover:bg-primary-600 text-white rounded-lg px-4 h-[52px] font-bold flex flex-col items-center justify-center gap-1 transition-colors shadow-sm min-w-[70px]">
                                    <i class="fas fa-paper-plane text-base"></i>
                                    <span class="text-xs">Send</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Side Stats -->
                <div class="hidden xl:block xl:col-span-3 space-y-6 h-auto lg:h-[calc(100vh-140px)] overflow-y-auto chat-scroll pr-2 pb-6">
                    <div class="bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm p-4">
                        <h4 class="font-bold border-b border-gray-100 dark:border-dark-border pb-2 mb-3 text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-server text-gray-400"></i> Peer Info
                        </h4>
                        <div class="space-y-3 text-sm">
                            <div class="flex flex-col gap-1">
                                <span class="text-gray-500 dark:text-gray-400 text-xs uppercase tracking-wider font-semibold">Peer ID</span>
                                <span class="font-mono text-gray-800 dark:text-gray-200 break-all bg-gray-50 dark:bg-gray-800/50 p-2 rounded border border-gray-100 dark:border-dark-border"><%= activePeer !=null ? activePeer.getPeerID() : "Unknown" %></span>
                            </div>
                            <div class="flex justify-between items-center pt-2">
                                <span class="text-gray-500 dark:text-gray-400">Status</span>
                                <span class="px-2 py-1 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 rounded-md text-xs font-bold">Active</span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm p-4">
                        <h4 class="font-bold border-b border-gray-100 dark:border-dark-border pb-2 mb-3 text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-chart-pie text-gray-400"></i> Statistics
                        </h4>
                        <div class="space-y-3 text-sm">
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Channels</span>
                                <span id="active-channel-count" class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded">0</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Open Ports</span>
                                <span class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded"><%= activePeer !=null ? activePeer.getOpenSockets().size() : 0 %></span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Connections</span>
                                <span class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded"><%= activePeer !=null ? activePeer.getActiveConnections().size() : 0 %></span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Create Channel Modal -->
    <div id="create-channel-form" class="fixed inset-0 z-50 bg-gray-900/50 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-dark-card w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-dark-border flex flex-col overflow-hidden animate-[fadeIn_0.2s_ease-out]" onclick="event.stopPropagation()">
            <div class="p-4 border-b border-gray-200 dark:border-dark-border flex justify-between items-center bg-gray-50 dark:bg-gray-800/50">
                <h3 class="font-bold text-lg text-gray-800 dark:text-white"><i class="fas fa-satellite-dish mr-2 text-primary-500"></i>Create Channel</h3>
                <button onclick="hideCreateChannelModal()" class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="p-6 space-y-5">
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300">Channel URI <span class="text-red-500">*</span></label>
                    <input type="text" id="new-channel-uri" class="w-full border border-gray-300 dark:border-dark-border rounded-lg p-2.5 bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 outline-none font-mono text-sm transition-shadow" placeholder="e.g. shark://my-channel">
                </div>
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300">Display Name (optional)</label>
                    <input type="text" id="new-channel-name" class="w-full border border-gray-300 dark:border-dark-border rounded-lg p-2.5 bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 outline-none text-sm transition-shadow" placeholder="e.g. My Secret Channel">
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 flex justify-end gap-3">
                <button onclick="hideCreateChannelModal()" class="px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 font-medium transition-colors">Cancel</button>
                <button onclick="createChannel()" class="px-4 py-2 bg-primary-500 hover:bg-primary-600 text-white rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2">
                    <i class="fas fa-check"></i> Create
                </button>
            </div>
        </div>
    </div>

    <!-- Message Context Menu -->
    <div id="message-context-menu" class="hidden fixed z-[100] w-48 bg-white dark:bg-dark-card rounded-lg shadow-xl border border-gray-200 dark:border-dark-border py-1 text-sm transition-opacity duration-200 opacity-0 pointer-events-none">
        <button onclick="triggerEditFromMenu()" class="w-full text-left px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-700 dark:text-gray-300 flex items-center gap-2 transition-colors">
            <i class="fas fa-edit text-blue-500 w-4"></i> Edit Message
        </button>
        <button onclick="triggerDeleteFromMenu()" class="w-full text-left px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-800 text-red-600 dark:text-red-400 flex items-center gap-2 transition-colors">
            <i class="fas fa-trash text-red-500 w-4"></i> Delete Message
        </button>
    </div>

    <script src="js/messenger.js?v=35"></script>

</body>

</html>