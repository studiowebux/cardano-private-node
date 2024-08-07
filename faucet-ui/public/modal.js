// Config
let visibleModal = null;

// Open modal
const openModal = (event) => {
    event.preventDefault();
    const modal = document.getElementById(event.currentTarget.dataset.target);
    if (!modal) return;
    const {documentElement: html} = document;
    visibleModal = modal;
    modal.showModal();
};

// Close modal
const closeModal = (event) => {
    if (!visibleModal) {
        throw new Error("No modal to close.")
    }
    visibleModal.close();
    visibleModal = null;
};

// Close with Esc key
document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && visibleModal) {
        closeModal(visibleModal);
    }
});

function triggerDeleteOrganization(key) {
    console.debug("triggerDeleteOrganization", key)
    htmx.trigger(htmx.find(`[data-target="${key}"]`), 'confirmed');
}

function triggerConfirmed(key) {
    console.debug("triggerConfirmed", key)
    const target = htmx.find(`[data-target="${key}"]`);
    if (!target) return;
    console.debug("triggerConfirmed", target);
    htmx.trigger(target, 'confirmed');
}