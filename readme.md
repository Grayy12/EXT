# EXT Library

A centralized manager for RBXScriptSignals and function hooks with built-in cleanup, toggle functionality, and unique identification.

## Features

- **Centralized Management:** Group connections, hooks, and cooldowns by unique ID with persistent state across script reloads
- **Connection Lifecycle Control:** Enable, disable, or delete connections without recreating them
- **Zero-Overhead Cooldowns:** Timestamp-based rate limiting with no task scheduling or thread creation
- **Advanced Hooks:** Support for both function hooks and metamethod hooks (`__namecall`, `__index`, `__newindex`)
- **Async Utilities:** Built-in `WaitFor` with configurable timeouts and `Once` for one-time event handlers
- **Auto-Cleanup:** Delete all connections, hooks, and cooldowns with a single method call
- **Dynamic Configuration:** Update cooldown durations on-the-fly without recreating cooldown objects

## Usage

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
-- Updates duration if changed between calls
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
