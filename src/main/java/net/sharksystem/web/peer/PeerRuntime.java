package net.sharksystem.web.peer;

import java.io.File;
import java.util.Map;
import java.util.List;
import java.net.Socket;
import java.util.HashMap;
import java.util.ArrayList;
import java.io.IOException;
import java.util.concurrent.CopyOnWriteArrayList;

import net.sharksystem.asap.*;
import net.sharksystem.SharkPeerFS;
import net.sharksystem.fs.ExtraData;
import net.sharksystem.pki.PKIHelper;
import net.sharksystem.fs.ExtraDataFS;
import net.sharksystem.SharkException;
import net.sharksystem.asap.ASAPException;
import net.sharksystem.pki.CredentialMessage;
import net.sharksystem.pki.SharkPKIComponent;
import net.sharksystem.asap.utils.PeerIDHelper;
import net.sharksystem.asap.crypto.ASAPKeyStore;
import net.sharksystem.hub.HubConnectionManager;
import net.sharksystem.asap.ASAPSecurityException;
import net.sharksystem.hub.HubConnectionManagerImpl;
import net.sharksystem.pki.SharkPKIComponentFactory;
import net.sharksystem.utils.streams.StreamPairImpl;
import net.sharksystem.asap.crypto.InMemoASAPKeyStore;
import net.sharksystem.asap.crypto.ASAPCryptoAlgorithms;
import net.sharksystem.web.peer.PeerRuntime.EncounterLog;
import net.sharksystem.asap.apps.TCPServerSocketAcceptor;
import net.sharksystem.web.pki.CredentialReceivedListener;
import net.sharksystem.hub.peerside.HubConnectorDescription;
import net.sharksystem.app.messenger.SharkNetMessengerComponent;
import net.sharksystem.app.messenger.SharkNetMessengerComponentFactory;

/**
 * Represents one SharkNet peer in the web application, extended with messenger, PKI,
 * encounters, hub management, and status tracking for the servlet.
 */
public final class PeerRuntime {

    private static final String PEER_ID_KEY = "peerID";

    private final String peerName;
    private final CharSequence peerID;
    private final SharkPeerFS sharkPeer;
    private final ASAPPeer asapPeer;

    private boolean active = false;

    private SharkNetMessengerComponent messengerComponent;
    private SharkPKIComponent pkiComponent;
    private HubConnectionManager hubConnectionManager;
    private ASAPEncounterManager encounterManager;
    private ASAPEncounterManagerAdmin encounterManagerAdmin;

    // TCP connections
    private final Map<Integer, TCPServerSocketAcceptor> openSockets = new HashMap<>();

    // HUB tracking
    private final Map<Integer, HubConnectorDescription> connectedHubs = new HashMap<>();
    private int failedHubConnections = 0;

    // Encounter logs
    public static class EncounterLog {
        public final CharSequence peerID;
        public final ASAPEncounterConnectionType type;
        public final long startTime;
        public long stopTime = -1;

        public EncounterLog(CharSequence peerID, ASAPEncounterConnectionType type) {
            this.peerID = peerID;
            this.type = type;
            this.startTime = System.currentTimeMillis();
        }
    }

    private final Map<CharSequence, List<EncounterLog>> encounterLogs = new HashMap<>();

    // App settings
    private boolean rememberNewHubConnections = true;
    private boolean hubReconnect = true;
    private CredentialReceivedListener credentialListener;

    public PeerRuntime(String peerName) throws SharkException, IOException {
        this(peerName, 10); // default sync interval
    }

