package net.sharksystem.web.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;

/**
 * API to open a TCP port on the peer.
 *
 * POST /api/tcp/open
 * Body: { "peerId": "peer-id-string", "port": 12345 }
 */
@WebServlet("/api/tcp/open")
public class OpenTCPServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        JsonObject response = new JsonObject();
        JsonObject body = gson.fromJson(req.getReader(), JsonObject.class);

        // Validate body
        if (body == null || !body.has("peerId") || !body.has("port")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "Missing peerId or port in request body");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        String peerId = body.get("peerId").getAsString();
        int port = body.get("port").getAsInt();

        PeerRuntime peer = manager.getPeer(peerId);
        if (peer == null || !peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "Peer not found or not active");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        try {
            peer.openTCPConnection(port);
            resp.setStatus(HttpServletResponse.SC_OK);
            response.addProperty("msg", "TCP port opened");
            response.addProperty("port", port);
        } catch (IllegalStateException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", e.getMessage());
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("msg", "Failed to open TCP port");
        }

        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(response));
    }
}
