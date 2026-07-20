RegisterNetEvent("escort:sync")
AddEventHandler("escort:sync", function(target)
    local src = source
    TriggerClientEvent("escort:start", target, src)
end)

RegisterNetEvent("escort:stop")
AddEventHandler("escort:stop", function(target)
    local src = source
    TriggerClientEvent("escort:stop", target)
    TriggerClientEvent("escort:stop", src)
end)
