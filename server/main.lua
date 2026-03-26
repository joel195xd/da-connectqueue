local Queue = {}
local GracePlayers = {}
local ConnectingCount = 0
local JoinTimes = {}

-- Dynamic Slot Management
local CurrentSlots = Config.DynamicSlots.default

-- Helper functions for identifiers
local function GetIdentifiers(source)
    local ids = {
        license = nil,
        discord = nil,
        steam = nil,
        ip = nil
    }
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "license:") then ids.license = id
        elseif string.find(id, "discord:") then ids.discord = string.sub(id, 9)
        elseif string.find(id, "steam:") then ids.steam = id
        elseif string.find(id, "ip:") then ids.ip = id
        end
    end
    return ids
end

-- Discord Role Check
local function GetDiscordPriority(discordId)
    if not Config.Discord.enabled or not discordId then return 0 end
    local p = promise.new()
    PerformHttpRequest("https://discord.com/api/v10/guilds/" .. Config.Discord.guildId .. "/members/" .. discordId, function(status, body, headers)
        if status == 200 then
            local data = json.decode(body)
            local maxPriority = 0
            for _, roleId in ipairs(data.roles) do
                if Config.Discord.roles[roleId] and Config.Discord.roles[roleId] > maxPriority then
                    maxPriority = Config.Discord.roles[roleId]
                end
            end
            p:resolve(maxPriority)
        else
            p:resolve(0)
        end
    end, "GET", "", {["Authorization"] = "Bot " .. Config.Discord.token})
    return Citizen.Await(p)
end

