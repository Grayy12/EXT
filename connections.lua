local g = (getgenv and getgenv()) or _G

g._connections = g._connections or {}
g._hooks = g._hooks or {}
g._cooldowns = g._cooldowns or {}

local ConnectionObj = {}
ConnectionObj.__index = ConnectionObj

function ConnectionObj:Disable()
	if self.connection and self.connection.Connected then
		self.connection:Disconnect()
	end
	return self
end

function ConnectionObj:Enable()
	if self._destroyed then
		return self
	end

	if not self.connection or not self.connection.Connected then
		if self.connection then
			g._connections[self.Id][self.uId] = nil
		end

		self.connection = self.signal:Connect(self.func)
		g._connections[self.Id][self.uId] = self.connection
	end
	return self
end

function ConnectionObj:Delete()
	self._destroyed = true
	if self.connection then
		if self.connection.Connected then
			self.connection:Disconnect()
		end
		g._connections[self.Id][self.uId] = nil
		self.connection = nil
	end
	self.signal = nil
	self.func = nil
end

ConnectionObj.__call = function(self, ...)
	if self.func and not self._destroyed then
		return self.func(...)
	end

	return
end

local ConnectionHandler = {}
ConnectionHandler.__index = ConnectionHandler

function ConnectionHandler.new(Id)
	local self = setmetatable({}, ConnectionHandler)
	self.Id = Id
	self.counter = 0

	if g._connections[Id] then
		for _, con in g._connections[Id] do
			if con.Connected then
				con:Disconnect()
			end
		end
	end

	if g._hooks[Id] then
		for _, hook in g._hooks[Id] do
			if hook and hook.Delete then
				hook:Delete()
			end
		end
	end
	g._connections[Id] = {}
	g._hooks[Id] = {}
	g._cooldowns[Id] = {}

	self.connections = g._connections[Id]
	self.hooks = g._hooks[Id]
	self.cooldowns = g._cooldowns[Id]

	return self
end

function ConnectionHandler:GetAllConnections()
	return self.connections
end

function ConnectionHandler:GetAllHooks()
	return self.hooks
end

function ConnectionHandler:GetAllCooldowns()
	return self.cooldowns
end

function ConnectionHandler:DeleteAll()
	for conId, con in self.connections do
		if con.Connected then
			con:Disconnect()
		end
		self.connections[conId] = nil
	end

	for hookId, hook in self.hooks do
		if hook and hook.Delete then
			hook:Delete()
		end
	end

	g._cooldowns[self.Id] = {}
	self.cooldowns = g._cooldowns[self.Id]
end

function ConnectionHandler:NewConnection(signal: RBXScriptSignal, func)
	assert(
		typeof(signal) == "RBXScriptSignal" or (type(signal) == "table" and signal.Connect),
		"Argument 1 must be a RBXScriptSignal"
	)
	assert(type(func) == "function", "Argument 2 must be a function")

	self.counter += 1
	local uId = self.counter
	local connection = signal:Connect(func)

	self.connections[uId] = connection

	local data = {
		connection = connection,
		signal = signal,
		func = func,
		Id = self.Id,
		uId = uId,
		_destroyed = false,
	}

	return setmetatable(data, ConnectionObj)
end

function ConnectionHandler:Once(signal: RBXScriptSignal, func)
	assert(
		typeof(signal) == "RBXScriptSignal" or (type(signal) == "table" and signal.Once),
		"Argument 1 must be a RBXScriptSignal"
	)
	assert(type(func) == "function", "Argument 2 must be a function")

	self.counter += 1
	local uId = self.counter
	local proxy

	local function wrapper(...)
		if proxy then
			proxy:Delete()
		end
		return func(...)
	end

	local connection = signal:Once(wrapper)
	self.connections[uId] = connection

	local data = {
		connection = connection,
		signal = signal,
		func = func,
		Id = self.Id,
		uId = uId,
		_destroyed = false,
	}

	proxy = setmetatable(data, ConnectionObj)

	return proxy
end

function ConnectionHandler:WaitFor(signal: RBXScriptSignal, timeout: number?)
	assert(
		typeof(signal) == "RBXScriptSignal" or (type(signal) == "table" and signal.Connect),
		"Argument 1 must be a RBXScriptSignal"
	)
	assert(timeout == nil or type(timeout) == "number", "Argument 2 must be a number or nil")
	assert(coroutine.isyieldable(), "WaitFor must be called from a yieldable thread")

	timeout = timeout or 10

	local thread = coroutine.running()
	local connection
	local timeoutTask: thread?

	local function resume(isSuccess, ...)
		if connection then
			connection:Delete()
		end
		if timeoutTask then
			task.cancel(timeoutTask)
		end
		task.spawn(thread, isSuccess, ...)
	end

	connection = self:Once(signal, function(...)
		resume(true, ...)
	end)

	timeoutTask = task.delay(timeout, resume, false)

	return coroutine.yield()
end

function ConnectionHandler:Cooldown(title: string, duration: number)
	assert(type(title) == "string", "Argument 1 must be a string")
	assert(type(duration) == "number", "Argument 2 must be a number")

	local cooldown = self.cooldowns[title]

	if not cooldown then
		cooldown = {
			lastTime = -math.huge,
			duration = duration,
		}
		self.cooldowns[title] = cooldown
	else
		cooldown.duration = duration
	end

	local now = tick()
	if now - cooldown.lastTime >= cooldown.duration then
		cooldown.lastTime = now
		return true
	end

	return false
end

function ConnectionHandler:ResetCooldown(title: string)
	local cooldown = self.cooldowns[title]
	if cooldown then
		cooldown.lastTime = -math.huge
	end
	return self
end

function ConnectionHandler:GetCooldownRemaining(title: string)
	local cooldown = self.cooldowns[title]
	if not cooldown then
		return 0
	end

	return math.max(0, cooldown.duration - (tick() - cooldown.lastTime))
end

function ConnectionHandler:NewHook(targetObject: string | () -> (), callback)
	local isMeta = type(targetObject) == "string"

	if isMeta then
		assert(
			targetObject == "__namecall" or targetObject == "__index" or targetObject == "__newindex",
			"Invalid metamethod name. Must be '__namecall', '__index', or '__newindex'."
		)
	else
		assert(type(targetObject) == "function", "targetObject must be a function or a metamethod name string.")
	end

	self.counter += 1
	local hookId = self.counter
	local hook = { _enabled = true, _original = nil, _callback = callback, Id = self.Id }

	local function wrapper(...)
		if hook._enabled then
			return hook._callback(hook._original, ...)
		end
		return hook._original(...)
	end

	hook._original = isMeta and hookmetamethod(game, targetObject, wrapper)
		or hookfunction(targetObject, newcclosure(wrapper))

	local hookMeta = {
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
						if restorefunction then
							local ok, err = pcall(restorefunction, targetObject)
							if not ok then
								warn("[Connection Manager] Failed to restore function:", err)
							end
						else
							hookfunction(targetObject, self._original)
						end
					else
						hookmetamethod(game, targetObject, self._original)
					end
					g._hooks[self.Id][hookId] = nil
					self._original = nil
					self._callback = nil
				end
			end,
		},
	}

	setmetatable(hook, hookMeta)
	g._hooks[self.Id][hookId] = hook
	return hook
end

return ConnectionHandler
