package net.sharksystem.web.api;

import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.web.peer.PeerRuntimeManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collection;
import java.io.BufferedReader;

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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Collection<PeerRuntime> peers = manager.listPeers();

        resp.setContentType("application/json");
        resp.setStatus(HttpServletResponse.SC_OK);

        StringBuilder json = new StringBuilder();
        json.append("[");

        boolean first = true;
        for (PeerRuntime peer : peers) {
            if (!first) {
                json.append(",");
            }
            first = false;

            json.append("{")
                .append("\"name\":\"").append(peer.getPeerName()).append("\",")
                .append("\"peerId\":\"").append(peer.getPeerID()).append("\"")
                .append("}");
        }

        json.append("]");
        resp.getWriter().write(json.toString());
    }
}
