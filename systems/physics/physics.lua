local decore = require("decore.decore")

local physics_command = require("systems.physics.physics_command")

---@class entity
---@field physics component.physics|nil

---@class entity.physics: entity
---@field physics component.physics
---@field game_object component.game_object
---@field transform component.transform

---@class component.physics
---@field box2d_body b2Body
---@field collisionobject_url url
---@field velocity_x number
---@field velocity_y number

---@class system.physics: system
---@field entities entity.physics[]
local M = {}

local TEMP_VECTOR = vmath.vector3()

---@static
---@return system.physics, system.physics_command
function M.create_system()
	local system = setmetatable(decore.ecs.processingSystem(), { __index = M })
	system.filter = decore.ecs.requireAll("physics", "game_object", "transform")
	system.id = "physics"

	return system, physics_command.create_system(system)
end


---@param entity entity.physics
function M:onAdd(entity)
	local collisionobject_url = msg.url(nil, entity.game_object.root, "collisionobject")
	entity.physics.collisionobject_url = collisionobject_url
	entity.physics.box2d_body = b2d.get_body(collisionobject_url)

	local body = entity.physics.box2d_body
	TEMP_VECTOR.x = entity.physics.velocity_x
	TEMP_VECTOR.y = entity.physics.velocity_y
	b2d.body.set_linear_velocity(body, TEMP_VECTOR)
end


function M:onRemove(entity)
	entity.physics.box2d_body = nil
	entity.physics.collisionobject_url = nil
end


---@param entity entity.physics
---@param dt number
function M:process(entity, dt)
	local body = entity.physics.box2d_body
	local is_awake = b2d.body.is_awake(body)
	if not is_awake then
		return
	end

	-- Is it faster?
	local position = b2d.body.get_position(body)
	local position_x = position.x
	local position_y = position.y
	--local position_x = go.get(entity.game_object.root, "position.x")
	--local position_y = go.get(entity.game_object.root, "position.y")
	local transform = entity.transform
	if position_x ~= transform.position_x or position_y ~= transform.position_y then
		transform.position_x = position_x
		transform.position_y = position_y

		self.world.queue:push("transform_event", {
			entity = entity,
			is_position_changed = true
		})
	end

	local velocity = b2d.body.get_linear_velocity(body)
	entity.physics.velocity_x = velocity.x
	entity.physics.velocity_y = velocity.y
end


---@param entity entity.physics
---@param force_x number
---@param force_y number
function M:add_force(entity, force_x, force_y)
	if not decore.is_alive(self, entity) then
		return
	end

	local body = entity.physics.box2d_body
	TEMP_VECTOR.x = force_x or 0
	TEMP_VECTOR.y = force_y or 0
	TEMP_VECTOR.z = 0
	b2d.body.apply_force_to_center(body, TEMP_VECTOR)
end


return M
