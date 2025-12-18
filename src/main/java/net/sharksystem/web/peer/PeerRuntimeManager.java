package net.sharksystem.web.peer;

import net.sharksystem.SharkException;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * Manages all running peers in memory.
 */
public class PeerRuntimeManager {

    private static final PeerRuntimeManager INSTANCE = new PeerRuntimeManager();

    private final Map<String, PeerRuntime> peers = new HashMap<>();

    private PeerRuntimeManager() {
    }

    public static PeerRuntimeManager getInstance() {
        return INSTANCE;
    }

    public synchronized void createPeer(String peerName) throws SharkException {
        if (peers.containsKey(peerName)) {
            throw new IllegalStateException("Peer already exists: " + peerName);
        }

        PeerRuntime runtime = new PeerRuntime(peerName);
        peers.put(peerName, runtime);
    }

    public synchronized Map<String, PeerRuntime> getPeers() {
        return Collections.unmodifiableMap(peers);
    }
}
