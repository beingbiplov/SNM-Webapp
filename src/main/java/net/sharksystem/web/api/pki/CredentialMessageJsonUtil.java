package net.sharksystem.web.api.pki;

import com.google.gson.JsonObject;
import net.sharksystem.pki.PKIHelper;
import net.sharksystem.pki.CredentialMessage;

/**
 * Utility to convert CredentialMessage to JSON representation.
 */
public final class CredentialMessageJsonUtil {

    private CredentialMessageJsonUtil() {}

    public static JsonObject toJson(CredentialMessage msg) {
        String raw = PKIHelper.credentialMessage2String(msg);

        JsonObject json = new JsonObject();

        // split by |
        String[] parts = raw.split("\\|");

        for (String part : parts) {
            String p = part.trim();

            if (p.startsWith("name:")) {
                json.addProperty("name", value(p));
            } else if (p.startsWith("id:")) {
                json.addProperty("id", value(p));
            } else if (p.startsWith("valid since:")) {
                json.addProperty("validSince", value(p));
            } else if (p.startsWith("via connection:")) {
                json.addProperty("connectionType", value(p));
            } else if (p.startsWith("#extra byte:")) {
                json.addProperty("extraBytes", value(p));
            } else if (p.startsWith("publicKey fingerprint:")) {
                json.addProperty("publicKeyFingerprint", value(p));
            }
        }

        return json;
    }

    private static String value(String part) {
        int idx = part.indexOf(':');
        return idx >= 0 ? part.substring(idx + 1).trim() : "";
    }
}
