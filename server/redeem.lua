Redeem = Redeem or {}

local cooldowns = {}

local function isOnCooldown(source)
  local untilAt = cooldowns[source]
  if not untilAt then
    return false
  end

  if os.time() >= untilAt then
    cooldowns[source] = nil
    return false
  end

  return true
end

local function setCooldown(source)
  local seconds = Config.Limits.redeemCooldownSeconds or 10
  cooldowns[source] = os.time() + seconds
end

local function executeAction(source, action, data)
  if action == 'spawn_vehicle' then
    TriggerClientEvent('vip_vouchers:client:spawnVehicle', source, data or {})
    return true
  end

  if action == 'give_weapon' then
    Bridge.GiveWeapon(source, data.weapon, data.ammo)
    return true
  end

  if action == 'give_item' then
    if Bridge.GiveItem(source, data.item, data.count or 1) then
      return true
    end

    if Bridge.inventory == 'none' then
      Bridge.Notify(source, Locale.Get('no_inventory'))
      return false
    end

    return false
  end

  Utils.Debug('Unknown voucher action:', action)
  return false
end

local function validatePickChoices(entry, selectedChoices)
  local pickCount = entry.data and entry.data.pickCount or 0
  local choices = entry.data and entry.data.choices or {}

  if pickCount <= 0 or #choices == 0 then
    return false, 'redeem_invalid'
  end

  if type(selectedChoices) ~= 'table' then
    return false, 'pick_invalid_count'
  end

  if #selectedChoices ~= pickCount then
    return false, 'pick_invalid_count'
  end

  local seen = {}
  local resolved = {}

  for i = 1, #selectedChoices do
    local choiceId = selectedChoices[i]
    if type(choiceId) ~= 'string' or seen[choiceId] then
      return false, 'pick_invalid_choice'
    end

    local choice = Utils.FindPickChoice(entry, choiceId)
    if not choice then
      return false, 'pick_invalid_choice'
    end

    seen[choiceId] = true
    resolved[#resolved + 1] = choice
  end

  return true, resolved
end

function Redeem.Attempt(source, categoryId, entryId, gates, selectedChoices, callback)
  if isOnCooldown(source) then
    callback(false, 'redeem_cooldown')
    return
  end

  local category, entry = Utils.FindVoucherEntry(categoryId, entryId)
  if not category or not entry then
    callback(false, 'redeem_invalid')
    return
  end

  gates = gates or { roles = {} }

  if not Access.EntryAllowed(entry, gates) then
    callback(false, 'redeem_no_access')
    return
  end

  if entry.action == 'pick_multiple' then
    local valid, resolvedOrReason = validatePickChoices(entry, selectedChoices)
    if not valid then
      callback(false, resolvedOrReason)
      return
    end

    for i = 1, #resolvedOrReason do
      local choice = resolvedOrReason[i]
      local ok = executeAction(source, choice.action, choice.data)
      if not ok then
        callback(false, 'redeem_failed')
        return
      end
    end

    setCooldown(source)
    callback(true, 'pick_success')
    return
  end

  local ok = executeAction(source, entry.action, entry.data)
  if not ok then
    callback(false, 'redeem_failed')
    return
  end

  setCooldown(source)
  callback(true, 'redeem_success')
end

AddEventHandler('playerDropped', function()
  cooldowns[source] = nil
end)
