fx_version 'cerulean'
game 'gta5'

name 'vip_vouchers'
author 'Custom'
description 'Standalone Discord-role gated VIP voucher menu with Squaresite/PayPal store links'
version '1.3.1'

lua54 'yes'

ui_page 'web/index.html'

shared_scripts {
  'config.lua',
  'shared/*.lua',
}

server_scripts {
  'server/bridges/detect.lua',
  'server/bridges/framework.lua',
  'server/bridges/inventory.lua',
  'server/discord.lua',
  'server/logging.lua',
  'server/access.lua',
  'server/redeem.lua',
  'server/main.lua',
}

client_scripts {
  'client/actions.lua',
  'client/bridges/target.lua',
  'client/main.lua',
}

files {
  'web/index.html',
  'web/styles.css',
  'web/app.js',
  'web/assets/*',
}
