package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.pki.SharkPKIComponent;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;

/**
 * API to get identity assurance level for a subject.
 *
 * GET /api/pki/identityAssurance?subjectId=peer-id
 *
 * - subjectId: required (ID of the subject to check)
 */
@WebServlet("/api/pki/identityAssurance")
public class IdentityAssuranceServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
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
            int ia = pki.getIdentityAssurance(subjectId);
            
            response.addProperty("subjectId", subjectId);
            response.addProperty("identityAssurance", ia);
            response.addProperty("identityAssuranceText", net.sharksystem.web.api.pki.WebPKIUtils.getIAExplainText(ia));
            
            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, response);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty(
                    "msg",
                    "Failed to get identity assurance: " + e.getMessage()
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
