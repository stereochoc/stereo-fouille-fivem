------------------------------------------
-- FOUILLE de POUBELLES par #stereochoc --
--  pour 5DEV https://discord.gg/5dev   --
------------------------------------------

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX = nil
objects = {}
local OptionsInteractionTrash = {
    {
        name = 'FouillePoubelle',
        event = 'FouillePoubelle',
        icon = 'fa-solid fa-trash',
        label = 'Fouiller la poubelle',
        canInteract = function(entity, distance, coords, name)
            if distance < Config.Distance then
                return true
            end
            return false
        end
    }
}

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
    exports.ox_target:addModel(Config.TrashCans.Model, OptionsInteractionTrash)
end)

AddEventHandler('FouillePoubelle', function()
    local ped = PlayerPedId()
    local lib, anim = 'amb@prop_human_bum_bin@base', 'base'
    local duration = Config.SearchTime * 1000

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
end)
