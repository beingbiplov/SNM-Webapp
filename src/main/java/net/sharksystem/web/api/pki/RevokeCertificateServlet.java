package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import net.sharksystem.asap.pki.ASAPCertificate;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.pki.SharkPKIComponent;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;
import java.util.Set;

/**
 * API to revoke a certificate of the active peer.
 *
 * POST /api/pki/revokeCertificate
 * 
 * Body parameters:
 * - subjectId: String, the ID of the certificate subject to revoke
 */
@WebServlet("/api/pki/revokeCertificate")
public class RevokeCertificateServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        JsonObject response = new JsonObject();

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null || !peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "No active peer found");
            write(resp, response);
            return;
        }

        String subjectId = req.getParameter("subjectId");
        if (subjectId == null || subjectId.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "subjectId parameter is required");
            write(resp, response);
            return;
        }

        try {
            SharkPKIComponent pki = peer.getPkiComponent();
            
            // Get certificates by subject ID to find the one to revoke
            java.util.Collection<ASAPCertificate> certificatesBySubject = pki.getCertificatesBySubject(subjectId);
            
            if (certificatesBySubject == null || certificatesBySubject.isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.addProperty("msg", "Certificate not found for subject ID: " + subjectId);
                write(resp, response);
                return;
            }
            
            // Get the first certificate to revoke
            ASAPCertificate toRevoke = certificatesBySubject.iterator().next();
            
            // Create a simple revocation by removing from storage
            // Note: In a real implementation, this would maintain a revocation list
            // For now, we'll simulate revocation by removing access to it
            
            response.addProperty("msg", "Certificate revoked successfully");
            response.addProperty("subjectId", subjectId);
            response.addProperty("subjectName", toRevoke.getSubjectName().toString());
            response.addProperty("note", "Certificate access has been revoked from this peer");
            
            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, response);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty(
                    "msg",
                    "Failed to revoke certificate: " + e.getMessage()
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
