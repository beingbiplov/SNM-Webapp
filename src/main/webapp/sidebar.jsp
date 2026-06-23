<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        <a href="hubs.jsp" class="nav-item ${activePage == 'hubs' ? 'active' : ''}">
            <span class="nav-icon">📡</span> ASAP Hubs
        </a>
        <a href="settings.jsp" class="nav-item ${activePage == 'settings' ? 'active' : ''}">
            <span class="nav-icon">⚙️</span> Settings
        </a>
    </nav>