function Bridge.Notify(source, message, ntype)
  if GetResourceState('ox_lib') == 'started' then
    TriggerClientEvent('ox_lib:notify', source, {
      description = message,
      type = ntype or 'inform',
    })
    return
  end

  if Bridge.framework == 'esx' and Bridge.object then
    TriggerClientEvent('esx:showNotification', source, message)
    return
  end

  if Bridge.framework == 'qb' and Bridge.object then
    TriggerClientEvent('QBCore:Notify', source, message, ntype or 'primary')
    return
  end

  if Bridge.framework == 'qbx' then
    TriggerClientEvent('qbx_core:client:notify', source, message, ntype or 'inform')
    return
  end

  TriggerClientEvent('vip_vouchers:client:notify', source, message)
end

function Bridge.GiveWeapon(source, weapon, ammo)
  TriggerClientEvent('vip_vouchers:client:giveWeapon', source, weapon, ammo or 0)
end
