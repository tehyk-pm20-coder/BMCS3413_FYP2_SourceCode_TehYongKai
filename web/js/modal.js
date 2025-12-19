// Function to open the modal
function openEditForm() {
    const modal = document.getElementById("editModal");
    if (modal) {
        modal.style.display = "flex"; // Show the modal
    }
}

// Function to close the modal
function closeEditForm() {
    const modal = document.getElementById("editModal");
    if (modal) {
        modal.style.display = "none"; // Hide the modal
    }
}

// Close the modal if the user clicks outside of the modal content
window.onclick = function(event) {
    const modal = document.getElementById("editModal");
    if (event.target === modal) {
        modal.style.display = "none"; // Hide the modal
    }
};