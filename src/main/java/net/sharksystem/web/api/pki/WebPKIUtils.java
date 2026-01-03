package net.sharksystem.web.api.pki;

import net.sharksystem.asap.ASAPEncounterConnectionType;
import net.sharksystem.asap.crypto.ASAPCryptoAlgorithms;
import net.sharksystem.asap.pki.ASAPCertificate;
import net.sharksystem.pki.SharkPKIComponent;

import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

public class WebPKIUtils {

    private final SharkPKIComponent pki;

    public WebPKIUtils(SharkPKIComponent pki) {
        this.pki = pki;
    }

    /**
     * Convert ASAPCertificate to JSON-friendly Map
     */
    public Map<String, Object> getCertificateAsJson(ASAPCertificate cert) {
        Map<String, Object> json = new HashMap<>();

        // Issuer
        Map<String, String> issuer = new HashMap<>();
        issuer.put("name", cert.getIssuerName().toString());
        issuer.put("id", cert.getIssuerID().toString());
        json.put("issuedBy", issuer);

        // Subject
        Map<String, String> subject = new HashMap<>();
        subject.put("name", cert.getSubjectName().toString());
        subject.put("id", cert.getSubjectID().toString());
        json.put("subject", subject);

        // Validity
        json.put("validSince", cert.getValidSince().getTime().toString());
        json.put("validUntil", cert.getValidUntil().getTime().toString());

        // Public key fingerprint
        try {
            json.put("publicKeyFingerprint", ASAPCryptoAlgorithms.getFingerprint(cert.getPublicKey()));
        } catch (NoSuchAlgorithmException e) {
            json.put("publicKeyFingerprint", "ERROR: " + e.getMessage());
        }

        // Connection type
        ASAPEncounterConnectionType connectionType = cert.getConnectionTypeCredentialsReceived();
        json.put("connectionType", connectionType.toString());

        // Identity check note
        if (connectionType != ASAPEncounterConnectionType.AD_HOC_LAYER_2_NETWORK) {
            json.put("identityChecked", "hope identity was checked carefully");
        } else {
            json.put("identityChecked", "direct encounter - well done");
        }

        return json;
    }
}
