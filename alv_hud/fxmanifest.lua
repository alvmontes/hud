fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'alv_hud'
author 'alvmontes'
description 'HUD minimalista: estado del jugador, voz, velocímetro y ubicación'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/utils.lua',
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}
