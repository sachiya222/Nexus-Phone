// Listen for messages from the FiveM client
window.addEventListener('message', function(event) {
    let item = event.data;
    
    if (item.type === "openPhone") {
        // Show the phone
        document.getElementById('phone-wrapper').classList.remove('hidden');
    } else if (item.type === "closePhone") {
        // Hide the phone
        document.getElementById('phone-wrapper').classList.add('hidden');
    }
});

// Listen for the Escape key to close the phone
document.onkeyup = function(data) {
    if (data.key == "Escape") {
        // Send a message back to the FiveM client to give back player controls
        fetch(`https://${GetParentResourceName()}/closePhone`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    }
};
