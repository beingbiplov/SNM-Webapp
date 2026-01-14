package net.sharksystem.web.pki;

import net.sharksystem.pki.CredentialMessage;
import net.sharksystem.pki.SharkCredentialReceivedListener;
import net.sharksystem.web.peer.PeerRuntime;

/**
 * Listener to handle received credentials
 */
public class CredentialReceivedListener
        implements SharkCredentialReceivedListener {

    private final PeerRuntime runtime;

    public CredentialReceivedListener(PeerRuntime runtime) {
        this.runtime = runtime;
    }

    @Override
    public void credentialReceived(CredentialMessage credentialMessage) {
        runtime.addPendingCredentialMessage(credentialMessage);
    }
}
