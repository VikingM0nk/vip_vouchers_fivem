Access = Access or {}

local function configuredRolesExist()
  return #Utils.CollectAllRoleIds() > 0
end

function Access.FetchPlayerGates(source, callback)
  local gates = {
    roles = {},
    inGuild = false,
  }

  if not Config.Discord.enabled then
    callback(true, gates)
    return
  end

  Discord.GetPlayerRoles(source, function(ok, roles, inGuild, failReason)
    if not ok then
      callback(false, gates, failReason)
      return
    end

    gates.roles = roles or {}
    gates.inGuild = inGuild == true
    callback(true, gates)
  end)
end

function Access.CanOpenMenu(gates)
  if not Config.Discord.enabled then
    return true
  end

  if Config.Discord.requireGuildMember and gates.inGuild == false then
    return false, 'not_in_guild'
  end

  if configuredRolesExist() then
    local discordOk = Utils.TableContainsAny(Utils.CollectAllRoleIds(), gates.roles or {})
    return discordOk, discordOk and nil or 'no_access'
  end

  return true
end

function Access.EntryAllowed(entry, gates)
  local discordIds = Utils.NormalizeRoleIds(entry.rolesAny)
  local discordRequired = Config.Discord.enabled and #discordIds > 0

  if not discordRequired then
    return true
  end

  return Utils.TableContainsAny(discordIds, gates.roles or {})
end
