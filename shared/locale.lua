Locale = Locale or {}

Locale.Strings = {
  en = {
    no_discord = 'You must have Discord linked to use VIP vouchers.',
    no_access = 'You do not have access to VIP vouchers.',
    menu_open_failed = 'Could not open the VIP menu.',
    redeem_success = 'Voucher redeemed successfully.',
    pick_success = 'Your Pick 3 rewards were delivered.',
    redeem_failed = 'Could not redeem this voucher.',
    redeem_cooldown = 'Please wait before redeeming another voucher.',
    redeem_no_access = 'Purchase this tier to unlock this voucher.',
    redeem_invalid = 'Invalid voucher.',
    pick_invalid_count = 'You must select the exact number of required choices.',
    pick_invalid_choice = 'One or more selected choices are invalid.',
    discord_error = 'Discord verification is unavailable. Try again later.',
    not_in_guild = 'You must be in our Discord server to use VIP vouchers.',
    no_inventory = 'No supported inventory system was detected on this server.',
    purchase_opened = 'Opening store in your browser...',
  },
}

function Locale.Get(key)
  local lang = Locale.Strings[Config.Locale] or Locale.Strings.en
  return lang[key] or key
end
