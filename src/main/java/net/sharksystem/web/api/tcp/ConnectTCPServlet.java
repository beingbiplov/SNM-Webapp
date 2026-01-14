package net.sharksystem.web.api.tcp;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.web.peer.PeerRuntimeManager;

/**
 * API to connect to a TCP port on a remote peer.
 *
 * POST /api/tcp/connect
 * Body: { "peerId": "peerId_xxx", "host": "localhost", "port": 12345 }
 */
@WebServlet("/api/tcp/connect")
public class ConnectTCPServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        JsonObject response = new JsonObject();

        JsonObject body = gson.fromJson(req.getReader(), JsonObject.class);
        if (body == null
                || !body.has("peerId")
                || !body.has("host")
                || !body.has("port")) {

            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "Missing peerId, host or port");
            write(resp, response);
            return;
        }

        int port = body.get("port").getAsInt();
        String host = body.get("host").getAsString();
        String peerId = body.get("peerId").getAsString();

        PeerRuntime peer = manager.getPeer(peerId);

        if (peer == null || !peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "Peer not found or not active");
            write(resp, response);
            return;
        }

        try {
            peer.connectTCP(host, port);

            resp.setStatus(HttpServletResponse.SC_OK);
            response.addProperty("msg", "Connected to peer");
            response.addProperty("host", host);
            response.addProperty("port", port);

        } catch (IllegalStateException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", e.getMessage());

        } catch (IOException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            response.addProperty("msg", "Failed to connect to remote peer");
        }

        write(resp, response);
    }

    private void write(HttpServletResponse resp, JsonObject json) throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(json));
    }
}
