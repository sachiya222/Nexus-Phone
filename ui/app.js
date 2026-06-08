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
let inCall = false;
let modalType = "";

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
    if (appId === "nextweet") document.getElementById('nextweet-screen').classList.remove('hidden');
    if (appId === "marketplace") document.getElementById('marketplace-screen').classList.remove('hidden');
    if (appId === "autosell") document.getElementById('autosell-screen').classList.remove('hidden');
    
    // Static views
    if (appId === "nexgram") document.getElementById('nexgram-screen').classList.remove('hidden'); 
    if (appId === "stocks") document.getElementById('stocks-screen').classList.remove('hidden'); 
}

function goHome() {
    document.querySelectorAll('.app-page').forEach(page => page.classList.add('hidden'));
    document.getElementById('home-screen').classList.remove('hidden');
}

// --- Bank, Dialer, Services Logic ---
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

function pressDial(num) { if (dialNumber.length < 10 && !inCall) { dialNumber += num; document.getElementById('dial-display').innerText = dialNumber; } }
function clearDial() { if (!inCall) { dialNumber = dialNumber.slice(0, -1); document.getElementById('dial-display').innerText = dialNumber; } }
function startCall() {
    if(dialNumber.length > 0 && !inCall) {
        inCall = true;
        document.getElementById('dial-display').style.color = "#32CD32";
        document.querySelector('.call-btn').innerText = "🛑";
        document.querySelector('.call-btn').style.background = "#e74c3c";
        fetch(`https://${GetParentResourceName()}/startCall`, { method: 'POST', body: JSON.stringify({ number: dialNumber }) });
    } else if (inCall) {
        inCall = false; dialNumber = "";
        document.getElementById('dial-display').innerText = "";
        document.getElementById('dial-display').style.color = "white";
        document.querySelector('.call-btn').innerText = "📞";
        document.querySelector('.call-btn').style.background = "#32CD32";
        fetch(`https://${GetParentResourceName()}/endCall`, { method: 'POST', body: JSON.stringify({}) });
    }
}

function callService(jobName) {
    fetch(`https://${GetParentResourceName()}/callService`, {
        method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ job: jobName })
    }).then(() => goHome());
}

// --- Compose Modal Logic ---
function openModal(type) {
    modalType = type;
    document.getElementById('compose-modal').classList.remove('hidden');
    document.getElementById('modal-input-title').value = "";
    document.getElementById('modal-input-desc').value = "";
    document.getElementById('modal-input-price').value = "";

    if (type === 'tweet') {
        document.getElementById('modal-title').innerText = "New Tweet";
        document.getElementById('modal-input-title').classList.add('hidden');
        document.getElementById('modal-input-price').classList.add('hidden');
        document.getElementById('modal-input-desc').placeholder = "What's happening?";
    } else if (type === 'market') {
        document.getElementById('modal-title').innerText = "List Item";
        document.getElementById('modal-input-title').classList.remove('hidden');
        document.getElementById('modal-input-price').classList.remove('hidden');
        document.getElementById('modal-input-title').placeholder = "Item Name";
        document.getElementById('modal-input-desc').placeholder = "Item Description";
    } else if (type === 'autosell') {
        document.getElementById('modal-title').innerText = "Sell Vehicle";
        document.getElementById('modal-input-title').classList.remove('hidden');
        document.getElementById('modal-input-price').classList.remove('hidden');
        document.getElementById('modal-input-title').placeholder = "Vehicle Model (e.g., GTR)";
        document.getElementById('modal-input-desc').placeholder = "Upgrades / Description";
    }
}

function closeModal() {
    document.getElementById('compose-modal').classList.add('hidden');
}

