<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login - SharkNet Messenger</title>
        <link rel="stylesheet" href="css/style.css?v=4">
        <style>
            .login-container {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 20px;
            }

            .login-card {
                background: white;
                border-radius: 16px;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                padding: 40px;
                width: 100%;
                max-width: 480px;
                text-align: center;
            }

            .app-title {
                font-family: 'JetBrains Mono', monospace;
                font-size: 2rem;
                font-weight: 700;
                color: var(--primary-color);
                margin-bottom: 12px;
            }

            .app-subtitle {
                color: var(--text-muted);
                margin-bottom: 32px;
                font-size: 0.95rem;
            }

            .login-form {
                text-align: left;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: var(--text-primary);
                font-family: 'JetBrains Mono', monospace;
                font-size: 0.9rem;
            }

            .form-input,
            .form-select {
                width: 100%;
                padding: 12px 16px;
                border: 2px solid #e5e7eb;
                border-radius: 8px;
                font-size: 0.95rem;
                transition: border-color 0.2s, box-shadow 0.2s;
                background: white !important;
                color: #1f2937 !important;
                font-family: 'JetBrains Mono', monospace;
                z-index: 10;
                -webkit-appearance: none;
                -moz-appearance: none;
                appearance: none;
            }

            .form-select option {
                background: white !important;
                color: #1f2937 !important;
                padding: 8px !important;
                z-index: 10 !important;
                border: none !important;
            }

            /* Force dropdown visibility */
            .form-select::-webkit-calendar-picker-indicator {
                background: transparent;
                bottom: 0;
                color: transparent;
                cursor: pointer;
                height: auto;
                left: 0;
                position: absolute;
                right: 0;
                top: 0;
                width: auto;
            }

            .form-input:focus,
            .form-select:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
            }

            /* Dark mode support for dropdown */
            @media (prefers-color-scheme: dark) {

                .form-input,
                .form-select {
                    background: #1f2937 !important;
                    color: white !important;
                    border-color: #374151;
                }

                .form-select option {
                    background: #1f2937 !important;
                    color: white !important;
                }
            }

            /* Ultra aggressive dropdown fix */
            select.form-select {
                background-color: white !important;
                color: #1f2937 !important;
            }

            select.form-select option {
                background-color: white !important;
                color: #1f2937 !important;
            }

            /* Override any inherited styles */
            * select.form-select option {
                background: white !important;
                color: #1f2937 !important;
            }

            /* Most aggressive fix - target all select options globally */
            option {
                background: white !important;
                color: #1f2937 !important;
                -webkit-appearance: none !important;
                -moz-appearance: none !important;
                appearance: none !important;
            }

            /* Force dropdown arrow visibility */
            .form-select {
                background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e") !important;
                background-repeat: no-repeat !important;
                background-position: right 0.5rem center !important;
                background-size: 1em !important;
                padding-right: 2.5rem !important;
            }

            /* Custom Dropdown Styles */
            .custom-dropdown {
                position: relative;
                width: 100%;
            }

            .dropdown-selected {
                width: 100%;
                padding: 12px 16px;
                border: 2px solid #e5e7eb;
                border-radius: 8px;
                background: white;
                color: #1f2937;
                font-size: 0.95rem;
                font-family: 'JetBrains Mono', monospace;
                cursor: pointer;
                display: flex;
                justify-content: space-between;
                align-items: center;
                transition: border-color 0.2s, box-shadow 0.2s;
            }

            .dropdown-selected:hover {
                border-color: #d1d5db;
            }

            .dropdown-selected:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
            }

            .dropdown-arrow {
                color: #6b7280;
                font-size: 0.8rem;
                transition: transform 0.2s;
            }

            .dropdown-options {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: white;
                border: 2px solid #e5e7eb;
                border-top: none;
                border-radius: 0 0 8px 8px;
                max-height: 200px;
                overflow-y: auto;
                z-index: 1000;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                display: none;
                /* Default to hidden, toggled by JS */
            }

            .dropdown-options.show {
                display: block !important;
            }

            .dropdown-option {
                padding: 12px 16px;
                color: #1f2937;
                font-size: 0.95rem;
                font-family: 'JetBrains Mono', monospace;
                cursor: pointer;
                border-bottom: 1px solid #f3f4f6;
                transition: background-color 0.2s;
                background: white;
                min-height: 20px;
                line-height: 1.4;
                display: block;
            }

            .dropdown-option:hover {
                background-color: #f8fafc;
            }

            .dropdown-option:last-child {
                border-bottom: none;
            }

            .btn-primary {
                width: 100%;
                padding: 14px 20px;
                background: var(--primary-color);
                color: white;
                border: none;
                border-radius: 8px;
                font-weight: 600;
                font-size: 0.95rem;
                cursor: pointer;
                transition: background-color 0.2s;
                font-family: 'JetBrains Mono', monospace;
            }

            .btn-primary:hover {
                background: #2563eb;
            }

            .btn-secondary {
                width: 100%;
                padding: 14px 20px;
                background: #f3f4f6;
                color: var(--text-primary);
                border: 2px solid #e5e7eb;
                border-radius: 8px;
                font-weight: 600;
                font-size: 0.95rem;
                cursor: pointer;
                transition: background-color 0.2s, border-color 0.2s;
                font-family: 'JetBrains Mono', monospace;
                margin-top: 12px;
            }

            .btn-secondary:hover {
                background: #e5e7eb;
                border-color: #d1d5db;
            }

            .divider {
                text-align: center;
                margin: 24px 0;
                position: relative;
            }

            .divider::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 0;
                right: 0;
                height: 1px;
                background: #e5e7eb;
            }

            .divider-text {
                background: white;
                padding: 0 16px;
                color: var(--text-muted);
                font-size: 0.85rem;
                font-family: 'JetBrains Mono', monospace;
            }

            .error-message {
                background: #fef2f2;
                color: #dc2626;
                padding: 12px;
                border-radius: 6px;
                margin-bottom: 20px;
                font-size: 0.9rem;
                border: 1px solid #fecaca;
            }

            .success-message {
                background: #f0fdf4;
                color: #16a34a;
                padding: 12px;
                border-radius: 6px;
                margin-bottom: 20px;
                font-size: 0.9rem;
                border: 1px solid #bbf7d0;
            }

            .loading {
                display: none;
                text-align: center;
                padding: 20px;
            }

            .spinner {
                border: 3px solid #f3f4f6;
                border-top: 3px solid var(--primary-color);
                border-radius: 50%;
                width: 24px;
                height: 24px;
                animation: spin 1s linear infinite;
                margin: 0 auto 12px;
            }

            @keyframes spin {
                0% {
                    transform: rotate(0deg);
                }

                100% {
                    transform: rotate(360deg);
                }
            }
        </style>
    </head>

    <body>
        <div class="login-container">
            <div class="login-card">
                <div class="app-title">🦈 SharkNet Messenger</div>
                <div class="app-subtitle">Decentralized Peer-to-Peer Communication</div>

                <div id="error-message" class="error-message" style="display: none;"></div>
                <div id="success-message" class="success-message" style="display: none;"></div>

                <div id="loading" class="loading">
                    <div class="spinner"></div>
                    <div>Processing...</div>
                </div>

                <div id="existing-peer-form" class="login-form">
                    <div class="form-group">
                        <label class="form-label">Select Existing Peer</label>
                        <div class="custom-dropdown">
                            <div class="dropdown-selected" onclick="toggleDropdown()">
                                <span id="selected-peer-text">-- Select a peer --</span>
                                <span class="dropdown-arrow">▼</span>
                            </div>
                            <div id="peer-dropdown-options" class="dropdown-options">
                                <!-- Options will be populated by JavaScript -->
                            </div>
                        </div>
                    </div>
                    <button type="button" class="btn-primary" onclick="selectExistingPeer()">
                        Continue with Selected Peer
                    </button>
                </div>

                <div class="divider">
                    <span class="divider-text">OR</span>
                </div>

                <!-- Create New Peer Form -->
                <div id="new-peer-form" class="login-form">
                    <div class="form-group">
                        <label class="form-label">Create New Peer</label>
                        <input type="text" id="peer-name" class="form-input" placeholder="Enter peer name..."
                            maxlength="50">
                    </div>
                    <button type="button" class="btn-primary" onclick="createNewPeer()">
                        Create New Peer
                    </button>
                </div>

                <button type="button" class="btn-secondary" onclick="refreshPeers()">
                    🔄 Refresh Peer List
                </button>
            </div>
        </div>

        <script src="js/login.js"></script>
    </body>

    </html>