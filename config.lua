Config = {}

-- Server Slot Limit
Config.Slots = 64

-- Whitelist Settings
Config.WhitelistEnabled = false
Config.Whitelist = {
    -- ["license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"] = true,
}

-- Priority Settings (Higher number = Higher priority)
-- Default priority is 0
Config.Priority = {
    -- ["license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"] = 10, -- Admin/VIP
}

-- Grace Period in seconds (allows players who crashed/disconnected to skip the queue)
Config.GracePeriod = 300 -- 5 minutes

-- Update interval in milliseconds (how often to update the queue message for waiting players)
Config.UpdateInterval = 5000

-- Language / Messages
Config.Messages = {
    whitelist_only = "This server is currently whitelist only.",
    server_full = "Server is full. You are in the queue.",
    queue_pos = "\nPosition: %d / %d\nPriority: %d\n\n[DA Scripts - Connect Queue]",
    grace_period = "Reconnecting... Welcome back!",
    connecting = "Connecting to the server...",
    error_id = "Error: Could not find your identifiers. Please restart Steam/FiveM."
}