-- Discord Webhook Logging
local function SendDiscordLog(title, message, color)
    if not Config.Discord.enabled or Config.Discord.webhook == "YOUR_WEBHOOK_URL" then return end
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color or 3447003,
            ["footer"] = { ["text"] = "DA Scripts - Connect Queue" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    PerformHttpRequest(Config.Discord.webhook, function(err, text, headers) end, 'POST', 
        json.encode({username = "DA Connect Queue", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Estimated Wait Time Calculation
local function GetEstimatedWait(pos)
    if #JoinTimes < 2 then return "Calculating..." end
    local diffSum = 0
    for i = 2, #JoinTimes do
        diffSum = diffSum + (JoinTimes[i] - JoinTimes[i-1])
    end
    local avg = diffSum / (#JoinTimes - 1)
    local totalSecs = math.floor(avg * pos)
    
    if totalSecs < 60 then return "< 1 min"
    else return math.ceil(totalSecs / 60) .. " min" end
end

-- Priority Sorting
local function SortQueue()
    table.sort(Queue, function(a, b)
        if a.priority ~= b.priority then
            return a.priority > b.priority
        end
        return a.time < b.time
    end)
end

-- Main Connection Handler
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local _source = source
    local ids = GetIdentifiers(_source)
    
    deferrals.defer()
    Wait(100)
    
    if not ids.license then
        deferrals.done(Config.Messages.error_id)
        return
    end

    -- Whitelist Check
    if Config.WhitelistEnabled and not Config.Whitelist[ids.license] then
        deferrals.done(Config.Messages.whitelist_only)
        return
    end

    local discordPriority = GetDiscordPriority(ids.discord)
    local configPriority = Config.Priority[ids.license] or 0
    local finalPriority = math.max(discordPriority, configPriority)

    -- Grace Period Check
    if GracePlayers[ids.license] then
        local timeNow = os.time()
        if timeNow - GracePlayers[ids.license] < Config.GracePeriod then
            deferrals.update(Config.Messages.grace_period)
            Wait(1000)
            GracePlayers[ids.license] = nil
            ConnectingCount = ConnectingCount + 1
            deferrals.done()
            return
        end
    end

    -- Queue Logic
    local playerNode = {
        source = _source,
        license = ids.license,
        name = playerName,
        priority = finalPriority,
        time = os.time(),
        deferrals = deferrals
    }
    
    table.insert(Queue, playerNode)
    SortQueue()
    SendDiscordLog("Queue Entry", playerName .. " (" .. ids.license .. ") joined the queue. Priority: " .. finalPriority, 16776960)

    local inQueue = true
    while inQueue do
        local pos = 0
        for i, node in ipairs(Queue) do
            if node.license == ids.license then
                pos = i
                break
            end
        end

        local currentCount = GetNumPlayerIndices() + ConnectingCount
        local availableSlots = CurrentSlots
        
        -- Reserved slots check
        if finalPriority == 0 and currentCount >= (CurrentSlots - Config.ReservedSlots) then
            availableSlots = CurrentSlots - Config.ReservedSlots
        end

        if pos == 1 and currentCount < availableSlots then
            inQueue = false
            ConnectingCount = ConnectingCount + 1
            for i, node in ipairs(Queue) do
                if node.license == ids.license then
                    table.remove(Queue, i)
                    break
                end
            end
            SendDiscordLog("Connecting", playerName .. " is connecting to the server.", 65280)
            deferrals.done()
        else
            local waitTime = GetEstimatedWait(pos)
            deferrals.update(string.format(Config.Messages.queue_pos, pos, #Queue, finalPriority, waitTime))
            Wait(Config.UpdateInterval)
            
            -- Check if source still exists (simple check)
            if GetPlayerName(_source) == nil and pos > 0 then
                -- Player likely cancelled
                for i, node in ipairs(Queue) do
                    if node.license == ids.license then
                        table.remove(Queue, i)
                        break
                    end
                end
                inQueue = false
            end
        end
    end
end)

-- Track join times for ETA
AddEventHandler('playerJoining', function()
    table.insert(JoinTimes, os.time())
    if #JoinTimes > 10 then table.remove(JoinTimes, 1) end
    if ConnectingCount > 0 then ConnectingCount = ConnectingCount - 1 end
end)

-- Grace period on drop
AddEventHandler('playerDropped', function(reason)
    local ids = GetIdentifiers(source)
    if ids.license then
        GracePlayers[ids.license] = os.time()
    end
end)

-- [[ ADMIN COMMANDS ]]

RegisterCommand('c-reload', function(source, args)
    if source ~= 0 then -- Check perms (assuming ace perms for simplicity in standalone)
        if not IsPlayerAceAllowed(source, "command.creload") then
            TriggerClientEvent('chat:addMessage', source, { args = { '^1[Queue]', Config.Messages.no_perms } })
            return
        end
    end
    
    local file = LoadResourceFile(GetCurrentResourceName(), "config.lua")
    if file then
        assert(load(file))()
        TriggerClientEvent('chat:addMessage', (source == 0 and -1 or source), { args = { '^2[Queue]', Config.Messages.reload_success } })
    end
end, false)

RegisterCommand('c-info', function(source, args)
    local msg = string.format("^3Queue Info: ^7%d in queue, Dynamic Limit: %d/%d, Connecting: %d", #Queue, CurrentSlots, Config.DynamicSlots.max, ConnectingCount)
    TriggerClientEvent('chat:addMessage', source, { args = { '^2[Queue]', msg } })
end, false)

RegisterCommand('c-whitelist', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, "command.cwhitelist") then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1[Queue]', Config.Messages.no_perms } })
        return
    end

    if args[1] == "add" and args[2] then
        Config.Whitelist[args[2]] = true
        TriggerClientEvent('chat:addMessage', source, { args = { '^2[Queue]', string.format(Config.Messages.whitelist_add, args[2]) } })
    elseif args[1] == "remove" and args[2] then
        Config.Whitelist[args[2]] = nil
        TriggerClientEvent('chat:addMessage', source, { args = { '^2[Queue]', string.format(Config.Messages.whitelist_remove, args[2]) } })
    end
end, false)

-- Dynamic Slot Update via command or timer
RegisterCommand('c-slots', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "command.cslots") then
        local newSlots = tonumber(args[1])
        if newSlots and newSlots <= Config.DynamicSlots.max then
            CurrentSlots = newSlots
            TriggerClientEvent('chat:addMessage', source, { args = { '^2[Queue]', "Slots updated to " .. newSlots } })
        end
    end
end, false)

print('^2[DA Scripts]^7 Advanced Connect Queue Loaded.')
