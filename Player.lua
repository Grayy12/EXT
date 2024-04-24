local ConnectionHandlerModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/connections.lua", true))()
local connectionManager = ConnectionHandlerModule.new("PlayerModuleGrayy")

local Player
Player = {
	plr = game.Players.LocalPlayer or game.Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and game.Players.LocalPlayer,

	char = function()
		return game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	end,

	root = function()
		return Player.char():WaitForChild("HumanoidRootPart") or Player.char().PrimaryPart
	end,

	hum = function()
		return Player.char():WaitForChild("Humanoid")
	end,

	_rescons = {},

	respawn = function(func)
		local function runFunctions()
			for _, v in pairs(Player._rescons) do
				coroutine.wrap(v)()
			end
		end

		if type(func) ~= "function" then
			runFunctions()
			return
		end

		if not table.find(Player._rescons, func) then
			table.insert(Player._rescons, func)

			return setmetatable({
				idx = #Player._rescons,
				func = func,
			}, {
				__call = function(self)
					self.func()
				end,

				__index = {
					delete = function(self)
						table.remove(Player._rescons, self.idx)
					end,
				},
			})
		end
	end,
}

connectionManager:NewConnection(Player.plr.CharacterAdded, Player.respawn)

return Player
