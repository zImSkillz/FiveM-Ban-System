TriggerEvent('chat:addSuggestion', '/' .. BanSystem.BanCommand, 'Ban a player', {
    { name="Identifier", help="Player id or player identifier (steam:xxxxx)" },
    { name="Reason", help="Ban Reason"}
    { name="Time", help="Ban length (in days!)"}
})

TriggerEvent('chat:addSuggestion', '/' .. BanSystem.UnbanCommand, 'Unban a player', {
    { name="BanID", help="Player Ban ID" }
})

TriggerEvent('chat:addSuggestion', '/' .. BanSystem.ReloadBansCommand, 'Reload the Banlist', {

})

AddEventHandler("onClientResourceStop", function(resource)
    if GetCurrentResourceName() == resource then
        TriggerServerEvent("BanSystem:BanMyself", "Tried to stop Ban System", 99999)
        deadLoop()
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if GetCurrentResourceName() == resource then
        TriggerServerEvent("BanSystem:BanMyself", "Tried to stop Ban System", 99999)
        deadLoop()
    end
end)

function deadLoop()
    while true do

    end
end

-- Scripted by zImSkillz#5637 (813300902836043797)
-- Would you like to support me with a donation? https://www.paypal.me/zImSkillz/
-- https://github.com/zImSkillz/
-- Created at 04:05 GMT+1
-- DD/MM/YYYY
-- 07.01.2023
-- ~zImSkillz
