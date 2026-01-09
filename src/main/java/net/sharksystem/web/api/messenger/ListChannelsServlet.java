package net.sharksystem.web.api.messenger;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;
import net.sharksystem.app.messenger.SharkNetMessengerChannel;
import net.sharksystem.app.messenger.SharkNetMessengerComponent;

import java.util.List;
import java.time.Instant;
import java.io.IOException;

/**
 * API to list all messenger channels known to the active peer.
 *
 * GET /api/messenger/channels
 */
@WebServlet("/api/messenger/channels")
public class ListChannelsServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        JsonObject root = new JsonObject();

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            root.addProperty("error", "No active peer");
            write(resp, root);
            return;
        }

        SharkNetMessengerComponent messenger = peer.getMessengerComponent();
        if (messenger == null) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            root.addProperty("error", "Messenger component not available");
            write(resp, root);
            return;
        }

        JsonArray channels = new JsonArray();

        try {
            List<CharSequence> uris = messenger.getChannelUris();

            int index = 1;
            for (CharSequence uri : uris) {
                SharkNetMessengerChannel channel =
                        messenger.getChannel(uri);

                JsonObject ch = new JsonObject();
                ch.addProperty("index", index++);
                ch.addProperty(
                        "name",
                        channel.getName() != null
                                ? channel.getName().toString()
                                : "<no name set>"
                );
                ch.addProperty("uri", uri.toString());

                int messageCount =
                        channel.getMessages() != null
                                ? channel.getMessages().size()
                                : 0;

                ch.addProperty("messages", messageCount);
                ch.addProperty("age", "unknown");

                channels.add(ch);
            }

            root.addProperty("timestamp", Instant.now().toString());
            root.addProperty("count", channels.size());
            root.add("channels", channels);

            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, root);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            root.addProperty("error", e.getMessage());
            write(resp, root);
        }
    }

    private void write(HttpServletResponse resp, JsonObject json)
            throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(json));
    }
}
