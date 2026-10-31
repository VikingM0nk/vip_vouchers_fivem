local menuOpen = false

local function notify(message)
  BeginTextCommandThefeedPost('STRING')
  AddTextComponentSubstringPlayerName(message)
  EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('vip_vouchers:client:notify', function(message)
  notify(message)
end)

local function openMenuRequest()
  if menuOpen then
    return
  end

  TriggerServerEvent('vip_vouchers:server:requestMenu')
end

RegisterCommand(Config.Access.command, function()
  openMenuRequest()
end, false)

RegisterNetEvent('vip_vouchers:client:openMenuRequest', openMenuRequest)

if Config.Access.keybind and Config.Access.keybind.enabled then
  RegisterKeyMapping(
    Config.Access.command,
    Config.Access.keybind.description or 'Open VIP Vouchers',
    'keyboard',
    Config.Access.keybind.defaultKey or 'F7'
  )
end

RegisterNetEvent('vip_vouchers:client:openMenu', function(payload)
  menuOpen = true
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = 'open',
    data = payload,
  })
end)

local function closeMenu()
  if not menuOpen then
    return
  end

  menuOpen = false
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
  closeMenu()
  cb({ ok = true })
end)

RegisterNUICallback('redeem', function(data, cb)
  if data and data.categoryId and data.entryId then
    TriggerServerEvent(
      'vip_vouchers:server:redeem',
      data.categoryId,
      data.entryId,
      data.selectedChoices
    )
  end
  cb({ ok = true })
end)

RegisterNUICallback('purchase', function(data, cb)
  if data and data.url then
    TriggerServerEvent('vip_vouchers:server:purchaseLinkOpened', data.url, data.roleKey, data.providerId)
  end
  cb({ ok = true })
end)

RegisterNetEvent('vip_vouchers:client:redeemResult', function(success, entryId)
  SendNUIMessage({
    action = 'redeemResult',
    success = success,
    entryId = entryId,
  })
end)

CreateThread(function()
  while true do
    if menuOpen and IsControlJustReleased(0, 322) then
      closeMenu()
    end
    Wait(0)
  end
end)