    public PeerRuntime(String peerName, int syncWithOthersInSeconds)
            throws SharkException, IOException {

        this.peerName = peerName;

        String dataDir = "./data/" + peerName;
        new File(dataDir).mkdirs();

        ExtraData peerData = new ExtraDataFS(dataDir + "/.peerRuntime");

        CharSequence loadedPeerID = null;
        try {
            loadedPeerID = new String(peerData.getExtra(PEER_ID_KEY));
        } catch (SharkException ignored) {
            // first run
        }

        if (loadedPeerID == null) {
            loadedPeerID = peerName + "_" + PeerIDHelper.createUniqueID();
            peerData.putExtra(PEER_ID_KEY, loadedPeerID.toString().getBytes());
        }

        this.peerID = loadedPeerID;

        this.sharkPeer = new SharkPeerFS(peerName, dataDir);
        this.asapPeer = new ASAPPeerFS(peerID, dataDir, sharkPeer.getSupportedFormats());

        ASAPKeyStore keyStore = new InMemoASAPKeyStore(peerID);
        asapPeer.setASAPKeyStore(keyStore);

        // PKI
        SharkPKIComponentFactory pkiFactory = new SharkPKIComponentFactory();
        this.sharkPeer.addComponent(pkiFactory, SharkPKIComponent.class);
        this.pkiComponent = (SharkPKIComponent) sharkPeer.getComponent(SharkPKIComponent.class);

        // Messenger
        SharkNetMessengerComponentFactory messengerFactory =
                new SharkNetMessengerComponentFactory(this.pkiComponent);
        this.sharkPeer.addComponent(messengerFactory, SharkNetMessengerComponent.class);
        this.messengerComponent =
                (SharkNetMessengerComponent) sharkPeer.getComponent(SharkNetMessengerComponent.class);

        // Encounter manager
        ASAPConnectionHandler handler = (ASAPConnectionHandler) asapPeer;
        ASAPEncounterManagerImpl encounterMgr =
                new ASAPEncounterManagerImpl(handler, peerID, syncWithOthersInSeconds * 100L);

        this.encounterManager = encounterMgr;
        this.encounterManagerAdmin = encounterMgr;

        // Setup hub connection manager
        this.hubConnectionManager = new HubConnectionManagerImpl(encounterManager, asapPeer, syncWithOthersInSeconds);
    }

    /** Activate (start) the peer and all components */
    public void activate() throws SharkException {
        if (!active) {
            sharkPeer.start(asapPeer);
            active = true;

            //Add CredentialReceivedListener for this peer
            this.credentialListener = new CredentialReceivedListener(this);
            this.pkiComponent.setSharkCredentialReceivedListener(credentialListener);
        }
    }

