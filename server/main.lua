local Queue = {}
local GracePlayers = {}
local ConnectingCount = 0

-- Function to get main identifier (license)
local function GetPlayerLicense(source)
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            return v
        end
    end
    return nil
end

-- Function to get priority level
local function GetPriority(license)
    if Config.Priority[license] then
        return Config.Priority[license]
    end
    return 0
end

-- Sort queue based on priority and then join time
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
    local license = GetPlayerLicense(_source)
    
    deferrals.defer()
    Wait(0)
    
    if not license then
        deferrals.done(Config.Messages.error_id)
        return
    end

    -- Whitelist Check
    if Config.WhitelistEnabled and not Config.Whitelist[license] then
        deferrals.done(Config.Messages.whitelist_only)
        return
    end

    -- Grace Period Check
    if GracePlayers[license] then
        local timeNow = os.time()
        if timeNow - GracePlayers[license] < Config.GracePeriod then
            deferrals.update(Config.Messages.grace_period)
            Wait(1000)
            GracePlayers[license] = nil
            ConnectingCount = ConnectingCount + 1
            deferrals.done()
            return
        else
            GracePlayers[license] = nil
        end
    end

    -- Check if can connect immediately
    local currentCount = GetNumPlayerIndices() + ConnectingCount
    if currentCount < Config.Slots and #Queue == 0 then
        ConnectingCount = ConnectingCount + 1
        deferrals.done()
        return
    end

    -- Add to Queue
    local playerNode = {
        source = _source,
        license = license,
        priority = GetPriority(license),
        time = os.time(),
        deferrals = deferrals
    }
    
    table.insert(Queue, playerNode)
    SortQueue()

    -- Queue Loop
    local inQueue = true
    while inQueue do
        local pos = 0
        for i, node in ipairs(Queue) do
            if node.license == license then
                pos = i
                break
            end
        end

        local currentPlayers = GetNumPlayerIndices() + ConnectingCount
        
        -- Try to connect
        if pos == 1 and currentPlayers < Config.Slots then
            inQueue = false
            ConnectingCount = ConnectingCount + 1
            -- Remove from queue
            for i, node in ipairs(Queue) do
                if node.license == license then
                    table.remove(Queue, i)
                    break
                end
            end
            deferrals.done()
        else
            -- Still in queue
            local msg = string.format(Config.Messages.queue_pos, pos, #Queue, playerNode.priority)
            deferrals.update(msg)
            Wait(Config.UpdateInterval)
        end
    end
end)

-- Handle player dropped (Grace Period & Count)
AddEventHandler('playerDropped', function(reason)
    local _source = source
    local license = GetPlayerLicense(_source)
    
    if license then
        GracePlayers[license] = os.time()
    end
end)

-- Reset connecting count when player actually joins
AddEventHandler('playerJoining', function()
    if ConnectingCount > 0 then
        ConnectingCount = ConnectingCount - 1
    end
end)

-- Clean up Queue on script stop/start (if needed, though unlikely for standalone)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('^2[DA Scripts]^7 Connect Queue Loaded.')
end)
