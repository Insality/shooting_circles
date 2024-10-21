local ecs = require("decore.ecs")

---@class world
---@field physics_command system.physics_command

---@class system.physics_command: system
---@field physics system.physics
local M = {}


---@static
---@return system.physics_command
function M.create_system(physics)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("physics_command")
	system.physics = physics
	system.id = "physics_command"

	return system
end


---@private
function M:onAddToWorld()
	self.world.physics_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.physics_command = nil
end


function M:add_force(entity, force_x, force_y)
	self.physics:add_force(entity, force_x, force_y)
end


return M