function submitPost() {
    let title = document.getElementById('modal-input-title').value;
    let desc = document.getElementById('modal-input-desc').value;
    let price = document.getElementById('modal-input-price').value;

    if (modalType === 'tweet' && desc.length > 0) {
        fetch(`https://${GetParentResourceName()}/postTweet`, {
            method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ message: desc })
        });
    } else if (modalType === 'market' && title.length > 0 && price.length > 0) {
        fetch(`https://${GetParentResourceName()}/postMarket`, {
            method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ title: title, desc: desc, price: price })
        });
    } else if (modalType === 'autosell' && title.length > 0 && price.length > 0) {
        fetch(`https://${GetParentResourceName()}/postAutoSell`, {
            method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ vehicle: title, desc: desc, price: price })
        });
    }
    closeModal();
    goHome();
}

// --- Live Data Injectors ---
function injectLiveTweets(tweetsArray) {
    const feed = document.getElementById('tweet-feed');
    feed.innerHTML = "";
    if (!tweetsArray || tweetsArray.length === 0) {
        feed.innerHTML = `<div style="text-align:center; color:#888; margin-top:20px;">No tweets yet. Be the first!</div>`;
        return;
    }
    tweetsArray.forEach(tweet => {
        feed.innerHTML += `
            <div class="tweet">
                <div class="tweet-header">
                    <div class="tweet-avatar" style="background:#32CD32"></div>
                    <span class="tweet-user">${tweet.firstName} ${tweet.lastName}</span>
                    <span class="tweet-handle">@${tweet.handle}</span>
                </div>
                <div class="tweet-content">${tweet.message}</div>
            </div>`;
    });
}

function injectLiveMarket(marketArray) {
    const feed = document.getElementById('market-feed');
    feed.innerHTML = "";
    if (!marketArray || marketArray.length === 0) {
        feed.innerHTML = `<div style="text-align:center; color:#888; grid-column:span 2; margin-top:20px;">Market is empty.</div>`;
        return;
    }
    marketArray.forEach(item => {
        feed.innerHTML += `
            <div class="market-item">
                <div class="market-icon">📦</div>
                <div class="market-name">${item.item_name}</div>
                <div class="market-price">$${item.price.toLocaleString('en-US')}</div>
                <span style="font-size:10px; color:#888; margin-bottom:5px;">Seller: ${item.seller_name}</span>
                <button class="buy-btn" onclick="pressDial('${item.seller_number}')">CALL</button>
            </div>`;
    });
}

function injectLiveAutoSell(autoSellArray) {
    const feed = document.getElementById('autosell-feed');
    feed.innerHTML = "";
    if (!autoSellArray || autoSellArray.length === 0) {
        feed.innerHTML = `<div style="text-align:center; color:#888; margin-top:20px;">No vehicles for sale.</div>`;
        return;
    }
    autoSellArray.forEach(car => {
        feed.innerHTML += `
            <div class="car-card">
                <div class="car-details">
                    <div class="car-title"><span>${car.vehicle_name.toUpperCase()}</span><span style="color:#32CD32">$${car.price.toLocaleString('en-US')}</span></div>
                    <span class="car-seller" style="margin-bottom: 2px;">Description: ${car.description}</span>
                    <span class="car-seller">Seller: ${car.seller_name}</span>
                    <button class="buy-btn" style="background:transparent; border:1px solid #32CD32; color:#32CD32;" onclick="pressDial('${car.seller_number}')">CONTACT SELLER</button>
                </div>
            </div>`;
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
        document.getElementById('my-phone-number').innerText = item.player.phoneNumber || "Unknown";
        
        injectLiveTweets(item.tweets);
        injectLiveMarket(item.market);
        injectLiveAutoSell(item.autosell);
        
        loadApps();
        document.getElementById('phone-wrapper').classList.remove('hidden');
    } else if (item.type === "closePhone") {
        document.getElementById('phone-wrapper').classList.add('hidden');
        goHome(); 
    } else if (item.type === "updateBattery") {
        document.getElementById('battery-level').innerText = item.battery + "%";
    }
});

document.onkeyup = function(data) {
    if (data.key == "Escape") fetch(`https://${GetParentResourceName()}/closePhone`, { method: 'POST', body: JSON.stringify({}) });
};
