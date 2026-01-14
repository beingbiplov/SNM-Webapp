package net.sharksystem.web.api.messenger;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import net.sharksystem.SharkException;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.asap.ASAPException;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.asap.persons.PersonValues;
import net.sharksystem.web.peer.PeerRuntimeManager;
import net.sharksystem.asap.utils.ASAPSerialization;
import net.sharksystem.app.messenger.SharkNetMessage;
import net.sharksystem.app.messenger.SharkNetMessengerChannel;
import net.sharksystem.app.messenger.SharkNetMessengerComponent;
import static net.sharksystem.web.api.pki.WebPKIUtils.getUniquePersonValues;

import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;

/**
 * API to send a messenger message.
 *
 * POST /api/messenger/messages
 *
 * Body parameters:
 * - content: String, the message content
 * - contentType: String, the content type (optional, default: ASAP_CHARACTER_SEQUENCE)
 * - sign: boolean, whether to sign the message (optional, default: true)
 * - encrypt: boolean, whether to encrypt the message (optional, default: false)
 * - receiver: String, the receiver's name or ANY_SHARKNET_PEER (optional, default: ANY_SHARKNET_PEER)
 * - channelIndex: int, the index of the channel to use (optional, default: 1)
 */
@WebServlet("/api/messenger/messages")
public class MessageServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            sendError(resp, "no active peer");
            return;
        }

        JsonObject body = JsonParser.parseReader(req.getReader()).getAsJsonObject();

        String content = body.get("content").getAsString();
        if (content == null) {
             sendError(resp, "content is required");
            return;
        }

        String contentType = body.has("contentType")
                ? body.get("contentType").getAsString()
                : SharkNetMessage.SN_CONTENT_TYPE_ASAP_CHARACTER_SEQUENCE;

        boolean sign = !body.has("sign") || body.get("sign").getAsBoolean();
        boolean encrypt = body.has("encrypt") && body.get("encrypt").getAsBoolean();

        String receiverName = body.has("receiver")
                ? body.get("receiver").getAsString()
                : SharkNetMessage.ANY_SHARKNET_PEER;

        int channelIndex = body.has("channelIndex")
                ? body.get("channelIndex").getAsInt()
                : 1;

        try {
            SharkNetMessengerComponent messenger = peer.getMessengerComponent();

            // Resolve channel
            CharSequence channelURI;
            try {
                SharkNetMessengerChannel channel =
                        messenger.getChannel(channelIndex - 1);
                channelURI = channel.getURI();
            } catch (SharkException se) {
                if (channelIndex == 1) {
                    channelURI = SharkNetMessengerComponent.GENERAL_CHANNEL_URI;
                } else {
                    sendError(resp, "invalid channel index");
                    return;
                }
            }

            // Resolve receiver
            CharSequence receiverID = receiverName;
            if (!receiverName.equalsIgnoreCase(SharkNetMessage.ANY_SHARKNET_PEER)) {
                PersonValues pv =
                        getUniquePersonValues(receiverName, peer.getPkiComponent());
                receiverID = pv.getUserID();
            }

            // Serialize content
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ASAPSerialization.writeCharSequenceParameter(content, baos);
            byte[] contentBytes = baos.toByteArray();

            // Send message
            messenger.sendSharkMessage(
                    contentType,
                    contentBytes,
                    channelURI,
                    receiverID,
                    sign,
                    encrypt
            );

            // Response
            JsonObject response = new JsonObject();
            response.addProperty("msg", "message sent");
            response.addProperty("channelIndex", channelIndex);
            response.addProperty("receiver", receiverName);
            response.addProperty("signed", sign);
            response.addProperty("encrypted", encrypt);

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");
            resp.getWriter().write(response.toString());

        } catch (ASAPException e) {
            sendError(resp, e.getMessage());
        }
        catch (SharkException e) {
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
