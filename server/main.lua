local playerGates = {}

local function buildStoreProducts(gates)
  local products = {}
  local store = Config.Store or {}

  if not store.enabled or not store.showStoreTab then
    return products
  end

  for i = 1, #(store.products or {}) do
    local product = store.products[i]
    local definition = Utils.GetRoleDefinition(product.roleKey)
    if definition then
      local roleIds = Utils.NormalizeRoleIds({ product.roleKey })
      local owned = #roleIds > 0 and Utils.TableContainsAny(roleIds, gates.roles or {})
      local purchaseLinks = Utils.MergePurchaseLinks(
        product.purchaseLinks,
        Utils.RolePurchaseLinks(product.roleKey)
      )

      products[#products + 1] = {
        id = product.roleKey,
        roleKey = product.roleKey,
        label = definition.label or product.roleKey,
        description = product.description or '',
        price = product.price,
        badge = definition.badge or product.roleKey,
        color = definition.color,
        purchaseLinks = purchaseLinks,
        owned = owned,
      }
    end
  end

  return products
end

local function buildMenuPayload(gates)
  local categories = {}
  local showLocked = Config.Store and Config.Store.enabled and Config.Store.showLockedEntries

  for i = 1, #Config.Vouchers do
    local category = Config.Vouchers[i]
    local visibleEntries = {}

    for j = 1, #(category.entries or {}) do
      local entry = category.entries[j]
      local allowed = Access.EntryAllowed(entry, gates)
      if allowed or showLocked then
        local meta = Utils.BuildEntryMeta(entry)
        visibleEntries[#visibleEntries + 1] = {
          id = entry.id,
          label = entry.label,
          description = entry.description,
          action = entry.action,
          locked = not allowed,
          badges = meta.badges,
          purchaseLinks = meta.purchaseLinks,
          pickCount = meta.pickCount,
          choices = meta.choices,
        }
      end
    end

    if #visibleEntries > 0 then
      categories[#categories + 1] = {
        id = category.id,
        label = category.label,
        icon = category.icon,
        entries = visibleEntries,
      }
    end
  end

  return {
    title = Config.UI.title,
    accentGold = Config.UI.accentGold,
    accentPurple = Config.UI.accentPurple,
    storeEnabled = Config.Store and Config.Store.enabled or false,
    paymentProviders = Utils.GetPaymentProviders(),
    instructions = Config.Store and Config.Store.instructions or nil,
    products = buildStoreProducts(gates),
    categories = categories,
  }
end

local function countVisibleEntries(payload)
  local total = 0

  for i = 1, #(payload.categories or {}) do
    total = total + #(payload.categories[i].entries or {})
  end

  return total
end

RegisterNetEvent('vip_vouchers:server:requestMenu', function()
  local src = source

  Access.FetchPlayerGates(src, function(ok, gates, reason)
    if not ok then
      if Config.Store and Config.Store.enabled and Config.Access.allowStoreWithoutRole then
        gates = { roles = {}, inGuild = false }
      else
        Logging.AccessDenied(src, reason or 'menu_open_failed')
        Bridge.Notify(src, Locale.Get(reason or 'menu_open_failed'))
        return
      end
    end

    local canOpen, denyReason = Access.CanOpenMenu(gates)
    if not canOpen then
      if Config.Store and Config.Store.enabled and Config.Access.allowStoreWithoutRole then
        canOpen = true
      else
        Logging.AccessDenied(src, denyReason or 'no_access')
        Bridge.Notify(src, Locale.Get(denyReason or 'no_access'))
        return
      end
    end

    playerGates[src] = gates
    local payload = buildMenuPayload(gates)
    Logging.MenuOpened(src, countVisibleEntries(payload))
    TriggerClientEvent('vip_vouchers:client:openMenu', src, payload)
  end)
end)

RegisterNetEvent('vip_vouchers:server:redeem', function(categoryId, entryId, selectedChoices)
  local src = source

  if type(categoryId) ~= 'string' or type(entryId) ~= 'string' then
    Logging.Redeem(src, categoryId or 'unknown', entryId or 'unknown', false, 'redeem_invalid')
    Bridge.Notify(src, Locale.Get('redeem_invalid'))
    return
  end

  Redeem.Attempt(src, categoryId, entryId, playerGates[src], selectedChoices, function(success, messageKey)
    Logging.Redeem(src, categoryId, entryId, success, messageKey)
    Bridge.Notify(src, Locale.Get(messageKey or (success and 'redeem_success' or 'redeem_failed')))
    TriggerClientEvent('vip_vouchers:client:redeemResult', src, success, entryId)
  end)
end)

RegisterNetEvent('vip_vouchers:server:purchaseLinkOpened', function(url, roleKey, providerId)
  local src = source
  Logging.PurchaseLinkOpened(src, url, roleKey, providerId)
end)

AddEventHandler('playerDropped', function()
  playerGates[source] = nil
end)
