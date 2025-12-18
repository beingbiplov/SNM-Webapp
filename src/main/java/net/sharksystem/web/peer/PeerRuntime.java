package net.sharksystem.web.peer;

import net.sharksystem.SharkException;
import net.sharksystem.SharkPeerFS;

/**
 * Minimal runtime wrapper for a Shark peer.
 * For now, it only starts and stops the peer.
 */
public class PeerRuntime {

    private final String peerName;
    private final SharkPeerFS peer;

    public PeerRuntime(String peerName) throws SharkException {
        this.peerName = peerName;

        // Data directory per peer
        String dataDir = "./data/" + peerName;

        // Create peer
        this.peer = new SharkPeerFS(peerName, dataDir);

        this.peer.start(peerName);
    }

    public String getPeerName() {
        return peerName;
    }

    public void shutdown() throws SharkException {
        peer.stop();
    }
}
