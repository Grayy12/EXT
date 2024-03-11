local ConnectionHandlerModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/main/connections.lua", true))()
local connectionManager = ConnectionHandlerModule.new('PlayerModuleGrayy')

local Player
Player = {
	plr = game.Players.LocalPlayer
		or game.Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and game.Players.LocalPlayer,

	char = function()
		return game.Players.LocalPlayer.Character
			or game.Players.LocalPlayer.CharacterAdded:Wait() and game.Players.LocalPlayer.Character
	end,

	root = function()
		return Player.char():WaitForChild("HumanoidRootPart") or Player.char().PrimaryPart
	end,

	hum = function()
		return Player.char():WaitForChild("Humanoid")
	end,

	_rescons = {},

	respawn = function(func)
		local function callFunctions()
			for _, v in next, Player._rescons do
				local s, n = pcall(function()
					coroutine.wrap(v)()
				end)

				if not s then
					warn(n)
				end
			end
		end
		if typeof(func) ~= "function" then
			callFunctions()
		end

		if func and type(func) == "function" then
			if not table.find(Player._rescons, func) then
				table.insert(Player._rescons, func)
				local res = {}
				res.__index = res
				res.idx = table.find(Player._rescons, func)
				res.func = func
				function res:delete()
					table.remove(Player._rescons, self.idx)
					callFunctions()
				end
				return res
			end
		end
	end,
}

connectionManager:NewConnection(Player.plr.CharacterAdded, Player.respawn)

return Player
