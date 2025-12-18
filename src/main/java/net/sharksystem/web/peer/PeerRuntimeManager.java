package net.sharksystem.web.peer;

import java.util.Map;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;

/**
 * Manages all running peers in the web application.
 */
public final class PeerRuntimeManager {

    private static final PeerRuntimeManager INSTANCE = new PeerRuntimeManager();

    private final Map<String, PeerRuntime> peers = new LinkedHashMap<>();

    private PeerRuntimeManager() {
    }

    public static PeerRuntimeManager getInstance() {
        return INSTANCE;
    }

    public synchronized PeerRuntime createPeer(String peerName) throws Exception {
        if (peers.containsKey(peerName)) {
            throw new IllegalStateException("Peer already exists: " + peerName);
        }

        PeerRuntime runtime = new PeerRuntime(peerName);
        peers.put(peerName, runtime);
        return runtime;
    }

    public synchronized Collection<PeerRuntime> listPeers() {
        return Collections.unmodifiableCollection(peers.values());
    }
}
