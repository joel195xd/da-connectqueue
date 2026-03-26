Config = {}

-- [[ SERVER SLOTS ]]
Config.DynamicSlots = {
    enabled = true,
    default = 30,
    max = 64
}

-- [[ RESERVED SLOTS ]]
-- These slots are kept free for priority players if the server is nearly full
Config.ReservedSlots = 4 

-- [[ DISCORD INTEGRATION ]]
-- Set to false if you don't want to use Discord features
Config.Discord = {
    enabled = false, -- Enable this and fill the fields below
    webhook = "YOUR_WEBHOOK_URL",
    token = "YOUR_BOT_TOKEN",
    guildId = "YOUR_GUILD_ID",
    roles = {
        ["1234567890"] = 10, -- Role ID = Priority Level
        ["0987654321"] = 5,
    }
}

-- [[ WHITELIST SETTINGS ]]
Config.WhitelistEnabled = false
Config.Whitelist = {
    -- ["license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"] = true,
}

-- [[ PRIORITY SETTINGS ]]
Config.Priority = {
    -- ["license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"] = 15,
}

-- [[ GRACE PERIOD ]]
-- Seconds to allow reconnecting after a crash
Config.GracePeriod = 300 

-- [[ QUEUE SETTINGS ]]
Config.UpdateInterval = 5000

-- [[ MESSAGES ]]
Config.Messages = {
    whitelist_only = "This server is currently whitelist only.",
    server_full = "Server is full. You are in the queue.",
    queue_pos = "\nPosition: %d / %d\nPriority: %d\nEstimated Wait: %s\n\n[DA Scripts - Connect Queue]",
    grace_period = "Reconnecting... Welcome back!",
    connecting = "Connecting to the server...",
    error_id = "Error: Could not find your identifiers. Please restart Steam/FiveM.",
    no_perms = "You do not have permission to use this command.",
    reload_success = "Queue configuration reloaded successfully.",
    whitelist_add = "Player %s added to whitelist.",
    whitelist_remove = "Player %s removed from whitelist.",
}
