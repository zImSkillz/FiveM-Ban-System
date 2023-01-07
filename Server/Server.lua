-- Locals
BanScreensBase64Saved = {}
PlayerBans = {}
MySQLBanList = {}
Version = "1.0.0"
-- Locals


-- Chat Message Helper
function sendChatMessage(sendTo, message)
    if sendTo > 0 then
        if GetPlayers(sendTo) then
            TriggerClientEvent('chatMessage', sendTo, "[Ban-System]", {255, 0, 0}, message)
        end
    else
        print("^9[^1Ban-System^9] ^0" .. message .. "^0")
    end
end
-- Chat Message Helper


-- Version Checker
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    PerformHttpRequest("https://raw.githubusercontent.com/zImSkillz/FiveM-Ban-System/main/version", function(err, rText, headers)
        if rText == Version then
            sendChatMessage(0, "^2You are using the latest version, have fun!")
        else
            sendChatMessage(0, "^1You are not using the latest version, please update! ^3https://github.com/zImSkillz/FiveM-Ban-System")
        end
    end)

end)
-- Version Checker


-- Json Helper
function loadJsonConfig(config)
	local loadedContent = LoadResourceFile(GetCurrentResourceName(), "Cache/" .. config .. ".json")
	return loadedContent and json.decode(loadedContent) or nil
end

function saveJsonConfig(config, content)
    SaveResourceFile(GetCurrentResourceName(), "Cache/" .. config .. ".json", json.encode(content), -1)
end
-- Json Helper


-- Ban Time Helper
function calculateBanTime(time)
    time = tonumber(time)
    if time > 99999 then
        local currentTime = os.time()
        local endTime = currentTime + 99999 * 24 * 60 * 60
        return(os.date("%Y/%m/%d", endTime))
    else
        local currentTime = os.time()
        local endTime = currentTime + time * 24 * 60 * 60
        return(os.date("%Y/%m/%d", endTime))
    end
end

function split(date)
    local date = date
    local finalDate = {}
    local count = 0
    for s in date:gmatch("[^/r\n]+") do
        count = count + 1
        finalDate[count] = s
    end
    return finalDate
end

function getDifferenceBetweenTwoDates(date)
    local finalDate = split(date)
    timeToCalculate = os.time{year=finalDate[1], month=finalDate[2], day=finalDate[3]}
    calculateTime = os.difftime(os.time(), timeToCalculate) / (24 * 60 * 60)
    finalCalculatedTime = math.floor(calculateTime)
    return finalCalculatedTime
end

function finalGetTime(time)
    local time = time
    local timeLeft = getDifferenceBetweenTwoDates(calculateBanTime(time))
    if timeLeft >= 0 then
        timeLeft = tostring(timeLeft)
        timeLeft = timeLeft:gsub("-", "")
        timeLeft = tostring(timeLeft)
    else
        timeLeft = "unban"
    end
    return timeLeft
end

-- Ban Time Helper


-- Load Functions
function loadBans()
    local cachedLoadedBans = loadJsonConfig("SavedBans")
    local cachedLoadedScreenshots = loadJsonConfig("SavedScreenshots")

    if BanSystem.UseMySQLBanSystem then
        MySQL.Async.fetchAll('SELECT * FROM ban_system_bans', {}, function (identifiers)
            MySQLBanList = {}

            for i=1, #identifiers, 1 do
            table.insert(MySQLBanList, {
                liveid = identifiers[i].liveid,
                xbl = identifiers[i].xbl,
                hwid = identifiers[i].hwid,
                ip = identifiers[i].ip,
                discord = identifiers[i].discord,
                license = identifiers[i].license,
                steamid = identifiers[i].steamid,
                date = identifiers[i].date,
                banneduntil = identifiers[i].banneduntil,
                bannedby = identifiers[i].bannedby,
                reason = identifiers[i].reason,
                })
            end
        end)
        print("^9[^1Ban-System^9] ^2Successfully loaded Bans!^0")
    else
        if cachedLoadedBans ~= nil then
            PlayerBans = cachedLoadedBans
            print("^9[^1Ban-System^9] ^2Successfully loaded Bans!^0")
        else
            print("^9[^1Ban-System^9] ^2Successfully loaded ^1empty ^2Ban list!^0")
        end
    end

    if cachedLoadedScreenshots ~= nil then
        BanScreensBase64Saved = cachedLoadedScreenshots
        print("^9[^1Ban-System^9] ^2Successfully loaded Ban Screenshots!^0")
    else
        print("^9[^1Ban-System^9] ^2Successfully loaded ^1empty ^2Ban Screenshot list!^0")
    end
