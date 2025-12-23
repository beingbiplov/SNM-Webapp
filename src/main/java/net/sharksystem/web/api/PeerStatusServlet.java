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
import net.sharksystem.asap.ASAPEncounterConnectionType;

import java.util.Map;
import java.util.List;
import java.io.IOException;

/**
 * API to expose current peer status with detailed encounters.
 */
@WebServlet("/api/peer/status/*")
public class PeerStatusServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");

        String path = req.getPathInfo(); // /{peerId}
        if (path == null || path.length() < 2) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write(error("Missing peerId"));
            return;
        }

        String peerId = path.substring(1).trim();
        PeerRuntime peer = manager.getPeer(peerId);
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write(error("Peer not found"));
            return;
        }

        // Peer exists but is NOT active
        if (!peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            resp.getWriter().write(error("Peer is not active"));
            return;
        }

        // Peer is active → safe to read runtime state
        JsonObject json = new JsonObject();

        // Peer information
        JsonObject peerInfo = new JsonObject();
        peerInfo.addProperty("name", peer.getPeerName());
        peerInfo.addProperty("id", peer.getPeerID().toString());
        peerInfo.addProperty("active", peer.isActive());
        json.add("peerInfo", peerInfo);

        // App settings
        JsonObject appSettings = new JsonObject();
        appSettings.addProperty("rememberNewHubConnections", peer.getRememberNewHubConnections());
        appSettings.addProperty("hubReconnect", peer.getHubReconnect());
        json.add("appSettings", appSettings);

        // PKI status
        JsonObject pkiStatus = new JsonObject();
        pkiStatus.addProperty("persons", peer.getNumberOfPersons());
        pkiStatus.addProperty("certificates", peer.getNumberOfCertificates());
        pkiStatus.addProperty("publicKeyFingerprint", peer.getPublicKeyFingerprint());
        json.add("pkiStatus", pkiStatus);

        // Hub connections
        JsonObject hubStatus = new JsonObject();
        hubStatus.addProperty("hubsConnected", peer.getConnectedHubsCount());
        hubStatus.addProperty("failedToConnect", peer.getFailedHubConnectionsCount());
        json.add("hubConnections", hubStatus);

        // Encounter status
        JsonObject encounterStatus = new JsonObject();
        Map<CharSequence, List<PeerRuntime.EncounterLog>> logs = peer.getEncounterLogs();
        encounterStatus.addProperty(
                "encountersTracked",
                logs.values().stream().mapToInt(List::size).sum()
        );
        json.add("encounterStatus", encounterStatus);

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(gson.toJson(json));
    }

    private String error(String msg) {
        JsonObject o = new JsonObject();
        o.addProperty("msg", msg);
        return gson.toJson(o);
    }
}
