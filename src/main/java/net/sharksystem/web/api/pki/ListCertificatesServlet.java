package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.web.peer.PeerRuntimeManager;
import net.sharksystem.asap.pki.ASAPCertificate;

import java.io.IOException;
import java.util.Set;

/**
 * API to list all certificates of a peer.
 *
 * GET /api/pki/certificates?peerId=peer-id
 */
@WebServlet("/api/pki/certificates")
public class ListCertificatesServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String peerId = req.getParameter("peerId");
        JsonObject response = new JsonObject();

        if (peerId == null || peerId.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "Missing peerId parameter");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        PeerRuntime peer = manager.getPeer(peerId);
        if (peer == null || !peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "Peer not found or not active");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        try {
            Set<ASAPCertificate> certificates = peer.getPkiComponent().getCertificates();
            WebPKIUtils utils = new WebPKIUtils(peer.getPkiComponent());

            JsonArray certArray = new JsonArray();
            if (certificates != null) {
                for (ASAPCertificate cert : certificates) {
                    certArray.add(gson.toJsonTree(utils.getCertificateAsJson(cert)));
                }
            }

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");

            response.add("certificates", certArray);
            resp.getWriter().write(gson.toJson(response));

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("msg", "Failed to list certificates: " + e.getMessage());
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
        }
    }
}
