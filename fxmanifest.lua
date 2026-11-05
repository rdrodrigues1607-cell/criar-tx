fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Antigravity'
description 'Sistema de Texturas e Estampas Personalizadas para Veiculos - WorkStore Creative & Qbox'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@vrp/lib/Utils.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/dui_view.html',
    'html/style.css',
    'html/script.js'
}
