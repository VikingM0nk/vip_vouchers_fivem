Config = Config or {}

Config.Locale = 'en'

Config.Access = {
  command = 'vip',
  -- When true, anyone can open the menu to browse and purchase via store links.
  -- Redeeming still requires the matching Discord role after staff grants it post-purchase.
  allowStoreWithoutRole = true,
  keybind = {
    enabled = true,
    name = 'vip',
    description = 'Open VIP Vouchers',
    defaultKey = 'F7',
  },
}

-- External payment providers shown in the Store tab and on locked vouchers.
Config.Payments = {
  squaresite = {
    enabled = true,
    label = 'Squaresite',
  },
  paypal = {
    enabled = true,
    label = 'PayPal',
  },
}

-- Payment URLs: keep each link on ONE line and wrap in quotes.
-- Wrong: paypal = 'https://example.com/link,
-- Right:  paypal = 'https://example.com/link',
Config.PayPalPlans = {
  VIP1 = 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-8P242197F8601225YNIS4XMI',
  VIP2 = 'https://www.paypal.com/paypalme/yourstore/19.99',
  VIP3 = 'https://www.paypal.com/paypalme/yourstore/29.99',
  OrgTier1 = 'https://www.paypal.com/paypalme/yourstore/14.99',
  OrgTier2 = 'https://www.paypal.com/paypalme/yourstore/24.99',
  OrgTier3 = 'https://www.paypal.com/paypalme/yourstore/34.99',
  OrgTier4 = 'https://www.paypal.com/paypalme/yourstore/44.99',
  OrgTier5 = 'https://www.paypal.com/paypalme/yourstore/54.99',
  ExtraOrgItems = 'https://www.paypal.com/paypalme/yourstore/9.99',
  CustomBusiness = 'https://www.paypal.com/paypalme/yourstore/49.99',
  WLMelee = 'https://www.paypal.com/paypalme/yourstore/7.99',
  WLGuns = 'https://www.paypal.com/paypalme/yourstore/12.99',
  Pick3 = 'https://www.paypal.com/paypalme/yourstore/15.99',
}

Config.SquaresiteLinks = {
  VIP1 = 'https://yourstore.square.site/product/vip-tier-1',
  VIP2 = 'https://yourstore.square.site/product/vip-tier-2',
  VIP3 = 'https://yourstore.square.site/product/vip-tier-3',
  OrgTier1 = 'https://yourstore.square.site/product/org-tier-1',
  OrgTier2 = 'https://yourstore.square.site/product/org-tier-2',
  OrgTier3 = 'https://yourstore.square.site/product/org-tier-3',
  OrgTier4 = 'https://yourstore.square.site/product/org-tier-4',
  OrgTier5 = 'https://yourstore.square.site/product/org-tier-5',
  ExtraOrgItems = 'https://yourstore.square.site/product/extra-org-items',
  CustomBusiness = 'https://yourstore.square.site/product/custom-business',
  WLMelee = 'https://yourstore.square.site/product/wl-melee',
  WLGuns = 'https://yourstore.square.site/product/wl-guns',
  Pick3 = 'https://yourstore.square.site/product/pick-3',
}

