local decore = require("decore.decore")

---@class entity
---@field acceleration component.acceleration|nil

---@class entity.acceleration: entity
---@field acceleration component.acceleration
---@field physics component.physics
---@field game_object component.game_object

---@class component.acceleration
---@field value number
decore.register_component("acceleration", {
	value = 0
})

---@class system.acceleration: system
---@field entities entity.acceleration[]
local M = {}


---@return system.acceleration
function M.create()
	return decore.processing_system(M, "acceleration", { "acceleration", "physics", "game_object" })
end


---@param entity entity.acceleration
---@param dt number
function M:process(entity, dt)
	-- Add force to the direction of the velocity
	local physics = entity.physics
	local velocity_x = physics.velocity_x
	local velocity_y = physics.velocity_y
	local acceleration = entity.acceleration.value

	local force_x = velocity_x * acceleration * dt
	local force_y = velocity_y * acceleration * dt

	self.world.command_physics:add_force(entity, force_x, force_y)
end


return M
