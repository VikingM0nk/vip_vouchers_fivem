TargetBridge = TargetBridge or { name = 'none' }

function TargetBridge.Detect()
  if not Config.AutoDetect.target then
    return TargetBridge.name
  end

  local resources = {
    { name = 'ox_target', resource = 'ox_target' },
    { name = 'qb-target', resource = 'qb-target' },
    { name = 'qtarget', resource = 'qtarget' },
  }

  for i = 1, #resources do
    local entry = resources[i]
    if GetResourceState(entry.resource) == 'started' then
      TargetBridge.name = entry.name
      TargetBridge.resource = entry.resource
      return TargetBridge.name
    end
  end

  TargetBridge.name = 'none'
  TargetBridge.resource = nil
  return TargetBridge.name
end

function TargetBridge.OpenMenu()
  TriggerEvent('vip_vouchers:client:openMenuRequest')
end

function TargetBridge.RegisterLocation(location)
  local coords = location.coords
  local radius = location.radius or 2.0
  local label = location.label or Config.UI.title
  local icon = location.icon or 'fas fa-gift'

  if TargetBridge.name == 'ox_target' then
    exports.ox_target:addSphereZone({
      coords = coords,
      radius = radius,
      debug = false,
      options = {
        {
          name = ('vip_vouchers_%s'):format(location.id or 'zone'),
          label = label,
          icon = icon,
          onSelect = TargetBridge.OpenMenu,
        },
      },
    })
    return true
  end

  if TargetBridge.name == 'qb-target' then
    exports['qb-target']:AddCircleZone(
      ('vip_vouchers_%s'):format(location.id or 'zone'),
      coords,
      radius,
      {
        name = ('vip_vouchers_%s'):format(location.id or 'zone'),
        debugPoly = false,
        useZ = true,
      },
      {
        options = {
          {
            type = 'client',
            event = 'vip_vouchers:client:openMenuRequest',
            icon = icon,
            label = label,
          },
        },
        distance = radius + 1.0,
      }
    )
    return true
  end

  if TargetBridge.name == 'qtarget' then
    exports.qtarget:AddCircleZone(
      ('vip_vouchers_%s'):format(location.id or 'zone'),
      coords,
      radius,
      {
        name = ('vip_vouchers_%s'):format(location.id or 'zone'),
        debugPoly = false,
        useZ = true,
      },
      {
        options = {
          {
            event = 'vip_vouchers:client:openMenuRequest',
            icon = icon,
            label = label,
          },
        },
        distance = radius + 1.0,
      }
    )
    return true
  end

  return false
end

function TargetBridge.RegisterPed(pedConfig)
  if not pedConfig or not pedConfig.coords then
    return false
  end

  local model = pedConfig.model or 'cs_barry'
  local modelHash = type(model) == 'string' and joaat(model) or model
  local coords = pedConfig.coords
  local label = pedConfig.label or Config.UI.title
  local icon = pedConfig.icon or 'fas fa-gift'

  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do
    Wait(0)
  end

  local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w or 0.0, false, false)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  FreezeEntityPosition(ped, true)

  if TargetBridge.name == 'ox_target' then
    exports.ox_target:addLocalEntity(ped, {
      {
        name = 'vip_vouchers_ped',
        label = label,
        icon = icon,
        onSelect = TargetBridge.OpenMenu,
      },
    })
    return true
  end

  if TargetBridge.name == 'qb-target' then
    exports['qb-target']:AddTargetEntity(ped, {
      options = {
        {
          type = 'client',
          event = 'vip_vouchers:client:openMenuRequest',
          icon = icon,
          label = label,
        },
      },
      distance = 2.5,
    })
    return true
  end

  if TargetBridge.name == 'qtarget' then
    exports.qtarget:AddTargetEntity(ped, {
      options = {
        {
          event = 'vip_vouchers:client:openMenuRequest',
          icon = icon,
          label = label,
        },
      },
      distance = 2.5,
    })
    return true
  end

  return false
end

function TargetBridge.Init()
  TargetBridge.Detect()

  if TargetBridge.name == 'none' then
    return
  end

  if not Config.Target or Config.Target.enabled == false then
    return
  end

  for i = 1, #(Config.Target.locations or {}) do
    TargetBridge.RegisterLocation(Config.Target.locations[i])
  end

  if Config.Target.ped and Config.Target.ped.enabled then
    TargetBridge.RegisterPed(Config.Target.ped)
  end
end

CreateThread(function()
  Wait(1500)
  TargetBridge.Init()
  Utils.Debug('Target bridge detected:', TargetBridge.name)
end)
