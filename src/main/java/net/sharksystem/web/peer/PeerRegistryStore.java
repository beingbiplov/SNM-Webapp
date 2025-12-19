package net.sharksystem.web.peer;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Persists peer registry to disk so peers survive restarts.
 */
public final class PeerRegistryStore {

    private static final Path FILE = Path.of("data/peers.json");
    private static final Gson gson = new Gson();

    private PeerRegistryStore() {
        // utility class
    }

    /**
     * Save all peers to disk.
     */
    public static synchronized void save(Collection<PeerRuntime> runtimes) {
        List<StoredPeer> stored = new ArrayList<>();

        for (PeerRuntime runtime : runtimes) {
            stored.add(new StoredPeer(runtime.getPeerName()));
        }

        try (Writer writer = Files.newBufferedWriter(FILE)) {
            gson.toJson(stored, writer);
        } catch (IOException e) {
            throw new RuntimeException("Failed to save peer registry", e);
        }
    }

    /**
     * Load peers from disk.
     */
    public static synchronized List<StoredPeer> load() {
        if (!Files.exists(FILE)) {
            return List.of();
        }

        try (Reader reader = Files.newBufferedReader(FILE)) {
            Type type = new TypeToken<List<StoredPeer>>() {}.getType();
            List<StoredPeer> peers = gson.fromJson(reader, type);
            return peers != null ? peers : List.of();
        } catch (IOException e) {
            throw new RuntimeException("Failed to load peer registry", e);
        }
    }
}
