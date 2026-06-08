const appRegistry = [
    { id: "phone", name: "Phone", icon: "📞", baseApp: true },
    { id: "messages", name: "Messages", icon: "💬", baseApp: true },
    { id: "bank", name: "Nexus Bank", icon: "🏦", baseApp: true },
    { id: "settings", name: "Settings", icon: "⚙️", baseApp: true },
    { id: "appstore", name: "App Store", icon: "🛒", baseApp: true },
    { id: "nextweet", name: "NexTweet", icon: "🐦", baseApp: true }, // Set to true for testing
    { id: "nexgram", name: "NexGram", icon: "📷", baseApp: true },  // Set to true for testing
    { id: "nexdate", name: "NexDate", icon: "🔥", baseApp: true }   // Set to true for testing
];

let currentBankBalance = 0;
let dialNumber = "";

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
    document.getElementById('home-screen').classList.add('hidden');
    if (appId === "bank") document.getElementById('bank-screen').classList.remove('hidden');
    if (appId === "phone") document.getElementById('phone-screen').classList.remove('hidden');
    if (appId === "messages") document.getElementById('messages-screen').classList.remove('hidden');
    if (appId === "settings") document.getElementById('settings-screen').classList.remove('hidden');
    if (appId === "nextweet") {
        document.getElementById('nextweet-screen').classList.remove('hidden');
        loadDummyTweets();
    }
    if (appId === "nexgram") {
        document.getElementById('nexgram-screen').classList.remove('hidden');
        loadDummyGrams();
    }
    if (appId === "nexdate") {
        document.getElementById('nexdate-screen').classList.remove('hidden');
    }
}

function goHome() {
    document.querySelectorAll('.app-page').forEach(page => page.classList.add('hidden'));
    document.getElementById('home-screen').classList.remove('hidden');
}

// --- Bank & Dialer Logic ---
function processTransfer() {
    let targetId = document.getElementById('transfer-id').value;
    let amount = document.getElementById('transfer-amount').value;
    if (!targetId || !amount || amount <= 0) return;
    fetch(`https://${GetParentResourceName()}/transferMoney`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ target: targetId, amount: amount })
    }).then(() => {
        document.getElementById('transfer-id').value = '';
        document.getElementById('transfer-amount').value = '';
        goHome();
    });
}

function pressDial(num) {
    if (dialNumber.length < 10) {
        dialNumber += num;
        document.getElementById('dial-display').innerText = dialNumber;
    }
}
function clearDial() {
    dialNumber = dialNumber.slice(0, -1);
    document.getElementById('dial-display').innerText = dialNumber;
}
function startCall() {
    if(dialNumber.length > 0) {
        fetch(`https://${GetParentResourceName()}/startCall`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ number: dialNumber })
        });
    }
}

// --- Social Dummy Data Injectors ---
function loadDummyTweets() {
    const feed = document.getElementById('tweet-feed');
    feed.innerHTML = `
        <div class="tweet">
            <div class="tweet-header">
                <div class="tweet-avatar" style="background:#32CD32"></div>
                <span class="tweet-user">Nexus Mayor</span>
                <span class="tweet-handle">@CityHall</span>
            </div>
            <div class="tweet-content">Taxes have been lowered by 2% city-wide. Enjoy the weekend! 🏙️📉</div>
            <div class="tweet-actions"><span>💬 12</span><span>🔁 5</span><span>❤️ 104</span></div>
        </div>
        <div class="tweet">
            <div class="tweet-header">
                <div class="tweet-avatar" style="background:#e74c3c"></div>
                <span class="tweet-user">Anonymous</span>
                <span class="tweet-handle">@Ghost</span>
            </div>
            <div class="tweet-content">Anyone selling a heavy pistol? DM me.</div>
            <div class="tweet-actions"><span>💬 0</span><span>🔁 0</span><span>❤️ 2</span></div>
        </div>
    `;
}

function loadDummyGrams() {
    const feed = document.getElementById('gram-feed');
    feed.innerHTML = `
        <div class="gram-post">
            <div class="gram-header">
                <div class="tweet-avatar" style="background:#9b59b6"></div>
                <span class="tweet-user">StreetKing</span>
            </div>
            <div class="gram-image">New Car Pic Here</div>
            <div class="gram-actions">🤍 💬 ↗️</div>
            <div class="gram-caption"><b>StreetKing</b> Just picked up the new GTR. Nexus City ain't ready. 🏎️💨</div>
        </div>
    `;
}

// --- FiveM Client Bridge ---
window.addEventListener('message', function(event) {
    let item = event.data;
    
    if (item.type === "openPhone") {
        document.getElementById('player-name').innerText = item.player.firstname + " " + item.player.lastname;
        document.getElementById('player-job').innerText = item.player.job.toUpperCase();
        
        currentBankBalance = item.player.bank;
        document.getElementById('player-bank-home').innerText = "$" + currentBankBalance.toLocaleString('en-US');
        document.getElementById('player-bank-app').innerText = "$" + currentBankBalance.toLocaleString('en-US');
        document.getElementById('battery-level').innerText = item.battery + "%";
        document.getElementById('my-phone-number').innerText = item.player.phoneNumber || "Unknown";
        
        loadApps();
        document.getElementById('phone-wrapper').classList.remove('hidden');
    } else if (item.type === "closePhone") {
        document.getElementById('phone-wrapper').classList.add('hidden');
        goHome(); 
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
