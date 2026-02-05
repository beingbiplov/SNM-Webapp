<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!-- We use a request attribute 'activePage' to highlight the current link -->
    <nav class="sidebar">
        <a href="index.jsp" class="nav-item ${activePage == 'messenger' ? 'active' : ''}">
            <span class="nav-icon">💬</span> Messenger
        </a>
        <a href="contacts.jsp" class="nav-item ${activePage == 'contacts' ? 'active' : ''}">
            <span class="nav-icon">👥</span> Peer
        </a>
        <a href="persons.jsp" class="nav-item ${activePage == 'persons' ? 'active' : ''}">
            <span class="nav-icon">👤</span> Persons
        </a>
        <a href="certificates.jsp" class="nav-item ${activePage == 'certificates' ? 'active' : ''}">
            <span class="nav-icon">🔑</span> Certificates
        </a>
        <a href="network.jsp" class="nav-item ${activePage == 'network' ? 'active' : ''}">
            <span class="nav-icon">🌐</span> Network Status
        </a>
        <a href="settings.jsp" class="nav-item ${activePage == 'settings' ? 'active' : ''}">
            <span class="nav-icon">⚙️</span> Settings
        </a>

        <div class="footer-info">
            <p>ASAP Protocol v1.0</p>
            <p>Secure & Decentralized</p>
        </div>
    </nav>