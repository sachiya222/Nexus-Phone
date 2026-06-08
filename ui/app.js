window.addEventListener('message', function(event) {
    let item = event.data;
    
    if (item.type === "openPhone") {
        // Inject Qbox data into the HTML
        document.getElementById('player-name').innerText = item.player.firstname + " " + item.player.lastname;
        document.getElementById('player-job').innerText = item.player.job.toUpperCase();
        
        // Format the bank balance with commas so it looks professional
        let formattedBank = item.player.bank.toLocaleString('en-US');
        document.getElementById('player-bank').innerText = "$" + formattedBank;

        // Slide the phone up
        document.getElementById('phone-wrapper').classList.remove('hidden');
    } else if (item.type === "closePhone") {
        document.getElementById('phone-wrapper').classList.add('hidden');
    }
});

document.onkeyup = function(data) {
    if (data.key == "Escape") {
        fetch(`https://${GetParentResourceName()}/closePhone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    }
};
