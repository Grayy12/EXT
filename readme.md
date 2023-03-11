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
```lua
local cons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/connections.lua", true))()

cons.new(<RBXScriptConnection>) -- adds a new connection to help with memory leaks
```