end

if BanSystem.UseMySQLBanSystem then
    MySQL.ready(function()
        loadBans()
    end)
else
    loadBans()
end

function reloadBans()
    local cachedLoadedBans = loadJsonConfig("SavedBans")
    local cachedLoadedScreenshots = loadJsonConfig("SavedScreenshots")

    if BanSystem.UseMySQLBanSystem then
        MySQL.Async.fetchAll('SELECT * FROM ban_system_bans', {}, function (identifiers)
            MySQLBanList = {}

            for i=1, #identifiers, 1 do
            table.insert(MySQLBanList, {
                liveid = identifiers[i].liveid,
                xbl = identifiers[i].xbl,
                hwid = identifiers[i].hwid,
                ip = identifiers[i].ip,
                discord = identifiers[i].discord,
                license = identifiers[i].license,
                steamid = identifiers[i].steamid,
                date = identifiers[i].date,
                banneduntil = identifiers[i].banneduntil,
                bannedby = identifiers[i].bannedby,
                reason = identifiers[i].reason,
                })
            end
        end)
    else
        if cachedLoadedBans ~= nil then
            PlayerBans = cachedLoadedBans
        else
        end
    end

    if cachedLoadedScreenshots ~= nil then
        BanScreensBase64Saved = cachedLoadedScreenshots
    else
    end
end
-- Load Functions


-- Ban Function
function banPlayer(bannedBy, source, reason, time, bannedOn)
    local bannedBy = bannedBy
    local source = tostring(source)
    local reason = reason
    local time = time
    local bannedOn = bannedOn

    if source ~= nil then
        if reason == nil then
            reason = "Unkown"
        end

        if time == nil then
            time = 99999
        end

        if bannedOn == nil then
            bannedOn = os.date("%Y/%m/%d %H:%M")
        end

        if bannedBy > 0 then
            bannedBy = GetPlayerName(bannedBy)
        else
            bannedBy = "Console"
        end

        local license = "Unkown"
        local playerip = GetPlayerEndpoint(source)
        local playerdiscord = "Unkown"
        local name = GetPlayerName(source)
        local date = bannedOn
        local liveid = "Unkown"
        local xbl = "Unkown"
        local steamid = "Unkown"
        local hwid = GetPlayerToken(source, 0)
        local banneduntil = calculateBanTime(time)
        local reason = reason

        for k,v in pairs(GetPlayerIdentifiers(source))do   
            if string.sub(v, 1, string.len("license:")) == "license:" then
                license = v
            elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                steamid = v
            elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                xbl  = v
            elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                playerip = v
            elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                playerdiscord = v
            elseif string.sub(v, 1, string.len("live:")) == "live:" then
                liveid = v
            end
        end
            
        if playerip == nil then
            playerip = 'Not found'
        end

        if BanSystem.ShowScreenshotInBanScreen then
            if tonumber(source) > 0 then
                if hwid ~= nil or hwid ~= "" then
                    exports['screenshot-basic']:requestClientScreenshot(tonumber(source), {
                        quality = BanSystem.ScreenShotQuality
                    }, function(err, data)
                        BanScreensBase64Saved[hwid] = data
                        saveJsonConfig("SavedScreenshots", BanScreensBase64Saved)
                    end)
                end
            end
        end

        if BanSystem.UseMySQLBanSystem then
            MySQL.Async.execute(
                'INSERT INTO ban_system_bans (license,steamid,ip,discord,name,date,liveid,xbl,hwid,banneduntil,bannedBy,reason) VALUES (@license,@steamid,@ip,@discord,@name,@date,@liveid,@xbl,@hwid,@banneduntil,@bannedBy,@reason)', {
                  ['@license'] = license,
                  ['@steamid'] = steamid,
                  ['@ip'] = playerip,
                  ['@discord'] = playerdiscord,
                  ['@name'] = name,
                  ['@date'] = date,
                  ['@liveid'] = liveid,
                  ['@xbl'] = xbl,
                  ['@hwid'] = hwid,
                  ['@banneduntil'] = banneduntil,
                  ['@bannedby'] = bannedBy,
                  ['@reason'] = reason,
                },
                function ()
              end)

              Citizen.Wait(1250)

              reloadBans()
        else
            PlayerBans[hwid] = {
                information = {
                    license = license,
                    steamid = steamid,
                    ip = playerip,
                    discord = playerdiscord,
                    name = name,
                    date = date,
                    liveid = liveid,
                    xbl = xbl,
                    hwid = hwid,
                    banneduntil = banneduntil,
                    bannedby = bannedBy,
                    reason = reason
                }
            }
            saveJsonConfig("SavedBans", PlayerBans)
        end
        Citizen.Wait(550)
        DropPlayer(source, "[Ban-System] You have been banned! | Try rejoining for more information.")
    else
        sendChatMessage(bannedBy, "Invalid player source! Please use: /ban <player> <reason> <time>")
    end
