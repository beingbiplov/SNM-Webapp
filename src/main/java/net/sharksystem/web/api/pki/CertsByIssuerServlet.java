package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.asap.pki.ASAPCertificate;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;
import java.util.Collection;

/**
 * API to list certificates issued by a peer.
 *
 * GET /api/pki/certsByIssuer?peerId=peer-id&issuerId=issuer-id
 *
 * - peerId: optional (defaults to active peer)
 * - issuerId: optional (defaults to local peer identity)
 */
@WebServlet("/api/pki/certsByIssuer")
public class CertsByIssuerServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String peerId = req.getParameter("peerId");
        String issuerId = req.getParameter("issuerId");

        JsonObject response = new JsonObject();
        PeerRuntime peer;

        // Resolve peer (peerId optional)
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
            // default issuer = active peer
            if (issuerId == null || issuerId.isEmpty()) {
                issuerId = peer.getPkiComponent()
                        .getOwnerID()
                        .toString();
            }

            Collection<ASAPCertificate> certificates =
                    peer.getPkiComponent().getCertificatesByIssuer(issuerId);

            WebPKIUtils utils = new WebPKIUtils(peer.getPkiComponent());

            JsonArray certArray = new JsonArray();
            if (certificates != null) {
                for (ASAPCertificate cert : certificates) {
                    certArray.add(
                            gson.toJsonTree(utils.getCertificateAsJson(cert))
                    );
                }
            }

            resp.setStatus(HttpServletResponse.SC_OK);
            response.addProperty("issuerId", issuerId);
            response.add("certificates", certArray);
            write(resp, response);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty(
                    "msg",
                    "Failed to list certificates by issuer: " + e.getMessage()
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
