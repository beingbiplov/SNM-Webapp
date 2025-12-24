package net.sharksystem.web.api;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.util.Map;
import java.io.IOException;

/**
 * API to list open TCP ports on the peer.
 *
 * POST /api/tcp/list
 * Body: { "peerId": "peerId_xxx" }
 */
@WebServlet("/api/tcp/list")
public class ListTCPServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        JsonObject response = new JsonObject();
        JsonObject body = gson.fromJson(req.getReader(), JsonObject.class);

        if (body == null || !body.has("peerId")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "Missing peerId in request body");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        String peerId = body.get("peerId").getAsString();
        PeerRuntime peer = manager.getPeer(peerId);

        if (peer == null || !peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "Peer not found or not active");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        // Collect open TCP ports
        Map<Integer, ?> openSockets = peer.getOpenSockets();
        JsonArray portsArray = new JsonArray();
        for (Integer port : openSockets.keySet()) {
            portsArray.add(port);
        }

        response.addProperty("peerId", peerId);
        response.add("openPorts", portsArray);

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(response));
    }
}
