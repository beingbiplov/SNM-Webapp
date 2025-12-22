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
        restorePeers();
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
        runtime.activate();
        String peerID = runtime.getPeerID().toString().trim(); // normalize
        peersById.put(peerID, runtime);
        PeerRegistryStore.save(peersById.values());

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
            PeerRegistryStore.save(peersById.values());

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

    /**
     * Restore persisted peers from disk.
     */
    private void restorePeers() {
        for (StoredPeer stored : PeerRegistryStore.load()) {
            try {
                PeerRuntime runtime = new PeerRuntime(stored.peerName);
                peersById.put(runtime.getPeerID().toString().trim(), runtime);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Start a peer by ID.
     */
    public boolean startPeer(String peerId) throws SharkException {
        PeerRuntime peer = getPeer(peerId);
        if (peer == null) return false;

        if (!peer.isActive()) {
            peer.start();
        }
        return true;
    }

    /**
     * Stop a peer by ID.
     */
    public boolean stopPeer(String peerId) throws SharkException {
        PeerRuntime peer = getPeer(peerId);
        if (peer == null) return false;

        peer.shutdown();
        return true;
    }
}
