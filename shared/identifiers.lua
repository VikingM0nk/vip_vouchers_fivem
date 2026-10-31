Identifiers = Identifiers or {}

function Identifiers.Get(source, idType)
  if not source or source <= 0 then
    return nil
  end

  local preferred = idType or 'license'

  if preferred ~= 'any' then
    local value = GetPlayerIdentifierByType(source, preferred)
    if value then
      return value, preferred
    end
  end

  local fallbacks = { 'license', 'license2', 'fivem', 'discord', 'steam' }
  for i = 1, #fallbacks do
    local kind = fallbacks[i]
    if kind ~= preferred then
      local value = GetPlayerIdentifierByType(source, kind)
      if value then
        return value, kind
      end
    end
  end

  return nil, nil
end

function Identifiers.GetDiscordId(source)
  local value = GetPlayerIdentifierByType(source, 'discord')
  if value then
    return value:gsub('discord:', '')
  end
  return nil
end
