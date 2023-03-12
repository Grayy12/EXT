local cons = {}
cons.__index = cons

local g = getgenv()

if g._connections then
	for i, v in next, g._connections do
		if v.Connected then
			v:Disconnect()
		end
		v = nil
	end
else
	g._connections = {}
end

function cons.new(signal: RBXScriptSignal, func)
	local self = setmetatable({}, cons)
	self.func = typeof(func) == "function" and func or function() end
	self.signal = signal
	self.conection = signal:Connect(self.func)

	table.insert(g._connections, self.conection)

	function self:disable()
		self.conection:Disconnect()
	end

	function self:enable()
		if self.conection.Connected then
			return
		end

		table.remove(g._connections, table.find(g._connections, self.conection))
		self.conection = self.signal:Connect(self.func)
		table.insert(g._connections, self.conection)
	end

	function self:delete()
		self.conection:Disconnect()

		table.remove(g._connections, table.find(g._connections, self.conection))
	end

	return self
end

return cons
