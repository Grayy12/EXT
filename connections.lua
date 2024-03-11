local g = (getgenv and getgenv()) or _G

g._connections = g._connections or {}

local ConnectionHandler = {}

function ConnectionHandler.new(Id)
    
    local cons = setmetatable({}, ConnectionHandler)

    if g._connections[Id] then
        for _, v in ipairs(g._connections[Id]) do
            if v.Connected then
                v:Disconnect()
            end
        end
    end

    g._connections[Id] = {}
    
    function cons:GetAllConnections()
        return g._connections[Id]
    end

    function cons:NewConnection(signal, func)
        local self = setmetatable({}, cons)
        self.func = typeof(func) == 'function' and func or function() end
        self.signal = signal
        self.connection = signal:Connect(self.func)
        table.insert(g._connections[Id], self.connection)

        function self:Disable()
            self.connection:Disconnect()
        end

        function self:Enable()
            if not self.connection.Connected then
                table.remove(g._connections[Id], table.find(g._connections[Id], self.connection))
                self.connection = self.signal:Connect(self.func)
                table.insert(g._connections[Id], self.connection)
            end
        end

        function self:Delete()
            self.connection:Disconnect()
            table.remove(g._connections[Id], table.find(g._connections[Id], self.connection))
        end

        return self
    end
    
    return cons
end

return ConnectionHandler
