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
        String path = req.getPathInfo(); // /{peerId}
        if (path == null || path.length() < 2) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Missing peerId");
            return;
        }

        String peerId = path.substring(1); // remove leading '/'
        PeerRuntime peer = manager.getPeer(peerId);
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("Peer not found");
            return;
        }

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
        Map<CharSequence, List<PeerRuntime.EncounterLog>> encounterLogs = peer.getEncounterLogs();
        int totalEncounters = encounterLogs.values().stream().mapToInt(List::size).sum();
        encounterStatus.addProperty("encountersTracked", totalEncounters);

        // Detailed encounter list per peer
        JsonArray detailedEncounters = new JsonArray();
        for (Map.Entry<CharSequence, List<PeerRuntime.EncounterLog>> entry : encounterLogs.entrySet()) {
            CharSequence otherPeerID = entry.getKey();
            List<PeerRuntime.EncounterLog> logs = entry.getValue();

            for (PeerRuntime.EncounterLog log : logs) {
                JsonObject logJson = new JsonObject();
                logJson.addProperty("peerID", otherPeerID.toString());
                logJson.addProperty("type", log.type != null ? log.type.toString() : "UNKNOWN");
                logJson.addProperty("startTime", log.startTime);
                logJson.addProperty("stopTime", log.stopTime);
                logJson.addProperty("connected", log.stopTime < 0); // still connected if stopTime not set
                detailedEncounters.add(logJson);
            }
        }
        encounterStatus.add("detailedEncounters", detailedEncounters);
        json.add("encounterStatus", encounterStatus);

        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(json));
    }
}