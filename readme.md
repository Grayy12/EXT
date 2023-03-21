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
local cons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/connections.lua", true))()

local test = cons.new(game:GetService("RunService").Heartbeat, function()
	print("Hello")
end)

task.wait(2)
print("Disabled")

test:disable() -- turns connection off

task.wait(10)
print("Enabled")

test:enable() -- reenables connection

task.wait(2)
print("Deleted")

test:delete() -- deletes the connection
```
