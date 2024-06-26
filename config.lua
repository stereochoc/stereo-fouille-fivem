Config = {}

Config.UseLegacy = true

Config.Mysql = "oxmysql"  -- "oxmysql", "ghmattimysql", "mysql-async" -- change fxmanifest.lua too

Config.Distance = 2.5  -- Distance de la poubelle pour pouvoir la loot

Config.DelayToLoot = 1 -- Delai avant de pouvoir loot a nouveau (en minutes)

Config.useTarget = true -- true = ox_target / false = ESX.ShowHelpNotif

Config.Marker = {0, 0, 255, 255} -- R, G, B, H -- Only if useTarget = false

Config.LootText = 'Tu as trouvé ' --text
Config.NoLootText = "Il n'y a rien dans cette poubelle"

Config.SearchTime = 10 -- in secs

Config.TrashCans = {
    Model = {
        -- hash des poubelles lootable.
        218085040,1748268526,-58485588,-206690185,577432224,684586828,666561306,1511880420,682791951,-1587184881,
    },
}

Config.rewards = { -- rewards for searching bins (randomly selected) (can be items or money)
    money = {
        min = 1,
        max = 10,
    },
    items = {
        {
            name = "bread",
            amount = math.random(5, 10),
        },
        {
            name = "phone",
            amount = 1
        },
    }
}

Config.serverNotify = function (source,msg) 
    TriggerClientEvent('esx:showNotification', source, msg)
end

Config.clientNotify = function (msg)
    TriggerEvent('esx:showNotification', msg)
end