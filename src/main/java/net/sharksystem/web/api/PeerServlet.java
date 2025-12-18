package net.sharksystem.web.api;

import net.sharksystem.web.peer.PeerRuntimeManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;

/**
 * API for managing peers.
 */
@WebServlet("/api/peer")
public class PeerServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Read raw body (plain text)
        String peerName;
        try (BufferedReader reader = req.getReader()) {
            peerName = reader.readLine();
        }

        if (peerName == null || peerName.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Peer name required in request body");
            return;
        }

        try {
            manager.createPeer(peerName.trim());
            resp.setStatus(HttpServletResponse.SC_CREATED);
            resp.getWriter().write("Peer created: " + peerName);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write(e.getMessage());
        }
    }
}
