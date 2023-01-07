--[[
    ███████╗██╗███╗   ███╗███████╗██╗  ██╗██╗██╗     ██╗     ███████╗
    ╚══███╔╝██║████╗ ████║██╔════╝██║ ██╔╝██║██║     ██║     ╚══███╔╝
      ███╔╝ ██║██╔████╔██║███████╗█████╔╝ ██║██║     ██║       ███╔╝ 
     ███╔╝  ██║██║╚██╔╝██║╚════██║██╔═██╗ ██║██║     ██║      ███╔╝  
    ███████╗██║██║ ╚═╝ ██║███████║██║  ██╗██║███████╗███████╗███████╗
    ╚══════╝╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝
					Developer: zImSkillz#5637
						> Let's Ban the Player's
]]--

fx_version 'cerulean'
games { 'gta5' }

author 'zImSkillz'

shared_script 'Config/Config.lua'

client_scripts {
    'Client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'Server/*.lua'
}

lua54 'yes'