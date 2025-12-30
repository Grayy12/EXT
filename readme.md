# EXT Library

A collection of utility modules for Roblox script development, featuring player management and advanced connection/hook handling.

## Modules

- [Player](#player)
- [Connections & Hooks](#connections--hooks)

---

## Player

This module provides streamlined functionality to interact with the local player's character, humanoid, and related properties.

### Usage

```lua
local Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/Player.lua", true))()

-- Access properties
local character = Player.char() -- Get Character
local player = Player.plr       -- Get LocalPlayer
local rootPart = Player.root()  -- Get HumanoidRootPart
local humanoid = Player.hum()   -- Get Humanoid

-- Respawn Event
-- Runs the input function whenever the character respawns
local respawnListener = Player.respawn(function()
    print("Character respawned!")
end)

-- Clean up the listener
respawnListener:delete()
```

---

## Connections & Hooks

A centralized manager for RBXScriptSignals and function hooks with built-in cleanup, toggle functionality, and unique identification.

### Features

- **Centralized Management:** Group connections by ID.
- **Auto-Cleanup:** Easily disconnect all associated signals and hooks.
- **Toggling:** Enable/Disable specific connections or hooks without destroying them.
- **Hook Support:** Supports both function hooks and metamethod hooks.

### Usage

```lua
-- Load the ConnectionHandler module
local ConnectionHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/connections.lua", true))()

-- Initialize with a unique identifier (Required)
local connectionManager = ConnectionHandler.new('MyScriptID')

----------------------------------------------------------------
-- Connections
----------------------------------------------------------------

-- Standard Connection
local heartbeat = connectionManager:NewConnection(game:GetService("RunService").Heartbeat, function()
    print("Heartbeat")
end)

-- One-time Connection (Disconnects after first fire)
connectionManager:Once(game:GetService("RunService").Heartbeat, function()
    print("This prints once")
end)

-- Wait for Signal (Yields until signal fires or timeout)
local success, result = connectionManager:WaitFor(game:GetService("RunService").Heartbeat, 5) -- 5s timeout
if success then
    print("Signal received:", result)
else
    warn("Timeout reached")
end

-- Managing Connections
heartbeat:Disable() -- Temporarily stop listening
heartbeat:Enable()  -- Resume listening
heartbeat:Delete()  -- Permanently disconnect

-- Get all active connections
local allCons = connectionManager:GetAllConnections()

----------------------------------------------------------------
-- Hooks
----------------------------------------------------------------

-- Function Hook
local function targetFunc()
    return 'Original'
end

local hook = connectionManager:NewHook(targetFunc, function(original, ...)
    return "Hooked! " .. original(...)
end)

-- Metamethod Hook
local metaHook = connectionManager:NewHook('__namecall', function(original, ...)
    print("Method called: " .. tostring(getnamecallmethod()))
    return original(...)
end)

-- Managing Hooks
hook:Disable() -- Temporarily restore original
hook:Enable()  -- Re-apply hook
hook:Delete()  -- Permanently restore original

-- Get all active hooks
local allHooks = connectionManager:GetAllHooks()

----------------------------------------------------------------
-- Cooldowns
----------------------------------------------------------------

-- Check if cooldown has expired (returns true if action is allowed)
while true do
	if connectionManager:Cooldown("Fire", 0.25) then -- 0.25s cooldown
		fire()
	end
	task.wait()
end

-- Reset a cooldown immediately
connectionManager:ResetCooldown('Fire')

-- Get remaining cooldown time in seconds
local remaining = connectionManager:GetCooldownRemaining('Fire')
print("Cooldown remaining: " .. remaining .. "s")

-- Get all active cooldowns
local allCooldowns = connectionManager:GetAllCooldowns()

----------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------

-- Disconnect ALL connections and remove ALL hooks created by this manager
connectionManager:DeleteAll()
```
