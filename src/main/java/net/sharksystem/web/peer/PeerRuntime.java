package net.sharksystem.web.peer;

import java.io.File;
import java.io.IOException;

import net.sharksystem.SharkException;
import net.sharksystem.SharkPeerFS;
import net.sharksystem.asap.ASAPPeer;
import net.sharksystem.asap.ASAPPeerFS;
import net.sharksystem.asap.utils.PeerIDHelper;
import net.sharksystem.asap.crypto.ASAPKeyStore;
import net.sharksystem.asap.crypto.InMemoASAPKeyStore;

/**
 * Represents one SharkNet peer in the web application.
 */
public final class PeerRuntime {

    private final String peerName;
    private final CharSequence peerID;
    private final SharkPeerFS sharkPeer;
    private final ASAPPeer asapPeer;

    private boolean active = false;

    public PeerRuntime(String peerName) throws SharkException, IOException {
        this.peerName = peerName;

        // Generate unique peer ID
        this.peerID = peerName + "_" + PeerIDHelper.createUniqueID();

        String dataDir = "./data/" + peerName;
        new File(dataDir).mkdirs();

        this.sharkPeer = new SharkPeerFS(peerName, dataDir);

        this.asapPeer = new ASAPPeerFS(
                peerID,
                dataDir,
                sharkPeer.getSupportedFormats()
        );

        ASAPKeyStore keyStore = new InMemoASAPKeyStore(peerID);
        asapPeer.setASAPKeyStore(keyStore);

        // DO NOT start here
        this.active = false;
    }

    /** Activate (start) the peer */
    public void activate() throws SharkException {
        if (!active) {
            sharkPeer.start(asapPeer);
            active = true;
        }
    }

    /** Stop the peer */
    public void shutdown() throws SharkException {
        if (active) {
            sharkPeer.stop();
            active = false;
        }
    }

    public void start() throws SharkException {
        if (!active) {
            sharkPeer.start(asapPeer);
            active = true;
        }
    }

    public boolean isActive() {
        return active;
    }

    public String getPeerName() {
        return peerName;
    }

    public CharSequence getPeerID() {
        return peerID;
    }
}