end

function banOfflinePlayer(bannedBy, source, reason, time, bannedOn)
    local bannedBy = bannedBy
    local source = tostring(source)
    local reason = reason
    local time = time
    local bannedOn = bannedOn

    if source ~= nil then
        if reason == nil then
            reason = "Unkown"
        end

        if time == nil then
            time = 99999
        end

        if bannedOn == nil then
            bannedOn = os.date("%Y/%m/%d %H:%M")
        end

        if bannedBy > 0 then
            bannedBy = GetPlayerName(bannedBy)
        else
            bannedBy = "Console"
        end

        local license = "Offline Player"
        local playerip = "Offline Player"
        local playerdiscord = "Offline Player"
        local name = "Offline Player"
        local date = bannedOn
        local liveid = "Offline Player"
        local xbl = "Offline Player"
        local steamid = "Offline Player"
        local hwid = "Offline Player"
        local banneduntil = calculateBanTime(time)
        local reason = reason

        if string.sub(reason, 1, string.len("steam:")) == "steam:" then
            steamid = reason
        elseif string.sub(reason, 1, string.len("license:")) == "license:" then
            license = reason
        elseif string.sub(reason, 1, string.len("xbl:")) == "xbl:" then
            xbl = reason
        elseif string.sub(reason, 1, string.len("ip:")) == "ip:" then
            ip = reason
        elseif string.sub(reason, 1, string.len("discord:")) == "discord:" then
            playerdiscord = reason
        elseif string.sub(reason, 1, string.len("liveid:")) == "liveid:" then
            liveid = reason
        elseif string.sub(reason, 1, string.len("hwid:")) == "hwid:" then
            hwid = reason
        end

        MySQL.Async.execute(
            'INSERT INTO ban_system_bans (license,steamid,ip,discord,name,date,liveid,xbl,hwid,banneduntil,bannedBy,reason) VALUES (@license,@steamid,@ip,@discord,@name,@date,@liveid,@xbl,@hwid,@banneduntil,@bannedBy,@reason)', {
                ['@license'] = license,
                ['@steamid'] = steamid,
                ['@ip'] = playerip,
                ['@discord'] = playerdiscord,
                ['@name'] = name,
                ['@date'] = date,
                ['@liveid'] = liveid,
                ['@xbl'] = xbl,
                ['@hwid'] = hwid,
                ['@banneduntil'] = banneduntil,
                ['@bannedby'] = bannedBy,
                ['@reason'] = reason,
            },
            function ()
            end)

    end
end
-- Ban Function


