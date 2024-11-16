local decore = require("decore.decore")
local ecs = require("decore.ecs")

---@class world
---@field physics_command system.physics_command

---@class system.physics_command: system_command
---@field physics system.physics
local M = {}


---@static
---@return system.physics_command
function M.create_system(physics)
	local system = decore.system(M, "physics_command")
	system.physics = physics

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


---@param entity entity
---@param force_x number|nil
---@param force_y number|nil
function M:add_force(entity, force_x, force_y)
	assert(entity.physics, "entity must have physics component")
	---@cast entity entity.physics

	self.physics:add_force(entity, force_x, force_y)
end


return M
