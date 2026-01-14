package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import net.sharksystem.pki.PKIHelper;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.pki.CredentialMessage;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;

/**
 * API to accept a pending credential message of the active peer.
 *
 * POST /api/pki/pendingCredentials/accept?index=message-index
 *
 * - index: required (index of the pending credential message)
 */
@WebServlet("/api/pki/pendingCredentials/accept")
public class AcceptPendingCredentialServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final PeerRuntimeManager manager =
            PeerRuntimeManager.getInstance();

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

        String indexParam = req.getParameter("index");
        if (indexParam == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "index parameter is required");
            write(resp, response);
            return;
        }

        try {
            int index = Integer.parseInt(indexParam);

            CredentialMessage accepted =
                    peer.acceptPendingCredentialMessageOnIndex(index);

            response.addProperty("msg", "credential accepted");
            response.addProperty(
                    "credential",
                    PKIHelper.credentialMessage2String(accepted)
            );
            response.addProperty(
                    "note",
                    "indices of pending credentials have changed"
            );

            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, response);

        } catch (IllegalArgumentException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", e.getMessage());
            write(resp, response);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty(
                    "msg",
                    "failed to accept credential: " + e.getMessage()
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
