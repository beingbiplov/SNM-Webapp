package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;

/**
 * API to send credential request messages.
 *
 * POST /api/pki/sendCredentials?peerId=peer-id&targetPeerId=target-peer-id
 *
 * - peerId: optional (defaults to active peer)
 * - targetPeerId: optional (broadcast if missing)
 */
@WebServlet("/api/pki/sendCredentials")
public class SendCredentialsServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String peerId = req.getParameter("peerId");
        String targetPeerId = req.getParameter("targetPeerId");

        JsonObject response = new JsonObject();
        PeerRuntime peer;

        // Resolve runtime peer (peerId optional)
        if (peerId == null || peerId.isEmpty()) {
            peer = manager.getActivePeer();
            if (peer == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.addProperty("msg", "No active peer found");
                write(resp, response);
                return;
            }
        } else {
            peer = manager.getPeer(peerId);
            if (peer == null || !peer.isActive()) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.addProperty("msg", "Peer not found or not active");
                write(resp, response);
                return;
            }
        }

        try {
            if (targetPeerId == null || targetPeerId.isEmpty()) {
                // broadcast
                peer.getPkiComponent().sendTransientCredentialMessage();

                response.addProperty(
                        "msg",
                        "Credential message sent to all peers"
                );
            } else {
                // targeted
                peer.getPkiComponent()
                        .sendTransientCredentialMessage(targetPeerId);

                response.addProperty(
                        "msg",
                        "Credential message sent to peer " + targetPeerId
                );
                response.addProperty("targetPeerId", targetPeerId);
            }

            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, response);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty(
                    "msg",
                    "Failed to send credential message: " + e.getMessage()
            );
            write(resp, response);
        }
    }

    private void write(HttpServletResponse resp, JsonObject response)
            throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(response));
    }
}
