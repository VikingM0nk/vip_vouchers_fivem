Bridge = Bridge or {
  framework = 'standalone',
  inventory = 'none',
  object = nil,
}

local function setFramework(name, object)
  Bridge.framework = name
  Bridge.object = object
end

local function setInventory(name)
  Bridge.inventory = name
end

function Bridge.DetectFramework()
  if not Config.AutoDetect.framework then
    return Bridge.framework
  end

  local candidates = {
    {
      name = 'esx',
      resources = { 'es_extended', 'esx_core' },
      init = function(resource)
        return exports[resource]:getSharedObject()
      end,
    },
    {
      name = 'qb',
      resources = { 'qb-core' },
      init = function(resource)
        return exports[resource]:GetCoreObject()
      end,
    },
    {
      name = 'qbx',
      resources = { 'qbx_core' },
      init = function(resource)
        return exports[resource]:GetCoreObject()
      end,
    },
  }

  for i = 1, #candidates do
    local candidate = candidates[i]
    for j = 1, #candidate.resources do
      local resource = candidate.resources[j]
      if GetResourceState(resource) == 'started' then
        local ok, object = pcall(candidate.init, resource)
        setFramework(candidate.name, ok and object or nil)
        return Bridge.framework
      end
    end
  end

  setFramework('standalone', nil)
  return Bridge.framework
end

function Bridge.DetectInventory()
  if not Config.AutoDetect.inventory then
    return Bridge.inventory
  end

  local resources = {
    { name = 'ox', resource = 'ox_inventory' },
    { name = 'qb', resource = 'qb-inventory' },
    { name = 'ps', resource = 'ps-inventory' },
    { name = 'lj', resource = 'lj-inventory' },
    { name = 'qs', resource = 'qs-inventory' },
    { name = 'codem', resource = 'codem-inventory' },
    { name = 'origen', resource = 'origen_inventory' },
    { name = 'core', resource = 'core_inventory' },
  }

  for i = 1, #resources do
    local entry = resources[i]
    if GetResourceState(entry.resource) == 'started' then
      setInventory(entry.name)
      return Bridge.inventory
    end
  end

  if Bridge.framework == 'esx' then
    setInventory('esx')
    return Bridge.inventory
  end

  if Bridge.framework == 'qb' or Bridge.framework == 'qbx' then
    setInventory('qb')
    return Bridge.inventory
  end

  setInventory('none')
  return Bridge.inventory
end

CreateThread(function()
  Bridge.DetectFramework()
  Bridge.DetectInventory()
  Utils.Debug('Bridge detected framework:', Bridge.framework, 'inventory:', Bridge.inventory)
end)