-- Named Discord role tiers. Reference keys in voucher entries via rolesAny = { 'VIP1' }.
-- After purchase on Squaresite or PayPal, staff/bot grants the Discord role for in-game redemption.
Config.DiscordRoles = {
  VIP1 = {
    label = 'VIP Tier 1',
    roleId = 'PUT_VIP1_ROLE_ID_HERE',
    badge = 'VIP I',
    color = '#F7D774',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.VIP1,
      paypal = Config.PayPalPlans.VIP1,
    },
  },
  VIP2 = {
    label = 'VIP Tier 2',
    roleId = 'PUT_VIP2_ROLE_ID_HERE',
    badge = 'VIP II',
    color = '#EAB308',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.VIP2,
      paypal = Config.PayPalPlans.VIP2,
    },
  },
  VIP3 = {
    label = 'VIP Tier 3',
    roleId = 'PUT_VIP3_ROLE_ID_HERE',
    badge = 'VIP III',
    color = '#CA8A04',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.VIP3,
      paypal = Config.PayPalPlans.VIP3,
    },
  },
  OrgTier1 = {
    label = 'Org Tier 1',
    roleId = 'PUT_ORG_TIER_1_ROLE_ID_HERE',
    badge = 'Org I',
    color = '#A78BFA',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.OrgTier1,
      paypal = Config.PayPalPlans.OrgTier1,
    },
  },
  OrgTier2 = {
    label = 'Org Tier 2',
    roleId = 'PUT_ORG_TIER_2_ROLE_ID_HERE',
    badge = 'Org II',
    color = '#8B5CF6',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.OrgTier2,
      paypal = Config.PayPalPlans.OrgTier2,
    },
  },
  OrgTier3 = {
    label = 'Org Tier 3',
    roleId = 'PUT_ORG_TIER_3_ROLE_ID_HERE',
    badge = 'Org III',
    color = '#7C3AED',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.OrgTier3,
      paypal = Config.PayPalPlans.OrgTier3,
    },
  },
  OrgTier4 = {
    label = 'Org Tier 4',
    roleId = 'PUT_ORG_TIER_4_ROLE_ID_HERE',
    badge = 'Org IV',
    color = '#6D28D9',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.OrgTier4,
      paypal = Config.PayPalPlans.OrgTier4,
    },
  },
  OrgTier5 = {
    label = 'Org Tier 5',
    roleId = 'PUT_ORG_TIER_5_ROLE_ID_HERE',
    badge = 'Org V',
    color = '#5B21B6',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.OrgTier5,
      paypal = Config.PayPalPlans.OrgTier5,
    },
  },
  ExtraOrgItems = {
    label = 'Extra Org Items',
    roleId = 'PUT_EXTRA_ORG_ITEMS_ROLE_ID_HERE',
    badge = 'Org+',
    color = '#C084FC',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.ExtraOrgItems,
      paypal = Config.PayPalPlans.ExtraOrgItems,
    },
  },
  CustomBusiness = {
    label = 'Custom Business',
    roleId = 'PUT_CUSTOM_BUSINESS_ROLE_ID_HERE',
    badge = 'Business',
    color = '#FBBF24',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.CustomBusiness,
      paypal = Config.PayPalPlans.CustomBusiness,
    },
  },
  WLMelee = {
    label = 'WL Melee',
    roleId = 'PUT_WL_MELEE_ROLE_ID_HERE',
    badge = 'Melee',
    color = '#F472B6',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.WLMelee,
      paypal = Config.PayPalPlans.WLMelee,
    },
  },
  WLGuns = {
    label = 'WL Guns',
    roleId = 'PUT_WL_GUNS_ROLE_ID_HERE',
    badge = 'Guns',
    color = '#FB7185',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.WLGuns,
      paypal = Config.PayPalPlans.WLGuns,
    },
  },
  Pick3 = {
    label = 'Pick 3',
    roleId = 'PUT_PICK_3_ROLE_ID_HERE',
    badge = 'Pick 3',
    color = '#34D399',
    purchaseLinks = {
      squaresite = Config.SquaresiteLinks.Pick3,
      paypal = Config.PayPalPlans.Pick3,
    },
  },
}

Config.Discord = {
  enabled = true,
  botToken = 'PUT_DISCORD_BOT_TOKEN_HERE',
  guildId = 'PUT_GUILD_ID_HERE',
  cacheSeconds = 60,
  requireGuildMember = true,
}

