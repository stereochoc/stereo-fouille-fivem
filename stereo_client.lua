------------------------------------------
-- FOUILLE de POUBELLES par #stereochoc --
--  pour 5DEV https://discord.gg/5dev   --
------------------------------------------
ESX = nil
Citizen.CreateThread(function()
    print("====================================== Loading Stereo-fouille =======================================")
    print("====================================== https://discord.gg/5dev ======================================")
    if Config.UseLegacy then
        ESX = exports["es_extended"]:getSharedObject()       
    else 
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end
end)

function SearchInTrash(ped, lib, anim, duration)
    ESX.Streaming.RequestAnimDict(lib, function()
        TaskPlayAnim(ped, lib, anim, 8.0, -8.0, duration, 1, 0, false, false, false)

        Wait(1)
        while IsEntityPlayingAnim(ped, lib, anim, 3) do
            Citizen.Wait(0)
            DisableAllControlActions(0)
            FreezeEntityPosition(ped, true)
        end
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        isSearching = false
        blocked = true
        TriggerServerEvent('stereo-fouille:giveReward')
    end)
end

Citizen.CreateThread(function()
    if Config.useTarget then 
        local OptionsInteractionTrash = {
            {
                name = 'FouillePoubelle', event = 'FouillePoubelle', icon = 'fa-solid fa-trash', label = 'Fouiller la poubelle',
                canInteract = function(entity, distance, coords, name)
                    if distance < Config.Distance then
                        return true
                    end
                    return false
                end
            }
        }
        exports.ox_target:addModel(Config.TrashCans.Model, OptionsInteractionTrash)
        AddEventHandler('FouillePoubelle', function()
            local ped = PlayerPedId()
            local lib, anim = 'amb@prop_human_bum_bin@base', 'base'
            local duration = Config.SearchTime * 1000
        
            SearchInTrash(ped, lib, anim, duration)
        end)
    else
        while true do
            local wait = 600
            local object, dist = ESX.Game.GetClosestObject()

            if object ~= 0 then
                local hash = GetEntityModel(object)
                local coord = GetEntityCoords(object)

                for _, model in ipairs(Config.TrashCans.Model) do 
                    if hash == model then
                        if dist <= 3.0 then
                            wait = 0
                            DrawMarker(0, coord.x, coord.y, coord.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, Config.Marker[1], Config.Marker[2], Config.Marker[3], Config.Marker[4], false, true, true, false)
                        end

                        if dist <= 2.0 then
                            wait = 0
                            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour fouiller la poubelle')
                            if IsControlJustPressed(1, 51) then
                                local ped = PlayerPedId()
                                local lib, anim = 'amb@prop_human_bum_bin@base', 'base'
                                local duration = Config.SearchTime * 1000
                                SearchInTrash(ped, lib, anim, duration)
                            end
                        end
                    end
                end
            end
            Citizen.Wait(wait)
        end
    end
end)

