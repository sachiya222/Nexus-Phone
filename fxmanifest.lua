fx_version 'cerulean'
game 'gta5'

description 'Nexus Community Premium Phone'
version '1.0.0'

-- UI Files
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js',
    'ui/assets/*'
}

-- Client Scripts
client_scripts {
    'client/main.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

-- Qbox Dependency
shared_scripts {
    '@qbx_core/modules/playerdata.lua'
}
