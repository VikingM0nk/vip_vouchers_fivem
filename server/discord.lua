Discord = Discord or {}

local roleCache = {}

local function getDiscordId(source)
  return Identifiers.GetDiscordId(source)
end

local function cacheKey(discordId)
  return ('%s:%s'):format(Config.Discord.guildId, discordId)
end

local function getCachedRoles(discordId)
  local key = cacheKey(discordId)
  local cached = roleCache[key]
  if not cached then
    return nil
  end

  if os.time() - cached.at > (Config.Discord.cacheSeconds or 60) then
    roleCache[key] = nil
    return nil
  end

  return cached.roles, cached.inGuild
end

local function setCache(discordId, roles, inGuild)
  roleCache[cacheKey(discordId)] = {
    at = os.time(),
    roles = roles or {},
    inGuild = inGuild == true,
  }
end

function Discord.GetPlayerRoles(source, callback)
  if not Config.Discord.enabled then
    callback(true, {}, true)
    return
  end

  local discordId = getDiscordId(source)
  if not discordId then
    callback(false, nil, false, 'no_discord')
    return
  end

  local cachedRoles, cachedInGuild = getCachedRoles(discordId)
  if cachedRoles then
    callback(true, cachedRoles, cachedInGuild)
    return
  end

  local url = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(
    Config.Discord.guildId,
    discordId
  )

  PerformHttpRequest(url, function(statusCode, body)
    if statusCode == 200 and body then
      local data = json.decode(body)
      local roles = (data and data.roles) or {}
      setCache(discordId, roles, true)
      callback(true, roles, true)
      return
    end

    if statusCode == 404 then
      setCache(discordId, {}, false)
      callback(true, {}, false)
      return
    end

    Utils.Debug('Discord API error', statusCode, body)
    callback(false, nil, false, 'discord_error')
  end, 'GET', '', {
    ['Authorization'] = 'Bot ' .. Config.Discord.botToken,
    ['Content-Type'] = 'application/json',
  })
end

function Discord.PlayerHasAnyRole(source, roleIds, callback)
  Discord.GetPlayerRoles(source, function(ok, roles, inGuild, reason)
    if not ok then
      callback(false, reason)
      return
    end

    if Config.Discord.requireGuildMember and not inGuild then
      callback(false, 'not_in_guild')
      return
    end

    callback(Utils.TableContainsAny(roleIds, roles or {}))
  end)
end

function Discord.ClearCache(source)
  local discordId = getDiscordId(source)
  if discordId then
    roleCache[cacheKey(discordId)] = nil
  end
end
