Utils = Utils or {}

function Utils.Debug(...)
  if GetConvar('vip_vouchers_debug', '0') == '1' then
    print('[vip_vouchers]', ...)
  end
end

function Utils.TableContains(tbl, value)
  for i = 1, #tbl do
    if tbl[i] == value then
      return true
    end
  end
  return false
end

function Utils.TableContainsAny(needles, haystack)
  if not needles or not haystack then
    return false
  end

  for i = 1, #needles do
    local needle = tostring(needles[i])
    for j = 1, #haystack do
      if needle == tostring(haystack[j]) then
        return true
      end
    end
  end

  return false
end

function Utils.IsPlaceholder(value)
  if type(value) ~= 'string' then
    return false
  end
  return value:find('PUT_') ~= nil or value == '' or value:find('your%-store') ~= nil or value:find('yourstore') ~= nil
end

function Utils.GetRoleDefinition(roleKey)
  if type(roleKey) ~= 'string' then
    return nil
  end

  local roles = Config.DiscordRoles or {}
  return roles[roleKey]
end

function Utils.GetPaymentProviders()
  local providers = {}
  local payments = Config.Payments or {}

  for providerId, provider in pairs(payments) do
    if provider.enabled ~= false then
      providers[#providers + 1] = {
        id = providerId,
        label = provider.label or providerId,
      }
    end
  end

  table.sort(providers, function(a, b)
    return a.label < b.label
  end)

  return providers
end

function Utils.NormalizePurchaseLinks(links)
  local normalized = {}

  if type(links) ~= 'table' then
    return normalized
  end

  for providerId, url in pairs(links) do
    if type(url) == 'string' and not Utils.IsPlaceholder(url) then
      normalized[providerId] = url
    end
  end

  return normalized
end

function Utils.MergePurchaseLinks(...)
  local merged = {}

  for i = 1, select('#', ...) do
    local links = select(i, ...)
    if type(links) == 'table' then
      for providerId, url in pairs(links) do
        if type(url) == 'string' and not Utils.IsPlaceholder(url) then
          merged[providerId] = url
        end
      end
    end
  end

  return merged
end

function Utils.RolePurchaseLinks(roleKey)
  local definition = Utils.GetRoleDefinition(roleKey)
  if not definition then
    return {}
  end

  return Utils.MergePurchaseLinks(
    definition.purchaseLinks,
    definition.purchaseUrl and { default = definition.purchaseUrl } or nil
  )
end

function Utils.EntryPurchaseLinks(entry, productOverride)
  if entry.purchaseLinks then
    return Utils.MergePurchaseLinks(entry.purchaseLinks, productOverride)
  end

  if entry.rolesAny then
    for i = 1, #entry.rolesAny do
      local links = Utils.RolePurchaseLinks(entry.rolesAny[i])
      if next(links) then
        return Utils.MergePurchaseLinks(links, productOverride)
      end
    end
  end

  local store = Config.Store or {}
  return Utils.MergePurchaseLinks(
    productOverride,
    {
      squaresite = store.squaresiteUrl,
      paypal = store.paypalUrl,
    }
  )
end

function Utils.ResolveRoleKey(roleKey)
  local definition = Utils.GetRoleDefinition(roleKey)
  if not definition then
    return roleKey, nil
  end

  local roleId = definition.roleId
  if Utils.IsPlaceholder(roleId) then
    return nil, definition
  end

  return tostring(roleId), definition
end

function Utils.ResolveRoleKeys(roleKeys)
  local roleIds = {}
  local definitions = {}
  local seen = {}

  if type(roleKeys) ~= 'table' then
    return roleIds, definitions
  end

  for i = 1, #roleKeys do
    local key = tostring(roleKeys[i])
    local roleId, definition = Utils.ResolveRoleKey(key)

    if roleId and not seen[roleId] then
      seen[roleId] = true
      roleIds[#roleIds + 1] = roleId
      definitions[#definitions + 1] = {
        key = key,
        roleId = roleId,
        label = definition and definition.label or key,
        badge = definition and definition.badge or key,
        color = definition and definition.color or nil,
        purchaseLinks = Utils.RolePurchaseLinks(key),
      }
    elseif definition and not seen[key] then
      seen[key] = true
      definitions[#definitions + 1] = {
        key = key,
        roleId = nil,
        label = definition.label or key,
        badge = definition.badge or key,
        color = definition.color or nil,
        purchaseLinks = Utils.RolePurchaseLinks(key),
      }
    elseif not definition and not Utils.IsPlaceholder(key) and not seen[key] then
      seen[key] = true
      roleIds[#roleIds + 1] = key
    end
  end

  return roleIds, definitions
end

function Utils.NormalizeRoleIds(values)
  local roles = {}
  local seen = {}

  if type(values) ~= 'table' then
    return roles
  end

  local roleIds, _ = Utils.ResolveRoleKeys(values)
  for i = 1, #roleIds do
    local roleId = tostring(roleIds[i])
    if not seen[roleId] then
      seen[roleId] = true
      roles[#roles + 1] = roleId
    end
  end

  return roles
end

function Utils.CollectAllRoleIds()
  local roles = {}
  local seen = {}

  local function addRoleId(roleId)
    if roleId and not Utils.IsPlaceholder(roleId) and not seen[roleId] then
      seen[roleId] = true
      roles[#roles + 1] = roleId
    end
  end

  for _, definition in pairs(Config.DiscordRoles or {}) do
    if definition.roleId then
      addRoleId(tostring(definition.roleId))
    end
  end

  for i = 1, #Config.Vouchers do
    local category = Config.Vouchers[i]
    for j = 1, #(category.entries or {}) do
      local entry = category.entries[j]
      local resolved = Utils.NormalizeRoleIds(entry.rolesAny or {})
      for k = 1, #resolved do
        addRoleId(resolved[k])
      end
    end
  end

  return roles
end

function Utils.FindVoucherEntry(categoryId, entryId)
  for i = 1, #Config.Vouchers do
    local category = Config.Vouchers[i]
    if category.id == categoryId then
      for j = 1, #(category.entries or {}) do
        local entry = category.entries[j]
        if entry.id == entryId then
          return category, entry
        end
      end
    end
  end

  return nil, nil
end

function Utils.BuildEntryMeta(entry)
  local _, definitions = Utils.ResolveRoleKeys(entry.rolesAny or {})
  local badges = {}

  for i = 1, #definitions do
    badges[#badges + 1] = {
      key = definitions[i].key,
      label = definitions[i].badge or definitions[i].label,
      color = definitions[i].color,
    }
  end

  return {
    badges = badges,
    purchaseLinks = Utils.EntryPurchaseLinks(entry),
    pickCount = entry.data and entry.data.pickCount or nil,
    choices = entry.data and entry.data.choices or nil,
  }
end

function Utils.FindPickChoice(entry, choiceId)
  local choices = entry.data and entry.data.choices or {}
  for i = 1, #choices do
    if choices[i].id == choiceId then
      return choices[i]
    end
  end
  return nil
end
