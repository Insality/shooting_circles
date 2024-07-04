local ecs = require("decore.ecs")

---@class entity
---@field physics_movement_command component.physics_movement_command|nil

---@class entity.physics_movement_command: entity
---@field physics_movement_command component.physics_movement_command

---@class component.physics_movement_command
---@field entity entity.physics_movement
---@field velocity_x number|nil
---@field velocity_y number|nil
---@field force_x number|nil
---@field force_y number|nil

---@class system.physics_movement_command: system
---@field entities entity.physics_movement_command[]
---@field physics_movement system.physics_movement
local M = {}


---@static
---@return system.physics_movement_command
function M.create_system(physics_movement)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("physics_movement_command")
	system.physics_movement = physics_movement
	system.id = "physics_movement_command"

	return system
end


---@param entity entity.physics_movement_command
function M:onAdd(entity)
	local command = entity.physics_movement_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.physics_movement_command
function M:process_command(command)
	local entity = command.entity
	local physics_movement = self.physics_movement
	
	if command.force_x or command.force_y then
		self.physics_movement:add_force(entity, command.force_x, command.force_y)
	end
end


return M
