const appRegistry = [
    { id: "phone", name: "Phone", icon: "📞", baseApp: true },
    { id: "messages", name: "Messages", icon: "💬", baseApp: true },
    { id: "bank", name: "Nexus Bank", icon: "🏦", baseApp: true },
    { id: "appstore", name: "App Store", icon: "🛒", baseApp: true },
    { id: "nextweet", name: "NexTweet", icon: "🐦", baseApp: true },
    { id: "nexgram", name: "NexGram", icon: "📷", baseApp: true },
    { id: "marketplace", name: "Market", icon: "🛍️", baseApp: true }, 
    { id: "autosell", name: "AutoSell", icon: "🚗", baseApp: true },
    { id: "stocks", name: "Stocks", icon: "📈", baseApp: true },
    { id: "services", name: "Services", icon: "🚨", baseApp: true },
    { id: "nexdate", name: "NexDate", icon: "🔥", baseApp: true },
    { id: "settings", name: "Settings", icon: "⚙️", baseApp: true }
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
    if (appId === "nexdate") document.getElementById('nexdate-screen').classList.remove('hidden');
    if (appId === "services") document.getElementById('services-screen').classList.remove('hidden');
    
    if (appId === "nextweet") { document.getElementById('nextweet-screen').classList.remove('hidden'); loadDummyTweets(); }
    if (appId === "nexgram") { document.getElementById('nexgram-screen').classList.remove('hidden'); loadDummyGrams(); }
    if (appId === "marketplace") { document.getElementById('marketplace-screen').classList.remove('hidden'); loadDummyMarket(); }
    if (appId === "autosell") { document.getElementById('autosell-screen').classList.remove('hidden'); loadDummyAutoSell(); }
    if (appId === "stocks") { document.getElementById('stocks-screen').classList.remove('hidden'); loadDummyStocks(); }
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

function pressDial(num) { if (dialNumber.length < 10) { dialNumber += num; document.getElementById('dial-display').innerText = dialNumber; } }
function clearDial() { dialNumber = dialNumber.slice(0, -1); document.getElementById('dial-display').innerText = dialNumber; }
function startCall() {
    if(dialNumber.length > 0) {
        fetch(`https://${GetParentResourceName()}/startCall`, { method: 'POST', body: JSON.stringify({ number: dialNumber }) });
    }
}

// --- Emergency Services Logic ---
function callService(jobName) {
    fetch(`https://${GetParentResourceName()}/callService`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ job: jobName })
    }).then(() => goHome());
}

// --- Economy & Social Dummy Data Injectors ---
function loadDummyTweets() {
    document.getElementById('tweet-feed').innerHTML = `
        <div class="tweet"><div class="tweet-header"><div class="tweet-avatar" style="background:#32CD32"></div><span class="tweet-user">Nexus Mayor</span><span class="tweet-handle">@CityHall</span></div><div class="tweet-content">Taxes have been lowered by 2% city-wide. Enjoy the weekend! 🏙️📉</div></div>
    `;
}
function loadDummyGrams() {
    document.getElementById('gram-feed').innerHTML = `
        <div class="gram-post"><div class="gram-header"><div class="tweet-avatar" style="background:#9b59b6"></div><span class="tweet-user">StreetKing</span></div><div class="gram-image">Car Pic</div><div class="gram-caption"><b>StreetKing</b> Just picked up the new GTR. 🏎️💨</div></div>
    `;
}
function loadDummyMarket() {
    document.getElementById('market-feed').innerHTML = `
        <div class="market-item"><div class="market-icon">📱</div><div class="market-name">Hacked Datapad</div><div class="market-price">$5,000</div><button class="buy-btn">BUY</button></div>
        <div class="market-item"><div class="market-icon">💊</div><div class="market-name">Bandages (x10)</div><div class="market-price">$500</div><button class="buy-btn">BUY</button></div>
    `;
}
function loadDummyAutoSell() {
    document.getElementById('autosell-feed').innerHTML = `
        <div class="car-card">
            <div class="car-img">Elegy Retro Custom Image</div>
            <div class="car-details">
                <div class="car-title"><span>Elegy Retro</span><span style="color:#32CD32">$85,000</span></div>
                <span class="car-seller">Seller: Ghost#1992</span>
                <button class="buy-btn" style="background:transparent; border:1px solid #32CD32; color:#32CD32;">CONTACT SELLER</button>
            </div>
        </div>
    `;
}
function loadDummyStocks() {
    document.getElementById('stock-feed').innerHTML = `
        <div class="stock-row"><div class="stock-info"><h4>NEXUS</h4><span>Nexus City Bond</span></div><div class="stock-price"><h4>$124.50</h4><span class="stock-change">+2.4%</span></div></div>
        <div class="stock-row"><div class="stock-info"><h4>QBIT</h4><span>Qbox Crypto</span></div><div class="stock-price"><h4>$8,932.10</h4><span class="stock-change change-neg">-1.2%</span></div></div>
        <div class="stock-row"><div class="stock-info"><h4>LIME</h4><span>Lime Tech</span></div><div class="stock-price"><h4>$45.00</h4><span class="stock-change">+8.9%</span></div></div>
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
        fetch(`https://${GetParentResourceName()}/closePhone`, { method: 'POST', body: JSON.stringify({}) });
    }
};
