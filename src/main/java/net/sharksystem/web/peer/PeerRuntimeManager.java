package net.sharksystem.web.peer;

import net.sharksystem.SharkException;

import java.io.IOException;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Manages all running SharkNet peers in the web application.
 */
public final class PeerRuntimeManager {

    private static final PeerRuntimeManager INSTANCE = new PeerRuntimeManager();

    // Store peers by normalized peerID string
    private final Map<String, PeerRuntime> peersById = new ConcurrentHashMap<>();

    private PeerRuntimeManager() {
    }

    public static PeerRuntimeManager getInstance() {
        return INSTANCE;
    }

    /**
     * Create and start a new peer.
     */
    public PeerRuntime createPeer(String peerName)
            throws SharkException, IOException {

        PeerRuntime runtime = new PeerRuntime(peerName);
        String peerID = runtime.getPeerID().toString().trim(); // normalize
        peersById.put(peerID, runtime);
        return runtime;
    }

    /**
     * Stop and remove a peer by peerID.
     */
    public boolean removePeer(String peerID) throws SharkException {
        if (peerID == null) return false;
        String normalizedId = peerID.trim(); // normalize input
        PeerRuntime runtime = peersById.remove(normalizedId);
        if (runtime != null) {
            runtime.shutdown();
            return true;
        }
        return false;
    }

    /**
     * List all running peers.
     */
    public Collection<PeerRuntime> listPeers() {
        return Collections.unmodifiableCollection(peersById.values());
    }

    /**
     * Get a peer by ID.
     */
    public PeerRuntime getPeer(String peerID) {
        if (peerID == null) return null;
        return peersById.get(peerID.trim());
    }
}
