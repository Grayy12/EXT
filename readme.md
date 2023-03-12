# Player
 
```lua
local Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/Player.lua", true))()

Player.char() -- character
Player.plr  -- Player
Player.root() -- HumanoidRootPart
Player.hum() -- Humanoid
Player.respawn(<function>) -- runs inputed function when character respawned
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

test:disable()

task.wait(10)
print("Enabled")

test:enable()

task.wait(2)
print("Deleted")

test:delete()
```
