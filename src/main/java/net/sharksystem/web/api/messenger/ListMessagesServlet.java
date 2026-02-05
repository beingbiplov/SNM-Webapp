package net.sharksystem.web.api.messenger;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import net.sharksystem.asap.ASAPHop;
import net.sharksystem.app.messenger.*;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.pki.SharkPKIComponent;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import net.sharksystem.web.api.pki.WebPKIUtils;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.util.Set;
import java.util.Date;
import java.util.List;
import java.io.IOException;
import java.text.SimpleDateFormat;

/**
 * API to list messages in a messenger channel.
 *
 * GET /api/messenger/messages/{channelUri}
 *
 * Path parameters:
 * - channelUri: String, the URI of the messenger channel
 */
@WebServlet("/api/messenger/messages/*")
public class ListMessagesServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    private String formatTime(long millis) {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date(millis));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            sendError(resp, "no active peer");
            return;
        }

        String channelUri = req.getParameter("uri");

        // Fallback to path info if query param is not present
        if (channelUri == null || channelUri.isEmpty()) {
            String pathInfo = req.getPathInfo();
            if (pathInfo != null && pathInfo.length() > 1) {
                channelUri = pathInfo.substring(1);
            }
        }

        if (channelUri == null || channelUri.isEmpty()) {
            sendError(resp, "missing channel URI");
            return;
        }

        try {
            SharkNetMessengerComponent messenger = peer.getMessengerComponent();
            SharkNetMessengerChannel channel = messenger.getChannel(channelUri);
            SharkNetMessageList messages = channel.getMessages();

            SharkPKIComponent pki = peer.getPkiComponent();
            WebPKIUtils pkiUtils = new WebPKIUtils(pki);

            JsonObject channelJson = new JsonObject();
            channelJson.addProperty("uri", channelUri);
            channelJson.addProperty("name", channel.getName() != null ? channel.getName().toString() : "<no name set>");
            channelJson.addProperty("messageCount", messages.size());
            channelJson.addProperty("age", "unknown");

            JsonArray msgArray = new JsonArray();

            List<SharkNetMessage> allMessages = new java.util.ArrayList<>();
            for (int i = 0; i < messages.size(); i++) {
                allMessages.add(messages.getSharkMessage(i, true));
            }

            // Sort by timestamp
            allMessages.sort((m1, m2) -> {
                try {
                    return Long.compare(m1.getCreationTime(), m2.getCreationTime());
                } catch (Exception e) {
                    return 0;
                }
            });

            for (int i = 0; i < allMessages.size(); i++) {
                SharkNetMessage msg = allMessages.get(i);
                JsonObject msgJson = new JsonObject();

                // Note: The index here is just the position in the sorted display list,
                // which might differ from the actual storage index if storage isn't sorted.
                // But for display purposes, 1..N in time order is usually what the frontend
                // expects.
                msgJson.addProperty("index", i + 1);
                msgJson.addProperty("contentType", msg.getContentType().toString());

                String content = "";
                try {
                    byte[] bytes = msg.getContent();
                    if (bytes != null)
                        content = new String(bytes);
                } catch (Exception e) {
                    content = "[Error reading content]";
                }
                msgJson.addProperty("content", content);

                // Sender
                CharSequence senderID = msg.getSender();
                if (pki.getOwnerID().equals(senderID)) {
                    msgJson.addProperty("sender", "you");
                } else {
                    msgJson.addProperty("sender", senderID.toString());
                }

                // Recipients
                Set<CharSequence> recipients = msg.getRecipients();
                JsonArray recipientsJson = new JsonArray();
                for (CharSequence rcpt : recipients)
                    recipientsJson.add(rcpt.toString());
                msgJson.add("recipients", recipientsJson);

                // Time
                msgJson.addProperty("timestamp", formatTime(msg.getCreationTime()));

                // E2E security
                JsonObject e2eJson = new JsonObject();
                e2eJson.addProperty("encrypted", msg.encrypted());
                e2eJson.addProperty("signed", msg.signed());
                e2eJson.addProperty("verified", msg.verified());

                if (msg.signed() && !pki.getOwnerID().equals(senderID)) {
                    e2eJson.addProperty("ia", WebPKIUtils.getIAExplainText(pki.getIdentityAssurance(senderID)));
                }

                msgJson.add("e2eSecurity", e2eJson);

                // Hops list
                JsonArray hopsJson = new JsonArray();
                List<ASAPHop> hops = msg.getASAPHopsList();
                if (hops.isEmpty()) {
                    msgJson.addProperty("hopingList", "no hops");
                } else {
                    for (ASAPHop hop : hops) {
                        JsonObject hopJson = new JsonObject();
                        hopJson.addProperty("sender", hop.sender().toString());
                        hopJson.addProperty("encrypted", hop.encrypted());
                        hopJson.addProperty("verified", hop.verified());
                        String via = switch (hop.getConnectionType()) {
                            case INTERNET -> "TCP";
                            case ASAP_HUB -> "HUB";
                            case AD_HOC_LAYER_2_NETWORK -> "Ad-Hoc";
                            case ONION_NETWORK -> "Onion";
                            default -> "Unknown";
                        };
                        hopJson.addProperty("via", via);
                        hopsJson.add(hopJson);
                    }
                    msgJson.add("hopingList", hopsJson);
                }

                msgArray.add(msgJson);
            }

            channelJson.add("messages", msgArray);

            JsonObject response = new JsonObject();
            response.addProperty("success", true);
            response.add("channel", channelJson);

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");
            resp.getWriter().write(response.toString());

        } catch (Exception e) {
            sendError(resp, e.getMessage());
        }
    }

    private void sendError(HttpServletResponse resp, String msg) throws IOException {
        JsonObject err = new JsonObject();
        err.addProperty("error", msg);
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.setContentType("application/json");
        resp.getWriter().write(err.toString());
    }
}