    /** Stop the peer */
    public void shutdown() throws SharkException {
        if (active) {
            closeAllTCPConnections();
            sharkPeer.stop();
            active = false;
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

    /** Getters for extended components */
    public SharkNetMessengerComponent getMessengerComponent() {
        return messengerComponent;
    }

    public SharkPKIComponent getPkiComponent() {
        return pkiComponent;
    }

    public HubConnectionManager getHubConnectionManager() {
        return hubConnectionManager;
    }

    public ASAPEncounterManager getEncounterManager() {
        return encounterManager;
    }

    public ASAPEncounterManagerAdmin getEncounterManagerAdmin() {
        return encounterManagerAdmin;
    }

    public Map<Integer, TCPServerSocketAcceptor> getOpenSockets() {
        return openSockets;
    }

    // HUB methods
    public void hubConnected(HubConnectorDescription hub) {
        try {
            connectedHubs.put(hub.getPortNumber(), hub);
        } catch (net.sharksystem.hub.ASAPHubException e) {
            // Handle exception: maybe log it and ignore
            System.err.println("Failed to add hub: " + e.getMessage());
            failedHubConnections++;
        }
    }

    public void hubFailed() {
        failedHubConnections++;
    }

    public int getConnectedHubsCount() { return connectedHubs.size(); }
    public int getFailedHubConnectionsCount() { return failedHubConnections; }

    // Encounter methods
    public void encounterStarted(CharSequence peerID, ASAPEncounterConnectionType type) {
        encounterLogs.computeIfAbsent(peerID, k -> new ArrayList<>()).add(new EncounterLog(peerID, type));
    }

    public void encounterTerminated(CharSequence peerID) {
        List<EncounterLog> logs = encounterLogs.get(peerID);
        if (logs != null && !logs.isEmpty()) {
            logs.get(logs.size() - 1).stopTime = System.currentTimeMillis();
        }
    }

    public Map<CharSequence, List<EncounterLog>> getEncounterLogs() { return encounterLogs; }

    // App settings
    public boolean getRememberNewHubConnections() { return rememberNewHubConnections; }
    public void setRememberNewHubConnections(boolean value) { this.rememberNewHubConnections = value; }

    public boolean getHubReconnect() { return hubReconnect; }
    public void setHubReconnect(boolean value) { this.hubReconnect = value; }

    // PKI summary helpers
    public int getNumberOfPersons() {
        return pkiComponent != null ? pkiComponent.getNumberOfPersons() : 0;
    }

    public int getNumberOfCertificates() {
        return pkiComponent != null ? pkiComponent.getCertificates().size() : 0;
    }

    public String getPublicKeyFingerprint() {
        if (pkiComponent == null || pkiComponent.getASAPKeyStore() == null) {
            return "";
        }

        try {
            return ASAPCryptoAlgorithms.getFingerprint(
                    pkiComponent.getASAPKeyStore().getPublicKey()
            );
        } catch (Exception e) {
            return "unavailable";
        }
    }

    /**
     * Open a TCP connection on the specified port.
     * @param port
     * @throws IOException
     * @throws IllegalStateException if the peer is not active or port is already in use
     */
    public synchronized void openTCPConnection(int port) throws IOException {
        if (!this.isActive()) {
            throw new IllegalStateException("Peer is not active");
        }

        if (openSockets.containsKey(port)) {
            throw new IllegalStateException("Port already in use");
        }

        TCPServerSocketAcceptor acceptor =
                new TCPServerSocketAcceptor(
                        port,
                        this.encounterManager,
                        true
                );

        openSockets.put(port, acceptor);
    }

    /**
     * Close the TCP connection on the specified port.
     * @param port
     * @throws IOException
     * @throws IllegalStateException if the peer is not active or port is not open
     */
    public synchronized void closeTCPConnection(int port) throws IOException {
        if (!this.isActive()) {
            throw new IllegalStateException("Peer is not active");
        }

        TCPServerSocketAcceptor acceptor = openSockets.remove(port);
        if (acceptor == null) {
            throw new IllegalStateException("Port is not open");
        }

        acceptor.close();
    }

    /**
     * Close all open TCP connections.
     */
    private void closeAllTCPConnections() {
        for (TCPServerSocketAcceptor acceptor : openSockets.values()) {
            try {
                acceptor.close();
            } catch (IOException ignored) {
                // ignore
            }
        }
        openSockets.clear();
    }

    /**
     * Connect to a TCP host and port.
     * @param host
     * @param port
     * @throws IOException
     * @throws IllegalStateException if the peer is not active or same-process connection attempted
     */
    public synchronized void connectTCP(String host, int port) throws IOException {
        if (!this.isActive()) {
            throw new IllegalStateException("Peer is not active");
        }

        // Same-process safety check (copied from CLI logic)
        if (host.equalsIgnoreCase("127.0.0.1") || host.equalsIgnoreCase("localhost")) {
            if (openSockets.containsKey(port)) {
                throw new IllegalStateException(
                        "Attempt to establish a connection to same peer refused"
                );
            }
        }

        Socket socket = new Socket(host, port);

        encounterManager.handleEncounter(
                StreamPairImpl.getStreamPair(
                        socket.getInputStream(),
                        socket.getOutputStream()
                ),
                ASAPEncounterConnectionType.INTERNET
        );
    }

    private final List<CredentialMessage> pendingCredentialMessages = new CopyOnWriteArrayList<>();

    public void addPendingCredentialMessage(CredentialMessage msg) {
        pendingCredentialMessages.add(msg);
    }

    public List<CredentialMessage> getPendingCredentialMessages() {
        return pendingCredentialMessages;
    }

    /** Accept and process a pending credential message by its index  */
    public CredentialMessage acceptPendingCredentialMessageOnIndex(int index)
            throws ASAPSecurityException, IOException {

        if (index < 1) {
            throw new IllegalArgumentException("minimal index is 1");
        }

        if (pendingCredentialMessages.size() < index) {
            throw new IllegalArgumentException(
                    "index " + index + " exceeds maximum of " + pendingCredentialMessages.size()
            );
        }

        // convert to 0-based index
        index--;

        CredentialMessage actioned =
                pendingCredentialMessages.remove(index);

        try {
            pkiComponent.getPersonValuesByName(actioned.getSubjectName());
            actioned.setSubjectName(actioned.getSubjectID());
        } catch (ASAPException ignored) {
            // peer name not known yet → OK
        }

        pkiComponent.acceptAndSignCredential(actioned);

        return actioned;
    }     
}
