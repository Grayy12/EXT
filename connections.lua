local g = (getgenv and getgenv()) or _G

g._connections = g._connections or {}
g._hooks = g._hooks or {}

local ConnectionHandler = {}

function ConnectionHandler.new(Id)
    local cons = setmetatable({}, ConnectionHandler)

    if g._connections[Id] then
        for _, v in next, g._connections[Id] do
            if v.Connected then
                v:Disconnect()
            end
        end

		for _, v in next, g._hooks[Id] do
			if v and v.Delete then
				v:Delete()
			end
		end
    end

    g._connections[Id] = {}
    g._hooks[Id] = {}

    function cons:GetAllConnections()
        return g._connections[Id]
    end

	function cons:GetAllHooks()
		return g._hooks[Id]
	end

    function cons:DeleteAll()
        for i = #g._connections[Id], 1, -1 do
            local v = g._connections[Id][i]
            if v and v.Connected then
                v:Disconnect()
            end
            table.remove(g._connections[Id], i)
        end

        for i = #g._hooks[Id], 1, -1 do
            local v = g._hooks[Id][i]
            if v and v.Delete then
                v:Delete()
            end
            table.remove(g._hooks[Id], i)
        end
    end

    function cons:NewConnection(signal: RBXScriptSignal, func)
        local connection = signal:Connect(func)
        table.insert(g._connections[Id], connection)

        return setmetatable({
            connection = connection,
            signal = signal,
            func = func,
            Cons = cons,
            Id = Id,
        }, {
            __call = function(self, ...)
                return self.func(...)
            end,

            __index = {
                Disable = function(self)
                    if self.connection and self.connection.Connected then
                        self.connection:Disconnect()
                    end
                    return self
                end,

                Enable = function(self)
                    if not self.connection or not self.connection.Connected then
                        if self.connection then
                            local list = g._connections[self.Id]
                            local idx = list
                                and table.find(list, self.connection)
                            if idx then
                                table.remove(list, idx)
                            end
                        end
                        self.connection = self.signal:Connect(self.func)
                        local list = g._connections[self.Id]
                        if list then
                            table.insert(list, self.connection)
                        end
                    end

                    return self
                end,

                Delete = function(self)
                    if self.connection then
                        if self.connection.Connected then
                            self.connection:Disconnect()
                        end
                        local list = g._connections[self.Id]
                        local idx = list and table.find(list, self.connection)
                        if idx then
                            table.remove(list, idx)
                        end
                        self.connection = nil
                    end
                    self.signal = nil
                    self.func = nil
                end,
            },
        })
    end

    function cons:NewHook(targetObject: string | () -> (), callback)
        local isMeta = type(targetObject) == 'string'

        if isMeta then
            assert(targetObject == '__namecall' or targetObject == '__index' or targetObject == '__newindex',
                "Invalid metamethod name. Must be '__namecall', '__index', or '__newindex'.")
        else
            assert(type(targetObject) == 'function', "targetObject must be a function or a metamethod name string.")
        end


        local hook = {}
        hook._enabled = true
        hook._original = nil
        hook._callback = nil

        local function wrapper(...)
            if hook._enabled then
                return hook._callback(hook._original, ...)
            end
            return hook._original(...)
        end

        hook._original = if isMeta
            then hookmetamethod(game, targetObject, wrapper)
            else hookfunction(targetObject, newcclosure(wrapper))
        hook._callback = callback

        hook = setmetatable(hook, {
            __index = {
                Disable = function(self)
                    self._enabled = false
                    return self
                end,

                Enable = function(self)
                    self._enabled = true
                    return self
                end,

                Delete = function(self)
                    if self._original then
                        if not isMeta then
                            if getgenv().restorefunction then
                                pcall(restorefunction, targetObject)
                            else
                                hookfunction(targetObject, self._original)
                            end
                        else
                            hookmetamethod(game, targetObject, self._original)
                        end
                    end
                end,
            },
        })

        table.insert(g._hooks[Id], hook)
        return hook
    end

    return cons
end

return ConnectionHandler
