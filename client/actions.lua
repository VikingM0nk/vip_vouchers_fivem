local function loadModel(model)
  local hash = type(model) == 'string' and joaat(model) or model
  if not IsModelInCdimage(hash) then
    return nil
  end

  RequestModel(hash)
  local timeout = GetGameTimer() + 10000

  while not HasModelLoaded(hash) do
    if GetGameTimer() > timeout then
      return nil
    end
    Wait(0)
  end

  return hash
end

local function applyVehicleOptions(vehicle, data)
  if data.livery ~= nil then
    SetVehicleLivery(vehicle, data.livery)
  end

  if data.extras then
    for extraId, enabled in pairs(data.extras) do
      SetVehicleExtra(vehicle, tonumber(extraId), not enabled)
    end
  end

  if data.colors then
    SetVehicleColours(
      vehicle,
      data.colors.primary or 0,
      data.colors.secondary or 0
    )
  end

  SetVehicleOnGroundProperly(vehicle)
  SetEntityAsMissionEntity(vehicle, true, true)
  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
  SetVehicleNeedsToBeHotwired(vehicle, false)
  SetVehRadioStation(vehicle, 'OFF')
end

RegisterNetEvent('vip_vouchers:client:spawnVehicle', function(data)
  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  local forward = GetEntityForwardVector(ped)
  local spawn = coords + (forward * 4.0)

  local hash = loadModel(data.model)
  if not hash then
    TriggerEvent('vip_vouchers:client:notify', 'Invalid vehicle model.')
    return
  end

  local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, heading, true, false)
  if vehicle == 0 then
    SetModelAsNoLongerNeeded(hash)
    TriggerEvent('vip_vouchers:client:notify', 'Could not spawn vehicle.')
    return
  end

  applyVehicleOptions(vehicle, data or {})
  TaskWarpPedIntoVehicle(ped, vehicle, -1)
  SetModelAsNoLongerNeeded(hash)
end)

RegisterNetEvent('vip_vouchers:client:giveWeapon', function(weapon, ammo)
  local ped = PlayerPedId()
  local hash = joaat(weapon)

  GiveWeaponToPed(ped, hash, ammo or 0, false, true)
end)
