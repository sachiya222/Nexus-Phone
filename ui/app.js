const appRegistry = [
    { id: "phone", name: "Phone", icon: "📞", baseApp: true },
    { id: "messages", name: "Messages", icon: "💬", baseApp: true },
    { id: "bank", name: "Nexus Bank", icon: "🏦", baseApp: true }, // Bank is active!
    { id: "camera", name: "Camera", icon: "📸", baseApp: true },
    { id: "settings", name: "Settings", icon: "⚙️", baseApp: true },
    { id: "appstore", name: "App Store", icon: "🛒", baseApp: true },
    { id: "nextweet", name: "NexTweet", icon: "🐦", baseApp: false },
    { id: "services", name: "Services", icon: "🚨", baseApp: false }
];

let currentBankBalance = 0;

function loadApps() {
    const grid = document.getElementById('app-grid-container');
    grid.innerHTML = ""; 
    appRegistry.forEach(app => {
        if (app.baseApp) {
            let appDiv = document.createElement('div');
            appDiv.className = "app-icon";
            appDiv.dataset.app = app.id;
            appDiv.innerHTML = `<div class="icon-inner nexus-glow">${app.icon}</div><span>${app.name}</span>`;
            appDiv.onclick = () => openApp(app.id);
            grid.appendChild(appDiv);
        }
    });
}

function openApp(appId) {
    if (appId === "bank") {
        document.getElementById('home-screen').classList.add('hidden');
        document.getElementById('bank-screen').classList.remove('hidden');
    }
}

function goHome() {
    document.querySelectorAll('.app-page').forEach(page => page.classList.add('hidden'));
    document.getElementById('home-screen').classList.remove('hidden');
}

function processTransfer() {
    let targetId = document.getElementById('transfer-id').value;
    let amount = document.getElementById('transfer-amount').value;

    if (!targetId || !amount || amount <= 0) return;

    // Send data to FiveM Lua client
    fetch(`https://${GetParentResourceName()}/transferMoney`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({
            target: targetId,
            amount: amount
        })
    }).then(() => {
        document.getElementById('transfer-id').value = '';
        document.getElementById('transfer-amount').value = '';
        goHome();
    });
}

window.addEventListener('message', function(event) {
    let item = event.data;
    
    if (item.type === "openPhone") {
        document.getElementById('player-name').innerText = item.player.firstname + " " + item.player.lastname;
        document.getElementById('player-job').innerText = item.player.job.toUpperCase();
        
        currentBankBalance = item.player.bank;
        document.getElementById('player-bank-home').innerText = "$" + currentBankBalance.toLocaleString('en-US');
        document.getElementById('player-bank-app').innerText = "$" + currentBankBalance.toLocaleString('en-US');
        
        document.getElementById('battery-level').innerText = item.battery + "%";
        
        loadApps();
        document.getElementById('phone-wrapper').classList.remove('hidden');
    } else if (item.type === "closePhone") {
        document.getElementById('phone-wrapper').classList.add('hidden');
        goHome(); // reset to home screen on close
    } else if (item.type === "updateBattery") {
        document.getElementById('battery-level').innerText = item.battery + "%";
    } else if (item.type === "updateBank") {
        currentBankBalance = item.balance;
        document.getElementById('player-bank-home').innerText = "$" + currentBankBalance.toLocaleString('en-US');
        document.getElementById('player-bank-app').innerText = "$" + currentBankBalance.toLocaleString('en-US');
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