-- Ban Event
RegisterServerEvent("BanSystem:BanMyself")
AddEventHandler("BanSystem:BanMyself", function(reason, time)
	local source = source
    local reason = reason

    if tonumber(time) then
        if reason == nil then
            reason = "No Reason"
        end
        banPlayer(0, source, reason, time, nil)
    end
end)
-- Ban Event


-- Ban Screen
    AddEventHandler('playerConnecting', function (playerName, setKickReason, deferrals)
    deferrals.defer()
    local source = source
    local license = "Unkown"
    local playerip = GetPlayerEndpoint(source)
    local playerdiscord = "Unkown"
    local name = GetPlayerName(source)
    local liveid = "Unkown"
    local xbl = "Unkown"
    local steamid = "Unkown"
    local hwid = GetPlayerToken(source, 0)

    for k,v in pairs(GetPlayerIdentifiers(source))do   
        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl  = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            playerip = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            playerdiscord = v
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        end
    end
        
    if playerip == nil then
        playerip = 'Not found'
    end

    local banned = false
    local reason = nil
    local bannedOn = nil
    local bannedBy = nil
    local unbannedOn = nil
    local savedBase64Screenshot = nil
    local remaining = nil

    if BanSystem.UseMySQLBanSystem then
        for i = 1, #MySQLBanList, 1 do
            if (tostring(MySQLBanList[i].license)) == tostring(license) 
            or (tostring(MySQLBanList[i].xbl)) == tostring(xbl) 
            or (tostring(MySQLBanList[i].liveid)) == tostring(liveid) 
            or (tostring(MySQLBanList[i].ip)) == tostring(playerip) 
            or (tostring(MySQLBanList[i].steamid)) == tostring(steamid) 
            or (tostring(MySQLBanList[i].discord)) == tostring(playerdiscord) 
            or (tostring(MySQLBanList[i].hwid)) == GetPlayerToken(source, 0) then
                reason = tostring(MySQLBanList[i].reason)
                bannedOn = tostring(MySQLBanList[i].date)
                unbannedOn = tostring(MySQLBanList[i].banneduntil)
                bannedBy = tostring(MySQLBanList[i].bannedby)
                remaining = finalGetTime(getDifferenceBetweenTwoDates(os.date(tostring(MySQLBanList[i].banneduntil))))
                banned = true
            end
        end
    else
        if PlayerBans[hwid] then
            if (tostring(PlayerBans[hwid].information.license)) == tostring(license) 
            or (tostring(PlayerBans[hwid].information.xbl)) == tostring(xbl) 
            or (tostring(PlayerBans[hwid].information.liveid)) == tostring(liveid) 
            or (tostring(PlayerBans[hwid].information.ip)) == tostring(playerip) 
            or (tostring(PlayerBans[hwid].information.steamid)) == tostring(steamid) 
            or (tostring(PlayerBans[hwid].information.discord)) == tostring(playerdiscord) 
            or (tostring(PlayerBans[hwid].information.hwid)) == GetPlayerToken(source, 0) then
                reason = tostring(PlayerBans[hwid].information.reason)
                bannedOn = tostring(PlayerBans[hwid].information.date)
                unbannedOn = tostring(PlayerBans[hwid].information.banneduntil)
                bannedBy = tostring(PlayerBans[hwid].information.bannedby)
                remaining = finalGetTime(getDifferenceBetweenTwoDates(os.date(tostring(PlayerBans[hwid].information.banneduntil))))

                if remaining == "unban" then
                    unbanHwid(hwid)
                elseif tonumber(remaining) == 0 then
                    unbanHwid(hwid)
                else
                    banned = true
                end
            end
        end
    end

    if BanScreensBase64Saved[hwid] ~= nil then
        savedBase64Screenshot = BanScreensBase64Saved[hwid]
    else
        savedBase64Screenshot = ""
    end

    deferrals.update("💎 [BanSystem] Checking your Connection.. 💎")
    Citizen.Wait(1250)
    if banned then
        Wait(50)
        deferrals.presentCard([==[{
            "type": "AdaptiveCard",
            "body": [
                {
                    "type": "Container",
                    "items": [
                        {
                            "type": "ColumnSet",
                            "columns": [
                                {
                                    "type": "Column",
                                    "items": [
                                        
                                        {
                                            "type": "TextBlock",
                                            "size": "ExtraLarge",
                                            "text": "]==] ..("✈️ Banned by our BanSystem ✈️") .. [==[",
                                            "wrap": true,
                                            "style": "heading",
                                            "horizontalAlignment": "Center"
                                        },
                                        {
                                            "type": "TextBlock",
                                            "size": "Large",
                                            "text": "]==]..("Reason:" .. " ") ..(reason) .. [==[",
                                            "wrap": true,
                                            "style": "heading",
                                            "horizontalAlignment": "Center"
                                        },
                                        {
                                            "type": "TextBlock",
                                            "size": "Medium",
                                            "text": "]==] ..("Banned on: " .. bannedOn .. " | Remaining: " .. remaining .." day/s (" .. unbannedOn .. ")") .. [==[",
                                            "wrap": true,
                                            "style": "heading",
                                            "horizontalAlignment": "Center"
                                        },
                                        {
                                            "type": "TextBlock",
                                            "size": "Medium",
                                            "text": "]==]..("BanID:" .. " ") ..(hwid) .. [==[",
                                            "wrap": true,
                                            "style": "heading",
                                            "horizontalAlignment": "Center"
                                        },
                                        {
                                            "type": "TextBlock",
                                            "size": "Small",
                                            "text": "Discord: ]==] ..(BanSystem.UnbanDiscordLink) .. [==[",
                                            "wrap": true,
                                            "style": "heading",
                                            "horizontalAlignment": "Center"
                                        }
                                    ],
                                    "width": "stretch"
                                }
                            ]
                        }
                    ],
                    "horizontalAlignment": "Left"
                },
                {
                    "type": "Container",
                    "items": [
                        {
                            "type": "Container",
                            "items": [
                                {
                                    "type": "Image",
                                    "url": "]==] .. (savedBase64Screenshot) .. [==[",
                                    "altText": "${status}",
                                    "height": "365px",
                                    "horizontalAlignment": "Center"
                                }
                            ]
                        },
                        {
                            "type": "ActionSet",
                            "actions": [
                                {
                                    "type": "Action.OpenUrl",
                                    "title": "BanSystem Developed by zImSkillz#5637",
                                    "url": "]==] .. ("https://github.com/zImSkillz") .. [==["
                                }
                            ]
                        },
                        {
                            "type": "ActionSet",
                            "actions": [
                                {
                                    "type": "Action.OpenUrl",
                                    "title": "]==] .. ("Copy Ban ID") .. [==[",
                                    "url": "]==] .. ("https://spambude.net/project_lyxos_api/copyAPI.php?copy=" .. hwid) .. [==["
                                }
                            ]
                        }
                    ]
                }
            ],
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "fallbackText": "This card requires Adaptive Cards v1.2 support to be rendered properly."
        }]==],
            function(data, rawData)
        end)
        return
    end
    deferrals.done()
end)
-- Ban Screen


