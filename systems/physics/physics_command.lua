local ecs = require("decore.ecs")

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


---@param entity entity.physics_command
function M:onAdd(entity)
	local command = entity.physics_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.physics_command
function M:process_command(command)
	local e = command.entity --[[@as entity.physics]]

	if command.force_x or command.force_y then
		self.physics:add_force(e, command.force_x, command.force_y)
	end
end


return M