Config.Store = {
  enabled = true,
  showLockedEntries = true,
  showStoreTab = true,
  -- Fallback store home pages when a tier has no direct product link configured.
  squaresiteUrl = 'https://yourstore.square.site',
  paypalUrl = 'https://www.paypal.com/paypalme/yourstore',
  instructions = {
    enabled = true,
    title = 'How to Purchase & Redeem',
    steps = {
      'Select a tier and pay via Squaresite or PayPal.',
      'Save your receipt or payment confirmation.',
      'Open a ticket in our Discord with your receipt, tier name, and in-game name.',
      'Wait for staff to grant your Discord role.',
      'Return here and redeem your vouchers once unlocked.',
    },
    note = 'Make sure Discord is linked to FiveM. Roles are usually granted within 24 hours.',
    discordInvite = 'https://discord.gg/yourserver',
    discordLabel = 'Open Discord',
  },
  products = {
    { roleKey = 'VIP1', description = 'Entry VIP perks — starter vehicles & items.', price = '$9.99' },
    { roleKey = 'VIP2', description = 'Expanded VIP perks — more cars & weapons.', price = '$19.99' },
    { roleKey = 'VIP3', description = 'Top VIP perks — premium selection.', price = '$29.99' },
    { roleKey = 'OrgTier1', description = 'Org starter package — tier 1 unlocks.', price = '$14.99' },
    { roleKey = 'OrgTier2', description = 'Org tier 2 — additional org vouchers.', price = '$24.99' },
    { roleKey = 'OrgTier3', description = 'Org tier 3 — mid-tier org rewards.', price = '$34.99' },
    { roleKey = 'OrgTier4', description = 'Org tier 4 — high-tier org rewards.', price = '$44.99' },
    { roleKey = 'OrgTier5', description = 'Org tier 5 — maximum org package.', price = '$54.99' },
    { roleKey = 'ExtraOrgItems', description = 'Bonus org items & extras.', price = '$9.99' },
    { roleKey = 'CustomBusiness', description = 'Custom business setup & perks.', price = '$49.99' },
    { roleKey = 'WLMelee', description = 'Whitelist melee weapons package.', price = '$7.99' },
    { roleKey = 'WLGuns', description = 'Whitelist firearms package.', price = '$12.99' },
    { roleKey = 'Pick3', description = 'Choose any 3 rewards from the Pick 3 pool.', price = '$15.99' },
  },
}

Config.AutoDetect = {
  framework = true,
  inventory = true,
  target = true,
}

Config.Target = {
  enabled = true,
  locations = {},
  ped = {
    enabled = false,
    model = 'cs_barry',
    coords = vector4(215.0, -810.0, 30.7, 160.0),
    label = 'VIP Vouchers',
    icon = 'fas fa-gift',
  },
}

Config.UI = {
  title = 'VIP Vouchers',
  accentGold = '#F7D774',
  accentPurple = '#7C3AED',
}

