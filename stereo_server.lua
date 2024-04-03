------------------------------------------
-- FOUILLE de POUBELLES par #stereochoc --
--  pour 5DEV https://discord.gg/5dev   --
------------------------------------------
ESX = nil
local objects = {}

Citizen.CreateThread(function()
    if Config.UseLegacy then
        ESX = exports["es_extended"]:getSharedObject()       
    else 
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end
end)

while ESX == nil do
    print(">>>Loading ESX<<<")
    Citizen.Wait(0)
end

function ExecuteSql(query)
    local IsBusy = true
    local result = nil
    if Config.Mysql == "oxmysql" then
        if MySQL == nil then
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.query(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.Mysql == "ghmattimysql" then
        exports.ghmattimysql:execute(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    elseif Config.Mysql == "mysql-async" then   
        MySQL.Async.fetchAll(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

function tointeger( x )
    num = tonumber( x )
    return num < 0 and math.ceil( num ) or math.floor( num )
end

RegisterServerEvent('stereo-fouille:giveReward')
AddEventHandler('stereo-fouille:giveReward', function()
    local src=source
    local xPlayer = ESX.GetPlayerFromId(src)
    local ped = GetPlayerPed(src)
    UserLoot = xPlayer.identifier

    local giveitem = false

    local data = ExecuteSql("SELECT * FROM `stereo_fouille` where UserLoot=\"" .. UserLoot .. "\"")
    local alreadyinDb = false
    for k,v in pairs(data) do
        -- on a une ligne en bdd sur ces coordonnees
        alreadyinDb = true
        -- on va convertir l'heure en bdd pour pouvoir connaitre le delai
        local pattern = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
        local timeToConvert = v.TimeLastLoot
        local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
        local TimeNow = os.date("%Y/%m/%d %X")
        local runyearNow, runmonthNow, rundayNow, runhourNow, runminuteNow, runsecondsNow = TimeNow:match(pattern)

        local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
        local convertedTimestampNow = os.time({year = runyearNow, month = runmonthNow, day = rundayNow, hour = runhourNow, min = runminuteNow, sec = runsecondsNow})
        local DelayFromLastLoot = tointeger((convertedTimestampNow - convertedTimestamp)/60)

        if (DelayFromLastLoot > Config.DelayToLoot ) then
            ExecuteSql("UPDATE `stereo_fouille` SET TimeLastLoot = \""..os.date("%Y/%m/%d %X").."\" WHERE UserLoot = \"" .. UserLoot.."\"")
            giveitem = true
        end

    end
    if not alreadyinDb then
        ExecuteSql("INSERT INTO `stereo_fouille` (`UserLoot`, `TimeLastLoot`) VALUES ('"..UserLoot.."', '"..os.date("%Y/%m/%d %X").."')")
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
