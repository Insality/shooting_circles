local ecs = require("decore.ecs")

---@class entity
---@field debug_command component.debug_command|nil

---@class entity.debug_command: entity
---@field debug_command component.debug_command

---@class component.debug_command
---@field toggle_profiler boolean|nil
---@field restart boolean|nil
---@field reset_game boolean|nil

---@class system.debug_command: system
---@field entities entity.debug_command[]
---@field debug system.debug
local M = {}


---@static
---@param debug system.debug
---@return system.debug_command
function M.create_system(debug)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("debug_command")
	system.id = "debug_command"
	system.debug = debug

	return system
end


---@param entity entity.debug_command
function M:onAdd(entity)
	local command = entity.debug_command
	if command then
		self:process_command(entity, entity.debug_command)
		self.world:removeEntity(entity)
	end
end


---@param entity entity.debug_command
---@param command component.debug_command
function M:process_command(entity, command)
	if command.toggle_profiler then
		for _, e in ipairs(self.debug.entities) do
			self.debug:toggle_profiler(e)
		end
	end

	if command.restart then
		if html5 then
			html5.run('document.location.reload();')
		else
			msg.post("@system:", "reboot")
		end
	end
end


return M
