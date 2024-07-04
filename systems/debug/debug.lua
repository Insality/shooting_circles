local ecs = require("decore.ecs")
local log = require("log.log")

local logger = log.get_logger("system.debug")

local system_debug_command = require("systems.debug.debug_command")

---@class entity
---@field debug component.debug|nil

---@class entity.debug: entity
---@field debug component.debug

---@class component.debug
---@field is_profiler_active boolean

---@class system.debug: system
---@field entities entity.debug[]
local M = {}


---@static
---@return system.debug, system.debug_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("debug")
	system.id = "debug"

	return system, system_debug_command.create_system(system)
end


---@param entity entity.debug
function M:toggle_profiler(entity)
	local d = entity.debug
	d.is_profiler_active = not d.is_profiler_active
	profiler.enable_ui(d.is_profiler_active)

	logger:info("Profiler is active: " .. tostring(d.is_profiler_active))
end


return M
