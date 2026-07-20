local escorting = false
local escorted = false
local escortTarget = nil

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    if closestDistance ~= -1 and closestDistance <= Config.MaxDistance then
        return closestPlayer
    else
        return nil
    end
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

RegisterNetEvent("escort:start")
AddEventHandler("escort:start", function(source)
    local playerPed = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(source))

    escorted = true

    LoadAnim(Config.AnimDict)

    AttachEntityToEntity(
        playerPed,
        targetPed,
        0,
        Config.Offset.x,
        Config.Offset.y,
        Config.Offset.z,
        0.0, 0.0, 0.0,
        false, false, false, false, 2, true
    )

    TaskPlayAnim(playerPed, Config.AnimDict, Config.AnimName, 8.0, -8.0, -1, 49, 0, false, false, false)
end)

RegisterNetEvent("escort:stop")
AddEventHandler("escort:stop", function()
    local playerPed = PlayerPedId()

    escorting = false
    escorted = false
    escortTarget = nil

    DetachEntity(playerPed, true, false)
    ClearPedTasks(playerPed)
end)

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, Config.Key) then
            if not escorting then
                local closestPlayer = GetClosestPlayer()

                if closestPlayer then
                    escorting = true
                    escortTarget = GetPlayerServerId(closestPlayer)

                    TriggerServerEvent("escort:sync", escortTarget)
                end
            else
                TriggerServerEvent("escort:stop", escortTarget)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if escorting then
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
        end
    end
end)
