package net.sharksystem.web.api;

import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.web.peer.PeerRuntimeManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

import java.io.IOException;
import java.util.Collection;
import java.io.BufferedReader;

/**
 * API for managing peers.
 */
@WebServlet("/api/peer/*")
public class PeerServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    /**
     * CREATE peer
     * POST /api/peer
     * Body: { "name": "alice" }
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        JsonObject body;

        try (BufferedReader reader = req.getReader()) {
            body = gson.fromJson(reader, JsonObject.class);
        } catch (JsonSyntaxException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Invalid JSON body");
            return;
        }

        // Type + presence check
        if (body == null || !body.has("name") || !body.get("name").isJsonPrimitive()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Missing or invalid 'name'");
            return;
        }

        String peerName = body.get("name").getAsString().trim();
        if (peerName.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Peer name cannot be empty");
            return;
        }

        try {
            PeerRuntime peer = manager.createPeer(peerName);

            JsonObject response = new JsonObject();
            response.addProperty("name", peer.getPeerName());
            response.addProperty("peerId", peer.getPeerID().toString());

            resp.setStatus(HttpServletResponse.SC_CREATED);
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write(e.getMessage());
        }
    }

    /**
     * LIST peers OR GET peer by ID
     *
     * GET /api/peer
     * GET /api/peer/{peerId}
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {

            Collection<PeerRuntime> peers = manager.listPeers();

            resp.setContentType("application/json");
            resp.setStatus(HttpServletResponse.SC_OK);

            var array = new com.google.gson.JsonArray();
            for (PeerRuntime peer : peers) {
                JsonObject obj = new JsonObject();
                obj.addProperty("name", peer.getPeerName());
                obj.addProperty("peerId", peer.getPeerID().toString());
                obj.addProperty("active", peer.isActive());
                array.add(obj);
            }

            resp.getWriter().write(array.toString());
            return;
        }

        String peerId = pathInfo.substring(1); // remove leading "/"

        if (peerId.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Peer ID required");
            return;
        }

        PeerRuntime peer = manager.getPeer(peerId);

        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("Peer not found");
            return;
        }

        JsonObject obj = new JsonObject();
        obj.addProperty("name", peer.getPeerName());
        obj.addProperty("peerId", peer.getPeerID().toString());

        resp.setContentType("application/json");
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(obj.toString());
    }

    /**
     * DELETE peer
     * DELETE /api/peer
     * Body: { "peerId": "alice_xxx" }
     */
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        JsonObject body;

        try (BufferedReader reader = req.getReader()) {
            body = gson.fromJson(reader, JsonObject.class);
        } catch (JsonSyntaxException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Invalid JSON body");
            return;
        }

        // Type + presence check
        if (body == null || !body.has("peerId") || !body.get("peerId").isJsonPrimitive()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Missing or invalid 'peerId'");
            return;
        }

        String peerID = body.get("peerId").getAsString().trim();
        if (peerID.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Peer ID cannot be empty");
            return;
        }

        try {
            boolean removed = manager.removePeer(peerID);

            if (removed) {
                resp.setStatus(HttpServletResponse.SC_OK);
                resp.getWriter().write("Peer stopped: " + peerID);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("Peer not found: " + peerID);
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(e.getMessage());
        }
    }
}
