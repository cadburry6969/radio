ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
	end
end)

--========================================================
--                  CONFIG
--========================================================
local PMAVOICE = true
local radioMenu = false
local enableCmd = true
local RestrictedChannels = 5
local Locale = {
  ['not_on_radio'] = 'You are currently not on any radio',
  ['on_radio'] = 'You are currently on the radio: ',
  ['joined_to_radio'] = 'You joined the radio: ',
  ['restricted_channel_error'] = 'You can not join encrypted channels!',
  ['you_on_radio'] = 'You are already on the radio: ',
  ['you_leave'] = 'You left the radio',
  ['no_radio'] = 'You dont have a radio'
}
--========================================================
--          EVENTS & FUNCTION & COMMAND
--========================================================
RegisterNetEvent('radio:use')
AddEventHandler('radio:use', function()
  enableRadio(true)
end)

RegisterNetEvent('radio:noitemdrop')
AddEventHandler('radio:noitemdrop', function()
  if PMAVOICE then
    exports["pma-voice"]:setRadioChannel(0)    
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
  else
    exports["mumble-voip"]:SetRadioChannel(0)   
    exports["mumble-voip"]:SetMumbleProperty("radioEnabled", false)
  end
end)

if enableCmd then
  RegisterCommand('radio', function(source, args)  
    ESX.TriggerServerCallback('radio:getinventoryitem', function(check)
      if check then
        enableRadio(true)  
      else
        TriggerEvent('cc-notify',Locale['no_radio'],'default') 
      end
    end)
  end, false)
end

function enableRadio(enable)
  SetNuiFocus(true, true)
  radioMenu = enable
  PhonePlayIn()

  SendNUIMessage({
    type = "enableui",
    enable = enable
  })
end

--========================================================
--                    NUI
--========================================================

RegisterNUICallback('joinRadio', function(data, cb)
    local _source = source
    local PlayerData = ESX.GetPlayerData(_source)      
    if tonumber(data.channel) <= RestrictedChannels then
        if(PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then      
          if PMAVOICE then      
            exports["pma-voice"]:setRadioChannel(tonumber(data.channel))       
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)                         
          else
            exports["mumble-voip"]:SetRadioChannel(tonumber(data.channel))   
            exports["mumble-voip"]:SetMumbleProperty("radioEnabled", true)
          end
          TriggerEvent('cc-notify',Locale['joined_to_radio'] .. data.channel .. ' MHz','default')            
        elseif not (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then  
          TriggerEvent('cc-notify',Locale['restricted_channel_error'],'default')                           
        end
    else
      if tonumber(data.channel) > RestrictedChannels then          
        if PMAVOICE then      
          exports["pma-voice"]:setRadioChannel(tonumber(data.channel))       
          exports["pma-voice"]:setVoiceProperty("radioEnabled", true)                         
        else
          exports["mumble-voip"]:SetRadioChannel(tonumber(data.channel))   
          exports["mumble-voip"]:SetMumbleProperty("radioEnabled", true)
        end            
        TriggerEvent('cc-notify',Locale['joined_to_radio'] .. data.channel .. ' MHz','default')                    
      else
        TriggerEvent('cc-notify',Locale['you_on_radio'] .. data.channel .. ' MHz','default')            
      end
    end    
    cb('ok')
end)

RegisterNUICallback('leaveRadio', function(data, cb)
  if PMAVOICE then
    exports["pma-voice"]:setRadioChannel(0)    
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
  else
    exports["mumble-voip"]:SetRadioChannel(0)   
    exports["mumble-voip"]:SetMumbleProperty("radioEnabled", false)
  end
  TriggerEvent('cc-notify', Locale['you_leave'],'default')           
  cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    enableRadio(false)
    SetNuiFocus(false, false)
    PhonePlayOut()    
    cb('ok')
end)
--========================================================
--                CITIZEN THREADS
--========================================================
Citizen.CreateThread(function()
    while true do
        if radioMenu then                      
            DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown
            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride 
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
            DisableControlAction(1, 37, true) -- Disables INPUT_SELECT_WEAPON (TAB)
            DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing         
            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        end
        Citizen.Wait(0)
    end
end)
