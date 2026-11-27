fx_version 'cerulean'
game 'gta5'

-- This optional stub syncs artwork into its own packfile from kora_inventory.
kora_inventory_image_stub 'yes'
files {
    'html/images/.gitkeep',
    'html/images/*',
    'html/images/**/*'
}

server_script 'image_sync.lua'
