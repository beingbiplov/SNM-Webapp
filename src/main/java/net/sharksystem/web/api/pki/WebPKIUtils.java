package net.sharksystem.web.api.pki;

import net.sharksystem.SharkException;
import net.sharksystem.asap.ASAPException;
import net.sharksystem.pki.SharkPKIComponent;
import net.sharksystem.asap.pki.ASAPCertificate;
import net.sharksystem.asap.persons.PersonValues;
import net.sharksystem.asap.persons.PersonValues;
import net.sharksystem.asap.ASAPSecurityException;
import net.sharksystem.asap.ASAPEncounterConnectionType;
import net.sharksystem.asap.crypto.ASAPCryptoAlgorithms;
import net.sharksystem.app.messenger.SharkNetMessengerException;

import java.util.Map;
import java.util.Set;
import java.util.HashMap;
import java.security.NoSuchAlgorithmException;

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

    /**
     * Provide explanation text for identity assurance levels.
     */
    public static String getIAExplainText(int ia) {
        if(ia < 0 || ia > 10) return "error: iA must be in [0,10]";
        if(ia == 0) return("bad");
        else if(ia == 10) return("perfect");
        else if(ia == 9) return("good");
        else if(ia > 6) return("nice");
        else if(ia < 4) return("bad");

        return("enough?");
    }

    /**
     * Resolve a unique PersonValues by name.
     *
     * @param name peer name
     * @param pki  SharkPKIComponent
     * @return PersonValues
     * @throws ASAPException if none found
     * @throws SharkException if more than one found
     */
    public static PersonValues getUniquePersonValues(
            String name,
            SharkPKIComponent pki
    ) throws ASAPException, SharkException {

        Set<PersonValues> persons = pki.getPersonValuesByName(name);

        if (persons == null || persons.isEmpty()) {
            throw new ASAPException("no person found with name " + name);
        }

        if (persons.size() > 1) {
            throw new SharkException(
                    "problem: more than one persons found with name " + name
            );
        }

        return persons.iterator().next();
    }

    public String getIAString(CharSequence peerID) {
        StringBuilder sb = new StringBuilder();
        sb.append("ia (");
        sb.append(peerID);
        sb.append("): ");

        int ia = 0;
        try {
            ia = pki.getIdentityAssurance(peerID);
        } catch (ASAPSecurityException e) {
            if(pki.getOwnerID().equals(peerID)) {
                ia = 10;
            }
        }
        sb.append(ia);
        sb.append(" (");
        sb.append(WebPKIUtils.getIAExplainText(ia));
        sb.append(") ");

        return sb.toString();
    }
}
