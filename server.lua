ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterUsableItem('radio', function(source)
	local Player = ESX.GetPlayerFromId(source)
	TriggerClientEvent('radio:use', source)
end)

ESX.RegisterServerCallback('radio:getinventoryitem', function(source, cb)
    local Player = ESX.GetPlayerFromId(source)
    if Player.getInventoryItem('radio') >= 1 then
        cb(true)
    else
        cb(false)
    end    
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local Players = ESX.GetPlayers()
        for i=1, #Players, 1 do
            local Player = ESX.GetPlayerFromId(Players[i])
            if Player ~= nil then
                if Player.getInventoryItem('radio').count == 0 then
                    local source = Players[i]
                    TriggerClientEvent('radio:noitemdrop', source)
                    break
                end
            end
        end        
    end
end)