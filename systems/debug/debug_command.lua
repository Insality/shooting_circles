local ecs = require("decore.ecs")

---@class world
---@field debug_command system.debug_command|nil

---@class system.debug_command: system_command
---@field debug system.debug
local M = {}


---@static
---@param debug system.debug
---@return system.debug_command
function M.create_system(debug)
	local system = setmetatable(ecs.system(), { __index = M })
	system.id = "debug_command"
	system.debug = debug

	return system
end


---@private
function M:onAddToWorld()
	self.world.debug_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.debug_command = nil
end


function M:toggle_profiler()
	for _, e in ipairs(self.debug.entities) do
		self.debug:toggle_profiler(e)
	end
end


function M:toggle_memory_record()
	for _, e in ipairs(self.debug.entities) do
		self.debug:toggle_memory_record(e)
	end
end


function M:restart()
	if html5 then
		html5.run('document.location.reload();')
	else
		msg.post("@system:", "reboot")
	end
end


return M
