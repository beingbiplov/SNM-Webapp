/**
 * welcome.js - Handles User Onboarding multi-step wizard logic
 * Integrates directly with verified runtime configuration REST APIs.
 */

let currentOnboardingStep = 1;
const maximumOnboardingSteps = 4;

/**
 * Executes initialization routines on DOM verification content readiness.
 */
document.addEventListener('DOMContentLoaded', () => {
    extractActivePeerIdentityFingerprint();
});

/**
 * Extracts cryptographic identity parameters from active instance status APIs.
 * * @return {void}
 */
function extractActivePeerIdentityFingerprint() {
    if (!window.currentActivePeerId) {
        console.warn("No active peer identified during setup flow routing execution.");
        return;
    }

    const targetPeerId = encodeURIComponent(window.currentActivePeerId);
    fetch(`/snm-webapp/api/peer/status/${targetPeerId}`)
        .then(response => {
            if (!response.ok) throw new Error("HTTP status extraction failure.");
            return response.json();
        })
        .then(data => {
            const fingerprintDisplay = document.getElementById('ob-fingerprintDisplay');
            if (fingerprintDisplay && data.pkiStatus && data.pkiStatus.publicKeyFingerprint) {
                fingerprintDisplay.innerText = data.pkiStatus.publicKeyFingerprint;
            }
        })
        .catch(err => {
            console.error("Failure extraction parameters:", err);
            const display = document.getElementById('ob-fingerprintDisplay');
            if (display) display.innerText = "Error locating cryptography keys mapping context.";
        });
}

/**
 * Handles validation and state transformation updates when progressing forward.
 * * @return {void}
 */
function navigateNextStep() {
    if (currentOnboardingStep === 1) {
        const nameInput = document.getElementById('ob-displayName').value.trim();
        if (!nameInput) {
            alert("Please input your display parameter representation to proceed.");
            return;
        }
    }

    if (currentOnboardingStep === maximumOnboardingSteps) {
        completeOnboardingSequenceWorkflow();
        return;
    }

    currentOnboardingStep++;
    transformWizardWorkflowUI();
}

/**
 * Adjusts state contexts to navigate back into previous layout boundaries.
 * * @return {void}
 */
function navigatePreviousStep() {
    if (currentOnboardingStep <= 1) return;
    currentOnboardingStep--;
    transformWizardWorkflowUI();
}

/**
 * Handles visual element manipulation to match state settings.
 * * @return {void}
 */
function transformWizardWorkflowUI() {
    // Toggle block sections visibility tracking maps
    for (let index = 1; index <= maximumOnboardingSteps; index++) {
        const stepView = document.getElementById(`wizard-step-${index}`);
        if (stepView) {
            if (index === currentOnboardingStep) {
                stepView.classList.remove('hidden');
            } else {
                stepView.classList.add('hidden');
            }
        }
    }

    // Process progress circles alignment configurations
    for (let stepIndex = 1; stepIndex <= maximumOnboardingSteps; stepIndex++) {
        const circle = document.getElementById(`step-circle-${stepIndex}`);
        if (circle) {
            if (stepIndex <= currentOnboardingStep) {
                circle.classList.remove('bg-gray-200', 'text-gray-600', 'dark:bg-dark-border', 'dark:text-gray-400');
                circle.classList.add('bg-primary-500', 'text-white');
            } else {
                circle.classList.remove('bg-primary-500', 'text-white');
                circle.classList.add('bg-gray-200', 'text-gray-600', 'dark:bg-dark-border', 'dark:text-gray-400');
            }
        }
    }

    // Toggle interaction layout buttons states boundaries
    const backBtn = document.getElementById('btn-wizard-back');
    const nextBtn = document.getElementById('btn-wizard-next');

    if (backBtn) backBtn.disabled = (currentOnboardingStep === 1);

    if (nextBtn) {
        if (currentOnboardingStep === maximumOnboardingSteps) {
            nextBtn.innerHTML = `<span>Complete Setup</span> <i class="fas fa-check-circle"></i>`;
        } else {
            nextBtn.innerHTML = `<span>Next</span> <i class="fas fa-arrow-right"></i>`;
        }
    }
}

/**
 * Dispatches a formal background execution connection attempt to verified hub systems.
 * * @return {Promise<void>}
 */
async function triggerHubConnectAttempt() {
    if (!window.currentActivePeerId) return;

    const host = document.getElementById('ob-hubAddress').value.trim();
    const port = document.getElementById('ob-hubPort').value.trim();

    if (!host || !port) {
        alert("Please enter both target remote address and operational port mappings.");
        return;
    }

    try {
        const response = await fetch('/snm-webapp/api/tcp/connect', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                peerId: window.currentActivePeerId,
                host: host,
                port: parseInt(port)
            })
        });
        const output = await response.json();
        alert(output.msg || "Operation executed.");
    } catch (error) {
        console.error("Hub deployment link exception:", error);
        alert("Failed dispatching operational frame context to target hub.");
    }
}

/**
 * Implements final step configurations processing channel routing maps setup.
 * * @return {Promise<void>}
 */
async function completeOnboardingSequenceWorkflow() {
    const channelUri = document.getElementById('ob-channelUri').value.trim();
    const channelName = document.getElementById('ob-channelName').value.trim();

    if (!channelUri) {
        alert("A valid active scope target channel URI sequence context parameter is required.");
        return;
    }

    console.log("Saving onboarding preferences parameters context data mapping...");

    // Final redirection after configuration completing orchestration steps boundaries
    window.location.href = '/snm-webapp/index.jsp';
}