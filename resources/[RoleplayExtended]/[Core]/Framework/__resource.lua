resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

resource_type 'map' { gameTypes = { fivem = true } }

map 'map.lua'

client_scripts {
    'client/functions.lua',
    'client/modules/callbacks.lua',
    'client/modules/markers.lua',
    'client/modules/menus.lua',
    'client/modules/dialogs.lua',
    'client/modules/spawnmanager.lua',
    'client/modules/characters.lua',
    'client/main.lua'
}

server_scripts {
    'server/functions.lua',
    'server/modules/callbacks.lua',
    'server/modules/database.lua',
    'MySQLASync.net.dll',
    'server/main.lua'
}

ui_page {
    'html/index.html'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/application.js',
    'html/assets/background.jpg',
    'html/assets/logo.png'
}

export 'SpawnCharacter'