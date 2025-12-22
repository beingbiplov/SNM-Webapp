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
     * Ensures only ONE peer is active at a time.
     */
    public synchronized PeerRuntime createPeer(String peerName)
            throws SharkException, IOException {

        // Stop any currently active peer
        stopAllActivePeers();

        // Create & start the new peer
        PeerRuntime runtime = new PeerRuntime(peerName);
        runtime.activate();

        String peerID = runtime.getPeerID().toString().trim();
        peersById.put(peerID, runtime);

        PeerRegistryStore.save(peersById.values());

        return runtime;
    }

    /**
     * Remove a peer completely.
     */
    public synchronized boolean removePeer(String peerID) {
        if (peerID == null) return false;

        PeerRuntime runtime = peersById.remove(peerID.trim());
        if (runtime == null) return false;

        try {
            runtime.shutdown();
            PeerRegistryStore.save(peersById.values());
            return true;
        } catch (SharkException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * List all peers.
     */
    public Collection<PeerRuntime> listPeers() {
        return Collections.unmodifiableCollection(peersById.values());
    }

    /**
     * Get peer by ID.
     */
    public PeerRuntime getPeer(String peerID) {
        if (peerID == null) return null;
        return peersById.get(peerID.trim());
    }

    /**
     * Start a peer (exclusive).
     */
    public synchronized boolean startPeer(String peerId) {
        PeerRuntime runtime = getPeer(peerId);
        if (runtime == null) return false;

        stopAllActivePeers();

        try {
            if (!runtime.isActive()) {
                runtime.activate();
            }
            PeerRegistryStore.save(peersById.values());
            return true;
        } catch (SharkException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Stop a peer.
     */
    public synchronized boolean stopPeer(String peerId) {
        PeerRuntime runtime = getPeer(peerId);
        if (runtime == null) return false;

        try {
            runtime.shutdown();
            PeerRegistryStore.save(peersById.values());
            return true;
        } catch (SharkException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Stop all active peers safely.
     */
    private void stopAllActivePeers() {
        for (PeerRuntime runtime : peersById.values()) {
            if (runtime.isActive()) {
                try {
                    runtime.shutdown();
                } catch (SharkException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Restore persisted peers.
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
}
