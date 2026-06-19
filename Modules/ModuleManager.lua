local ModuleManager = {}
ModuleManager.__index = ModuleManager

getgenv().ModuleManager = ModuleManager

local registry = {}

function ModuleManager.new(name, config)
    local self = setmetatable({}, ModuleManager)
    self.name = name
    self.enabled = false
    self.config = config or {}
    self._threads = {}
    self._connections = {}
    self.onStart = config.onStart or function() end
    self.onStop = config.onStop or function() end
    registry[name] = self
    return self
end

function ModuleManager:start()
    if self.enabled then return end
    self.enabled = true
    self.onStart(self)
end

function ModuleManager:stop()
    if not self.enabled then return end
    self.enabled = false
    for _, thread in ipairs(self._threads) do
        task.cancel(thread)
    end
    self._threads = {}
    for _, conn in ipairs(self._connections) do
        conn:Disconnect()
    end
    self._connections = {}
    self.onStop(self)
end

function ModuleManager:toggle()
    if self.enabled then
        self:stop()
    else
        self:start()
    end
end

function ModuleManager:addThread(fn)
    local thread = task.spawn(fn)
    table.insert(self._threads, thread)
    return thread
end

function ModuleManager:addConnection(conn)
    table.insert(self._connections, conn)
    return conn
end

function ModuleManager:set(key, value)
    self.config[key] = value
end

function ModuleManager:get(key)
    return self.config[key]
end

function ModuleManager.get(name)
    return registry[name]
end

return ModuleManager
