package net.sharksystem.web.api.peer;

import net.sharksystem.web.peer.PeerRuntimeManager;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.JsonObject;

import java.io.IOException;

/**
 * API for starting and stopping peers.
 *
 * POST /api/start/{peerId}
 * POST /api/stop/{peerId}
 */
@WebServlet(urlPatterns = {"/api/start/*", "/api/stop/*"})
public class PeerControlServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String servletPath = req.getServletPath(); // /api/start or /api/stop
        String pathInfo = req.getPathInfo();       // /{peerId}

        if (pathInfo == null || pathInfo.length() <= 1) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Missing peerId in URL");
            return;
        }

        String peerId = pathInfo.substring(1).trim();
        if (peerId.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Peer ID cannot be empty");
            return;
        }

        try {
            boolean success;
            boolean active;

            if ("/api/start".equals(servletPath)) {
                success = manager.startPeer(peerId);
                active = true;
            } else if ("/api/stop".equals(servletPath)) {
                success = manager.stopPeer(peerId);
                active = false;
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if (!success) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("Peer not found or invalid state");
                return;
            }

            JsonObject response = new JsonObject();
            response.addProperty("peerId", peerId);
            response.addProperty("active", active);

            resp.setContentType("application/json");
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(response.toString());

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(e.getMessage());
        }
    }
}
