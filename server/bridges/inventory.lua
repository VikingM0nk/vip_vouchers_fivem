function Bridge.GiveItem(source, item, count)
  count = count or 1
  local inventory = Bridge.inventory

  if inventory == 'ox' then
    return exports.ox_inventory:AddItem(source, item, count) ~= false
  end

  if inventory == 'qb' or inventory == 'ps' or inventory == 'lj' then
    local player = Bridge.GetPlayer(source)
    if player and player.Functions and player.Functions.AddItem then
      return player.Functions.AddItem(item, count) ~= false
    end
    return false
  end

  if inventory == 'qs' then
    return exports['qs-inventory']:AddItem(source, item, count) ~= false
  end

  if inventory == 'codem' then
    return exports['codem-inventory']:AddItem(source, item, count) ~= false
  end

  if inventory == 'origen' then
    return exports.origen_inventory:AddItem(source, item, count) ~= false
  end

  if inventory == 'core' then
    return exports.core_inventory:addItem(source, item, count) ~= false
  end

  if inventory == 'esx' and Bridge.object then
    local xPlayer = Bridge.object.GetPlayerFromId(source)
    if xPlayer then
      xPlayer.addInventoryItem(item, count)
      return true
    end
    return false
  end

  Utils.Debug('No inventory bridge available for item:', item)
  return false
end

function Bridge.GetPlayer(source)
  if Bridge.framework == 'esx' and Bridge.object then
    return Bridge.object.GetPlayerFromId(source)
  end

  if Bridge.framework == 'qb' and Bridge.object then
    return Bridge.object.Functions.GetPlayer(source)
  end

  if Bridge.framework == 'qbx' then
    return exports.qbx_core:GetPlayer(source)
  end

  return nil
end
