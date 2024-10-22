local ecs = require("decore.ecs")

local TEMP_APPLY_FORCE = {
	force = vmath.vector3(),
	position = vmath.vector3()
}

---@class entity
---@field physics_movement component.physics_movement|nil

---@class entity.physics_movement: entity
---@field physics_movement component.physics_movement
---@field transform component.transform
---@field game_object component.game_object

---@class component.physics_movement
---@field velocity_x number
---@field velocity_y number
---@field friction number

---@class system.physics_movement: system
---@field entities entity.physics_movement[]
local M = {}


---@static
---@return system.physics_movement
function M.create_system()
	local system = setmetatable(ecs.processingSystem(), { __index = M })
	system.filter = ecs.requireAll("physics_movement", "game_object")
	system.id = "physics_movement"

	return system
end


---@param entity entity.physics_movement
---@param x number|nil
---@param y number|nil
function M:add_force(entity, x, y)
	local collision_url = msg.url(nil, entity.game_object.root, "collisionobject")

	TEMP_APPLY_FORCE.force.x = x or 0
	TEMP_APPLY_FORCE.force.y = y or 0
	TEMP_APPLY_FORCE.position.x = entity.transform.position_x
	TEMP_APPLY_FORCE.position.y = entity.transform.position_y

	msg.post(collision_url, "apply_force", TEMP_APPLY_FORCE)
end


return M