Config.Vouchers = {
  {
    id = 'vip_cars',
    label = 'VIP Cars',
    icon = 'car',
    entries = {
      {
        id = 'vip1_adder',
        label = 'Adder',
        description = 'VIP1 exclusive supercar spawn.',
        rolesAny = { 'VIP1' },
        action = 'spawn_vehicle',
        data = { model = 'adder', colors = { primary = 131, secondary = 145 } },
      },
      {
        id = 'vip2_t20',
        label = 'T20',
        description = 'VIP2 exclusive supercar spawn.',
        rolesAny = { 'VIP2' },
        action = 'spawn_vehicle',
        data = { model = 't20', colors = { primary = 131, secondary = 145 } },
      },
      {
        id = 'vip3_entity',
        label = 'Entity XXR',
        description = 'VIP3 exclusive supercar spawn.',
        rolesAny = { 'VIP3' },
        action = 'spawn_vehicle',
        data = { model = 'entity2', colors = { primary = 131, secondary = 145 } },
      },
    },
  },
  {
    id = 'org_rewards',
    label = 'Org Rewards',
    icon = 'org',
    entries = {
      {
        id = 'org_t1_sultan',
        label = 'Org T1 — Sultan RS',
        description = 'Org Tier 1 vehicle voucher.',
        rolesAny = { 'OrgTier1' },
        action = 'spawn_vehicle',
        data = { model = 'sultanrs' },
      },
      {
        id = 'org_t3_insurgent',
        label = 'Org T3 — Insurgent',
        description = 'Org Tier 3 armored vehicle.',
        rolesAny = { 'OrgTier3' },
        action = 'spawn_vehicle',
        data = { model = 'insurgent' },
      },
      {
        id = 'org_t5_phantom',
        label = 'Org T5 — Phantom Custom',
        description = 'Org Tier 5 heavy hauler.',
        rolesAny = { 'OrgTier5' },
        action = 'spawn_vehicle',
        data = { model = 'phantom3' },
      },
      {
        id = 'org_extra_armor',
        label = 'Extra Org — Body Armor x3',
        description = 'Bonus org item pack.',
        rolesAny = { 'ExtraOrgItems' },
        action = 'give_item',
        data = { item = 'armor', count = 3 },
      },
    },
  },
  {
    id = 'business',
    label = 'Business',
    icon = 'biz',
    entries = {
      {
        id = 'custom_biz_supplies',
        label = 'Business Supply Crate',
        description = 'Custom business starter supplies.',
        rolesAny = { 'CustomBusiness' },
        action = 'give_item',
        data = { item = 'water', count = 10 },
      },
    },
  },
  {
    id = 'weapons',
    label = 'Weapons',
    icon = 'gun',
    entries = {
      {
        id = 'wl_melee_bat',
        label = 'WL Melee — Bat',
        description = 'Whitelisted melee weapon.',
        rolesAny = { 'WLMelee' },
        action = 'give_weapon',
        data = { weapon = 'WEAPON_BAT', ammo = 1 },
      },
      {
        id = 'wl_guns_pistol',
        label = 'WL Guns — Pistol',
        description = 'Whitelisted firearm + ammo.',
        rolesAny = { 'WLGuns' },
        action = 'give_weapon',
        data = { weapon = 'WEAPON_PISTOL', ammo = 120 },
      },
      {
        id = 'vip2_smg',
        label = 'VIP2 — SMG',
        description = 'VIP2 weapon voucher.',
        rolesAny = { 'VIP2' },
        action = 'give_weapon',
        data = { weapon = 'WEAPON_SMG', ammo = 200 },
      },
    },
  },
  {
    id = 'pick3',
    label = 'Pick 3',
    icon = 'p3',
    entries = {
      {
        id = 'pick3_bundle',
        label = 'Pick Any 3 Rewards',
        description = 'Select exactly 3 items from the pool below.',
        rolesAny = { 'Pick3' },
        action = 'pick_multiple',
        data = {
          pickCount = 3,
          choices = {
            { id = 'pick_sultan', label = 'Sultan RS', action = 'spawn_vehicle', data = { model = 'sultanrs' } },
            { id = 'pick_bati', label = 'Bati 801', action = 'spawn_vehicle', data = { model = 'bati' } },
            { id = 'pick_pistol', label = 'Pistol + Ammo', action = 'give_weapon', data = { weapon = 'WEAPON_PISTOL', ammo = 100 } },
            { id = 'pick_knife', label = 'Knife', action = 'give_weapon', data = { weapon = 'WEAPON_KNIFE', ammo = 1 } },
            { id = 'pick_bandage', label = 'Bandages x10', action = 'give_item', data = { item = 'bandage', count = 10 } },
            { id = 'pick_water', label = 'Water x5', action = 'give_item', data = { item = 'water', count = 5 } },
          },
        },
      },
    },
  },
}

Config.Limits = {
  redeemCooldownSeconds = 10,
}

Config.Logging = {
  enabled = true,
  discord = {
    webhookUrl = 'PUT_DISCORD_WEBHOOK_URL_HERE',
    botName = 'VIP Vouchers',
    avatarUrl = '',
  },
  events = {
    redeemSuccess = true,
    redeemFailed = true,
    accessDenied = true,
    menuOpened = false,
    purchaseLinkOpened = true,
  },
  colors = {
    success = 5763719,
    failure = 15548997,
    warning = 16766720,
    info = 8060973,
  },
}
