local cons = {}
local g = getgenv()

if g._connections then
	for i, v in next, g._connections do
		v:Disconnect()
	end
else
	g._connections = {}
end

function cons.new(connection: RBXScriptConnection)
	table.insert(g._connections, connection)
end

return cons
