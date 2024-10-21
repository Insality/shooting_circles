local ecs = require("decore.ecs")

local movement_controller_command = require("systems.movement_controller.movement_controller_command")

---@class entity
---@field movement_controller component.movement_controller|nil

---@class entity.movement_controller: entity
---@field movement_controller component.movement_controller
---@field physics component.physics

---@class component.movement_controller
---@field speed number
---@field movement_x number @Runtime
---@field movement_y number @Runtime

---@class system.movement_controller: system
---@field entities entity.movement_controller[]
local M = {}


---@static
---@return system.movement_controller, system.movement_controller_command
function M.create_system()
	local system = setmetatable(ecs.processingSystem(), { __index = M })
	system.filter = ecs.requireAll("movement_controller", "physics")
	system.id = "movement_controller"

	return system, movement_controller_command.create_system(system)
end


function M:process(entity, dt)
	local movement_controller = entity.movement_controller

	local speed = movement_controller.speed
	local movement_x = movement_controller.movement_x
	local movement_y = movement_controller.movement_y

	if movement_x ~= 0 or movement_y ~= 0 then
		local force_x = movement_x * speed * dt * 60
		local force_y = movement_y * speed * dt * 60
		self.world.physics_command:add_force(entity, force_x, force_y)
	end
end


return M