-- Permission Check
function IsPlayerAllowedToBan(source, permission)
    if source > 0 then
        local isAllowed = false
        if IsPlayerAceAllowed(player, permission) then
            isAllowed = true
        end
        return isAllowed
    else
        return true -- Console
    end
end
-- Permission Check


-- Ban Command
RegisterCommand(BanSystem.BanCommand, function(source, args, rawCommand)
    if IsPlayerAllowedToBan(source, "bansystem.banPlayers") then
        if args[1] then
            local hwid = GetPlayerToken(args[1], 0)
            if tonumber(args[1]) and GetPlayers(args[1]) and hwid ~= nil then
                banPlayer(source, args[1], args[2], args[3], nil)
            else
                if BanSystem.UseMySQLBanSystem then
                    banOfflinePlayer(source, args[1], args[2], args[3], nil)
                else
                    if IsPlayerAllowedToBan(source, "bansystem.banOfflinePlayers") then
                        sendChatMessage(source, "You can only ban offline players with You can only ban offline players if MySQL bans are enabled!")
                    else
                        sendChatMessage(source "You don't have permissions to ban offline players!")
                    end
                end
            end
        else
            sendChatMessage(source, "Invalid player source! Please use: /ban <player> <reason> <time>")
        end
    else
        sendChatMessage(source "You don't have permissions to ban players!")
    end
end)
-- Ban Command


