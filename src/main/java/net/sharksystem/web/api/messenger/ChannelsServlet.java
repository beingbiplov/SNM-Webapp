package net.sharksystem.web.api.messenger;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import net.sharksystem.SharkException;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;
import net.sharksystem.app.messenger.SharkNetMessengerChannel;
import net.sharksystem.app.messenger.SharkNetMessengerComponent;
import net.sharksystem.app.messenger.SharkNetMessengerException;

import java.util.List;
import java.io.Reader;
import java.time.Instant;
import java.io.IOException;

/**
 * API to list and create messenger channels.
 * GET /api/messenger/channels
 * POST /api/messenger/channels
 */
@WebServlet("/api/messenger/channels")
public class ChannelsServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    private static class CreateChannelRequest {
        String uri;
        String name;
    }

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
                SharkNetMessengerChannel channel = messenger.getChannel(uri);

                JsonObject ch = new JsonObject();
                ch.addProperty("index", index++);
                ch.addProperty(
                        "name",
                        channel.getName() != null
                                ? channel.getName().toString()
                                : "<no name set>");
                ch.addProperty("uri", uri.toString());

                int messageCount = channel.getMessages() != null
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        JsonObject result = new JsonObject();

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            result.addProperty("error", "No active peer");
            write(resp, result);
            return;
        }

        SharkNetMessengerComponent messenger = peer.getMessengerComponent();
        if (messenger == null) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.addProperty("error", "Messenger component not available");
            write(resp, result);
            return;
        }

        CreateChannelRequest body;
        try (Reader reader = req.getReader()) {
            body = gson.fromJson(reader, CreateChannelRequest.class);
        }

        if (body == null || body.uri == null || body.uri.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("error", "channel uri is required");
            write(resp, result);
            return;
        }

        String uri = body.uri;
        String name = body.name;

        try {
            messenger.getChannel(uri);

            // Channel exists → noop
            resp.setStatus(HttpServletResponse.SC_OK);
            result.addProperty("status", "noop");
            result.addProperty(
                    "message",
                    "nothing to do; channel already exists: " + uri);
            result.addProperty("uri", uri);
            write(resp, result);

        } catch (SharkException notExisting) {
            // Channel does not exist → create
            try {
                messenger.createChannel(uri, name, true);

                JsonObject channel = new JsonObject();
                channel.addProperty(
                        "name",
                        name != null ? name : "<no name set>");
                channel.addProperty("uri", uri);

                resp.setStatus(HttpServletResponse.SC_CREATED);
                result.addProperty("status", "created");
                result.addProperty("message", "channel created");
                result.add("channel", channel);
                write(resp, result);

            } catch (SharkNetMessengerException e) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.addProperty("error", e.getLocalizedMessage());
                write(resp, result);
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        JsonObject result = new JsonObject();

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            result.addProperty("error", "No active peer");
            write(resp, result);
            return;
        }

        SharkNetMessengerComponent messenger = peer.getMessengerComponent();
        if (messenger == null) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.addProperty("error", "Messenger component not available");
            write(resp, result);
            return;
        }

        JsonObject body;
        try (Reader reader = req.getReader()) {
            body = gson.fromJson(reader, JsonObject.class);
        } catch (Exception e) {
            result.addProperty("error", "Invalid JSON");
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            write(resp, result);
            return;
        }

        if (body == null || !body.has("uri")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("error", "channel uri is required");
            write(resp, result);
            return;
        }

        String uri = body.get("uri").getAsString();

        try {
            messenger.removeChannel(uri);
            resp.setStatus(HttpServletResponse.SC_OK);
            result.addProperty("status", "deleted");
            result.addProperty("uri", uri);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.addProperty("error", e.getMessage());
        }
        write(resp, result);
    }

    private void write(HttpServletResponse resp, JsonObject json)
            throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(json));
    }
}
