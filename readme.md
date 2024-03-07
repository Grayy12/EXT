# Player
 
```lua
local Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/Player.lua", true))()

Player.char() -- character
Player.plr  -- Player
Player.root() -- HumanoidRootPart
Player.hum() -- Humanoid
local respawnFunc = Player.respawn(<function>) -- runs inputed function when character respawned
respawnFunc:delete() -- Stops the function passed to the respawn
```

# Connections
### Example
```lua
-- Load the ConnectionHandler module from a remote source
local ConnectionHandlerModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/connections.lua", true))()

-- Create a new instance of the ConnectionHandler with a unique identifier
-- Ensure the identifier is unique per script if you only want to handle connections for this specific script
local connectionManager = ConnectionHandlerModule.new('UniqueIdentifier')

-- Create a new connection to the RunService.Heartbeat event
-- The provided function will be called on every heartbeat
local heartbeatConnection = connectionManager:NewConnection(game:GetService("RunService").Heartbeat, function()
    print("Hello")
end)

-- Disable the heartbeat connection
print("Disabled")
heartbeatConnection:Disable()


-- Re-enable the heartbeat connection
print("Enabled")
heartbeatConnection:Enable()

-- Delete the heartbeat connection
print("Deleted")
heartbeatConnection:Delete()
```
