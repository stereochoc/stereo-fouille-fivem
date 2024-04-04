fx_version 'adamant'

game 'gta5'

shared_scripts {
	'config.lua',
}

client_scripts {
	'stereo_client.lua',
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	--"@oxmysql/lib/MySQL.lua",
	'stereo_server.lua',
}
