local g = (getgenv and getgenv()) or _G

g._connections = g._connections or {}

local ConnectionHandler = {}

function ConnectionHandler.new(Id)
	local cons = setmetatable({}, ConnectionHandler)

	if g._connections[Id] then
		for _, v in next, g._connections[Id] do
			if v.Connected then
				v:Disconnect()
			end
		end
	end

	g._connections[Id] = {}

	function cons:GetAllConnections()
		return g._connections[Id]
	end

	function cons:DeleteAll()
		for i = #g._connections[Id], 1, -1 do
			local v = g._connections[Id][i]
			if v.Connected then
				v:Disconnect()
				table.remove(g._connections[Id], i)
			end
		end
	end

	function cons:NewConnection(signal: RBXScriptSignal, func)
		local connection = signal:Connect(func)
		table.insert(g._connections[Id], connection)

		return setmetatable({
			connection = connection,
			Cons = cons,
			Id = Id,
		}, {
			__call = function(self)
				func()
			end,

			__index = {
				Disable = function(self)
					self.connection:Disconnect()
					return self
				end,

				Enable = function(self)
					if not self.connection.Connected then
						table.remove(g._connections[self.Id], table.find(g._connections[self.Id], self.connection))
						self.connection = self.signal:Connect(self.signal, self.func)
						table.insert(g._connections[self.Id], self.connection)
					end

					return self
				end,

				Delete = function(self)
					if self.connection then
						self.connection:Disconnect()
						table.remove(g._connections[self.Id], table.find(g._connections[self.Id], self.connection))
						self.connection = nil
					end
				end,
			},
		})
	end

	return cons
end

return ConnectionHandler
