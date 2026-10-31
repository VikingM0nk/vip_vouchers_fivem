Logging = Logging or {}

local function loggingConfig()
  return Config.Logging and Config.Logging.discord
end

function Logging.IsEnabled()
  local cfg = loggingConfig()
  if not Config.Logging or not Config.Logging.enabled or not cfg then
    return false
  end

  local webhookUrl = cfg.webhookUrl
  return webhookUrl and webhookUrl ~= '' and not Utils.IsPlaceholder(webhookUrl)
end

function Logging.EventEnabled(eventName)
  if not Logging.IsEnabled() then
    return false
  end

  local events = Config.Logging.events or {}
  return events[eventName] ~= false
end

local function getPlayerContext(source)
  local license = Identifiers.Get(source, 'license')
  local discordId = Identifiers.GetDiscordId(source)

  return {
    name = GetPlayerName(source) or ('Player %s'):format(source),
    serverId = source,
    license = license or 'unknown',
    discord = discordId and ('<@%s>'):format(discordId) or 'not linked',
    discordId = discordId or 'none',
  }
end

local function isoTimestamp()
  return os.date('!%Y-%m-%dT%H:%M:%SZ')
end

local function sendPayload(payload)
  if not Logging.IsEnabled() then
    return
  end

  local cfg = loggingConfig()
  payload.username = payload.username or cfg.botName or 'VIP Vouchers'

  if cfg.avatarUrl and cfg.avatarUrl ~= '' and not Utils.IsPlaceholder(cfg.avatarUrl) then
    payload.avatar_url = cfg.avatarUrl
  end

  PerformHttpRequest(cfg.webhookUrl, function(statusCode, _, headers)
    if statusCode ~= 204 and statusCode ~= 200 then
      Utils.Debug('Discord webhook failed', statusCode, headers)
    end
  end, 'POST', json.encode(payload), {
    ['Content-Type'] = 'application/json',
  })
end

function Logging.SendEmbed(options)
  if not Logging.IsEnabled() then
    return
  end

  sendPayload({
    embeds = {
      {
        title = options.title or 'VIP Vouchers',
        description = options.description,
        color = options.color or (Config.Logging.colors and Config.Logging.colors.info) or 8060973,
        fields = options.fields or {},
        footer = {
          text = options.footer or 'vip_vouchers',
        },
        timestamp = isoTimestamp(),
      },
    },
  })
end

function Logging.AccessDenied(source, reasonKey)
  if not Logging.EventEnabled('accessDenied') then
    return
  end

  local player = getPlayerContext(source)
  local colors = Config.Logging.colors or {}

  Logging.SendEmbed({
    title = 'Access Denied',
    description = ('**%s** was blocked from opening the VIP menu.'):format(player.name),
    color = colors.warning or 16766720,
    fields = {
      { name = 'Server ID', value = tostring(player.serverId), inline = true },
      { name = 'License', value = player.license, inline = true },
      { name = 'Discord', value = player.discord, inline = true },
      { name = 'Reason', value = Locale.Get(reasonKey or 'no_access'), inline = false },
    },
  })
end

function Logging.MenuOpened(source, visibleEntries)
  if not Logging.EventEnabled('menuOpened') then
    return
  end

  local player = getPlayerContext(source)
  local colors = Config.Logging.colors or {}

  Logging.SendEmbed({
    title = 'Menu Opened',
    description = ('**%s** opened the VIP voucher menu.'):format(player.name),
    color = colors.info or 8060973,
    fields = {
      { name = 'Server ID', value = tostring(player.serverId), inline = true },
      { name = 'License', value = player.license, inline = true },
      { name = 'Discord', value = player.discord, inline = true },
      { name = 'Visible Vouchers', value = tostring(visibleEntries or 0), inline = true },
    },
  })
end

function Logging.Redeem(source, categoryId, entryId, success, reasonKey)
  local eventName = success and 'redeemSuccess' or 'redeemFailed'
  if not Logging.EventEnabled(eventName) then
    return
  end

  local player = getPlayerContext(source)
  local category, entry = Utils.FindVoucherEntry(categoryId, entryId)
  local colors = Config.Logging.colors or {}
  local actionLabel = entry and entry.action or 'unknown'
  local voucherLabel = entry and entry.label or entryId
  local categoryLabel = category and category.label or categoryId

  Logging.SendEmbed({
    title = success and 'Voucher Redeemed' or 'Redeem Failed',
    description = success
      and ('**%s** redeemed **%s**.'):format(player.name, voucherLabel)
      or ('**%s** failed to redeem **%s**.'):format(player.name, voucherLabel),
    color = success and (colors.success or 5763719) or (colors.failure or 15548997),
    fields = {
      { name = 'Server ID', value = tostring(player.serverId), inline = true },
      { name = 'License', value = player.license, inline = true },
      { name = 'Discord', value = player.discord, inline = true },
      { name = 'Category', value = categoryLabel, inline = true },
      { name = 'Voucher', value = voucherLabel, inline = true },
      { name = 'Action', value = actionLabel, inline = true },
      {
        name = 'Result',
        value = success and 'Success' or Locale.Get(reasonKey or 'redeem_failed'),
        inline = false,
      },
    },
  })
end

function Logging.PurchaseLinkOpened(source, url, roleKey, providerId)
  if not Logging.EventEnabled('purchaseLinkOpened') then
    return
  end

  local player = getPlayerContext(source)
  local colors = Config.Logging.colors or {}
  local definition = roleKey and Utils.GetRoleDefinition(roleKey) or nil
  local payments = Config.Payments or {}
  local providerLabel = providerId and payments[providerId] and payments[providerId].label or providerId or 'Unknown'

  Logging.SendEmbed({
    title = 'Purchase Link Opened',
    description = ('**%s** opened a store purchase link.'):format(player.name),
    color = colors.info or 8060973,
    fields = {
      { name = 'Server ID', value = tostring(player.serverId), inline = true },
      { name = 'License', value = player.license, inline = true },
      { name = 'Discord', value = player.discord, inline = true },
      { name = 'Product', value = definition and definition.label or (roleKey or 'Unknown'), inline = true },
      { name = 'Provider', value = providerLabel, inline = true },
      { name = 'URL', value = url or 'unknown', inline = false },
    },
  })
end
