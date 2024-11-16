local decore = require("decore.decore")
local log = require("log.log")

local system_debug_command = require("system.debug.debug_command")

---@class entity
---@field debug component.debug|nil

---@class entity.debug: entity
---@field debug component.debug

---@class component.debug
---@field is_profiler_active boolean
---@field profiler_mode userdata|nil
---@field timer_memory_record hash|nil
decore.register_component("debug", {
	is_profiler_active = false,
	profiler_mode = nil,
	timer_memory_record = nil,
})

---@class system.debug: system
---@field entities entity.debug[]
local M = {}


---@static
---@return system.debug, system.debug_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAny("debug")
	system.id = "debug"

	return system, system_debug_command.create_system(system)
end


---@param entity entity.debug
function M:toggle_profiler(entity)
	local d = entity.debug

	if not d.profiler_mode then
		d.profiler_mode = profiler.VIEW_MODE_MINIMIZED
		profiler.enable_ui(true)
		profiler.set_ui_view_mode(d.profiler_mode)
	elseif d.profiler_mode == profiler.VIEW_MODE_MINIMIZED then
		d.profiler_mode = profiler.VIEW_MODE_FULL
		profiler.enable_ui(true)
		profiler.set_ui_view_mode(d.profiler_mode)
	else
		profiler.enable_ui(false)
		d.profiler_mode = nil
	end

	log:info("Profiler is active: " .. tostring(d.is_profiler_active))
end


---@param entity entity.debug
function M:toggle_memory_record(entity)
	local d = entity.debug

	if d.timer_memory_record then
		timer.cancel(d.timer_memory_record)
		d.timer_memory_record = nil
		log:info("Memory record stopped")
		collectgarbage("restart")
		collectgarbage("collect")
	else
		collectgarbage("collect")
		collectgarbage("stop")
		local memory = collectgarbage("count")
		d.timer_memory_record = timer.delay(1, true, function()
			local new_memory = collectgarbage("count")
			log:info("Memory: " .. new_memory - memory)
			memory = new_memory
		end)
		log:info("Memory record started")
	end
end


return M
