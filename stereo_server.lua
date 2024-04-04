------------------------------------------
-- FOUILLE de POUBELLES par #stereochoc --
--  pour 5DEV https://discord.gg/5dev   --
------------------------------------------
ESX = nil
local objects = {}

Citizen.CreateThread(function()
    print("====================================== Loading Stereo-fouille =======================================")
    print("====================================== https://discord.gg/5dev ======================================")
    if Config.UseLegacy then
        ESX = exports["es_extended"]:getSharedObject()       
    else 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

function ExecuteSql(query, params, cb)
    if Config.Mysql == "oxmysql" then
        exports.oxmysql:execute(query, params, cb)
    elseif Config.Mysql == "ghmattimysql" then
        exports.ghmattimysql:execute(query, params, cb)
    elseif Config.Mysql == "mysql-async" then
        MySQL.Async.fetchAll(query, params, cb)
    else
        print("Erreur : Aucun driver SQL a été détecté")
    end
end

function tointeger( x )
    num = tonumber( x )
    return num < 0 and math.ceil( num ) or math.floor( num )
end

RegisterServerEvent('stereo-fouille:giveReward')
AddEventHandler('stereo-fouille:giveReward', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local ped = GetPlayerPed(src)
    local UserLoot = xPlayer.identifier

    local giveitem = false

    ExecuteSql("SELECT * FROM `stereo_fouille` WHERE UserLoot=?", {UserLoot}, function(data)
        local alreadyinDb = false
        for k, v in pairs(data) do
            alreadyinDb = true
            local pattern = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
            local timeToConvert = v.TimeLastLoot
            local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
            local TimeNow = os.date("%Y/%m/%d %X")
            local runyearNow, runmonthNow, rundayNow, runhourNow, runminuteNow, runsecondsNow = TimeNow:match(pattern)

            local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
            local convertedTimestampNow = os.time({year = runyearNow, month = runmonthNow, day = rundayNow, hour = runhourNow, min = runminuteNow, sec = runsecondsNow})
            local DelayFromLastLoot = tointeger((convertedTimestampNow - convertedTimestamp) / 60)

            if DelayFromLastLoot > Config.DelayToLoot then
                ExecuteSql("UPDATE `stereo_fouille` SET TimeLastLoot=? WHERE UserLoot=?", {os.date("%Y/%m/%d %X"), UserLoot})
                giveitem = true
            end
        end

        if not alreadyinDb then
            ExecuteSql("INSERT INTO `stereo_fouille` (`UserLoot`, `TimeLastLoot`) VALUES (?, ?)", {UserLoot, os.date("%Y/%m/%d %X")})
            giveitem = true
        end

        if giveitem then
            local reward = Config.rewards
            local randomType = math.random(1, 10)

            if randomType <= 5 then
                local randomMoney = math.random(reward.money.min, reward.money.max)
                xPlayer.addMoney(randomMoney)
                Config.serverNotify(src, Config.LootText .. randomMoney .. ' $')
            else
                local randomItem = math.random(1, #reward.items)
                local item = reward.items[randomItem]
                xPlayer.addInventoryItem(item.name, item.amount)
                Config.serverNotify(src, Config.LootText .. item.amount .. ' ' .. item.name)
            end
        else
            Config.serverNotify(src, Config.NoLootText)    
        end
    end)
end)
