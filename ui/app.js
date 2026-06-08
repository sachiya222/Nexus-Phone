// ui/app.js

// The Master App Registry
// baseApp: true = comes with phone | baseApp: false = downloaded from App Store
const appRegistry = [
    { id: "phone", name: "Phone", icon: "📞", baseApp: true },
    { id: "messages", name: "Messages", icon: "💬", baseApp: true },
    { id: "camera", name: "Camera", icon: "📸", baseApp: true },
    { id: "settings", name: "Settings", icon: "⚙️", baseApp: true },
    { id: "appstore", name: "App Store", icon: "🛒", baseApp: true },
    { id: "bank", name: "Nexus Bank", icon: "🏦", baseApp: false },
    { id: "nextweet", name: "NexTweet", icon: "🐦", baseApp: false },
    { id: "services", name: "Services", icon: "🚨", baseApp: false }
];

// Function to generate the clean layout dynamically
function loadApps() {
    const grid = document.getElementById('app-grid-container');
    grid.innerHTML = ""; 

    appRegistry.forEach(app => {
        // Only show apps that are base apps (we will add download logic later)
        if (app.baseApp) {
            let appDiv = document.createElement('div');
            appDiv.className = "app-icon";
            appDiv.dataset.app = app.id;
            appDiv.innerHTML = `
                <div class="icon-inner nexus-glow">${app.icon}</div>
                <span>${app.name}</span>
            `;
            // Add click listener for later
            appDiv.onclick = () => openApp(app.id);
            grid.appendChild(appDiv);
        }
    });
}

function openApp(appId) {
    console.log("Opening App: " + appId);
    // Logic for transitioning to app screens goes here later
}

window.addEventListener('message', function(event) {
    let item = event.data;
    
    if (item.type === "openPhone") {
        document.getElementById('player-name').innerText = item.player.firstname + " " + item.player.lastname;
        document.getElementById('player-job').innerText = item.player.job.toUpperCase();
        document.getElementById('player-bank').innerText = "$" + item.player.bank.toLocaleString('en-US');
        
        // Update Battery UI
        document.getElementById('battery-level').innerText = item.battery + "%";
        
        loadApps();
        document.getElementById('phone-wrapper').classList.remove('hidden');
    } else if (item.type === "closePhone") {
        document.getElementById('phone-wrapper').classList.add('hidden');
    } else if (item.type === "updateBattery") {
        // Live battery update while phone is open
        document.getElementById('battery-level').innerText = item.battery + "%";
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
