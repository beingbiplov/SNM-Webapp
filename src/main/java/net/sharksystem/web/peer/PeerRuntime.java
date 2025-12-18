package net.sharksystem.web.peer;

import net.sharksystem.SharkException;
import net.sharksystem.SharkPeerFS;
import net.sharksystem.asap.ASAPPeer;
import net.sharksystem.asap.ASAPPeerFS;
import net.sharksystem.asap.utils.PeerIDHelper;
import net.sharksystem.asap.crypto.ASAPKeyStore;
import net.sharksystem.asap.crypto.InMemoASAPKeyStore;

import java.io.File;
import java.io.IOException;

/**
 * Represents one running SharkNet peer in the web application.
 */
public final class PeerRuntime {

    private final String peerName;
    private final CharSequence peerID;
    private final SharkPeerFS sharkPeer;

    public PeerRuntime(String peerName) throws SharkException, IOException {
        this.peerName = peerName;

        // Generate unique peer ID
        this.peerID = peerName + "_" + PeerIDHelper.createUniqueID();

        String dataDir = "./data/" + peerName;
        new File(dataDir).mkdirs();

        // Create Shark peer
        this.sharkPeer = new SharkPeerFS(peerName, dataDir);

        // Create ASAP peer
        ASAPPeer asapPeer = new ASAPPeerFS(
                peerID,
                dataDir,
                sharkPeer.getSupportedFormats()
        );

        ASAPKeyStore keyStore = new InMemoASAPKeyStore(peerID);
        asapPeer.setASAPKeyStore(keyStore);

        // Start Shark peer
        sharkPeer.start(asapPeer);
    }

    public String getPeerName() {
        return peerName;
    }

    public CharSequence getPeerID() {
        return peerID;
    }

    public void shutdown() throws SharkException {
        sharkPeer.stop();
    }
}
