fx_version 'bodacious'

version  '2.0.7'

games { 'gta5' }

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@http-wrapper/server/server.lua',
    'server/server.lua'
}