-- Unban function
function unbanHwid(hwid)
    local hwid = hwid
    if BanSystem.UseMySQLBanSystem then
        MySQL.Async.fetchAll('SELECT * from ban_system_bans WHERE hwid = @hwid', {['@hwid'] = hwid}, function(result)
            if #result > 0 then
                MySQL.Async.execute('DELETE FROM ban_system_bans WHERE hwid = @hwid',
                {['hwid'] = hwid},
                function(affectedRows)
                end
            )
                Citizen.Wait(1000)
                reloadBans()
                BanScreensBase64Saved[hwid] = nil
                saveJsonConfig("SavedScreenshots", BanScreensBase64Saved)
            else
            end
        end)
    else
        PlayerBans[hwid] = nil
        saveJsonConfig("SavedBans", PlayerBans)
        BanScreensBase64Saved[hwid] = nil
        saveJsonConfig("SavedScreenshots", BanScreensBase64Saved)
        Citizen.Wait(1000)
    end
end
-- Unban function


-- Unban Command
RegisterCommand(BanSystem.UnbanCommand, function(source, args, rawCommand)
    local source = source
    if IsPlayerAllowedToBan(source, "bansystem.unban") then
        if args[1] then
            if BanSystem.UseMySQLBanSystem then
                MySQL.Async.fetchAll('SELECT * from ban_system_bans WHERE hwid = @hwid', {['@hwid'] = args[1]}, function(result)
                    if #result > 0 then
                        MySQL.Async.execute('DELETE FROM ban_system_bans WHERE hwid = @hwid',
                        {['hwid'] = args[1]},
                        function(affectedRows)
                        end
                    )
                        Citizen.Wait(1000)
                        sendChatMessage(source "Player is now unbanned!")
                        reloadBans()
                        BanScreensBase64Saved[args[1]] = nil
                        saveJsonConfig("SavedScreenshots", BanScreensBase64Saved)
                    else
                        sendChatMessage(source "Invailid Ban ID")
                    end
                end)
            else
                if PlayerBans[args[1]] ~= nil then
                    PlayerBans[args[1]] = nil
                    saveJsonConfig("SavedBans", PlayerBans)
                    BanScreensBase64Saved[args[1]] = nil
                    saveJsonConfig("SavedScreenshots", BanScreensBase64Saved)
                    Citizen.Wait(1000)
                    sendChatMessage(source "Player is now unbanned!")
                else
                    sendChatMessage(source "Invailid Ban ID")
                end
            end
        else
            sendChatMessage(source, "Please enter a Ban ID! Please use: /unban <banid>")
        end
    else
        sendChatMessage(source "You don't have permissions to unban any player")
    end
end)
-- Unban Command


-- Reload Command
RegisterCommand(BanSystem.ReloadBansCommand, function(source, args, rawCommand)
    local source = source
    if IsPlayerAllowedToBan(source, "bansystem.reloadBans") then
        reloadBans()
        Citizen.Wait(1250)
        sendChatMessage(source, "Banlist reloaded!")
    else
        sendChatMessage(source "You don't have permissions to reload the ban list!")
    end
end)
-- Reload Command


-- Credits
Citizen.CreateThread(function()
	SetConvarServerInfo("Ban System", "by zImSkillz#5637") -- If you want to support me, don't change :3
end)
-- Credits


-- Scripted by zImSkillz#5637 (813300902836043797)
-- Would you like to support me with a donation? https://www.paypal.me/zImSkillz/
-- https://github.com/zImSkillz/
-- Created at 04:05 GMT+1
-- DD/MM/YYYY
-- 07.01.2023
-- ~zImSkillz
