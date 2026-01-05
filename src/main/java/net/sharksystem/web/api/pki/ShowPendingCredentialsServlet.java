package net.sharksystem.web.api.pki;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import net.sharksystem.pki.PKIHelper;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.pki.CredentialMessage;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.util.List;
import java.io.IOException;

/**
 * API to show pending credential messages of the active peer.
 *
 * GET /api/pki/pendingCredentials
 */
@WebServlet("/api/pki/pendingCredentials")
public class ShowPendingCredentialsServlet extends HttpServlet {

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

        List<CredentialMessage> pending = peer.getPendingCredentialMessages();

        JsonArray result = new JsonArray();

        if (pending != null && !pending.isEmpty()) {
            int index = 1;
            for (CredentialMessage msg : pending) {
                System.out.println("Pending Credential Message: " + msg);
                JsonObject item = new JsonObject();
                item.addProperty("index", index++);
                item.add(
                        "credential",
                        CredentialMessageJsonUtil.toJson(msg)
                );
                result.add(item);
            }
        }

        response.add("pendingCredentials", result);
        resp.setStatus(HttpServletResponse.SC_OK);
        write(resp, response);
    }

    private void write(HttpServletResponse resp, JsonObject response)
            throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(response));
    }
}
