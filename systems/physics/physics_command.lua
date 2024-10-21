local ecs = require("decore.ecs")

---@class world
---@field physics_command system.physics_command

---@class entity
---@field physics_command component.physics_command|nil

---@class entity.physics_command: entity
---@field physics_command component.physics_command

---@class component.physics_command
---@field entity entity
---@field force_x number|nil
---@field force_y number|nil

---@class system.physics_command: system
---@field entities entity.physics_command[]
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
