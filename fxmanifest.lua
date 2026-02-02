fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'lance(aksy)'
description 'aksync credits vSync created by Vespura'
version '1.1.2'
repository 'https://github.com/yigitlance/aksync'

shared_script '@ox_lib/init.lua'
server_scripts {
	'config.lua',
	'locale.lua',
	'locales/*.lua',
	'server/server.lua'}
client_scripts {
	'config.lua',
	'locale.lua',
	'locales/*.lua',
	'client/client.lua'}