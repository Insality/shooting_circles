local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field physics evolved.id
	---@field body_url evolved.id

	components.physics = evolved.builder():name("physics"):spawn()
	components.body_url = evolved.builder():name("body_url"):spawn()
end


function M.create_system()
	local group = evolved.builder()
		:name("physics")
		:include(components.physics)
		:set(components.system)
		:spawn()

	evolved.builder()
		:name("physics.hook_body_url")
		:group(group)
		:include(components.physics, components.root_url)
		:exclude(components.body_url)
		:execute(M.hook_body_url)
		:spawn()

	evolved.builder()
		:name("physics.sync_body")
		:group(group)
		:include(components.body_url, components.position)
		:execute(M.sync_body)
		:spawn()

	return group
end


local TEMP_VECTOR = vmath.vector3()
function M.hook_body_url(chunk, entity_list, entity_count)
	local root_url = chunk:components(components.root_url)

	for index = 1, entity_count do
		local collisionobject_url = msg.url(nil, root_url[index], "collisionobject")
		local body = b2d.get_body(collisionobject_url)
		evolved.set(entity_list[index], components.body_url, body)

		TEMP_VECTOR.x = evolved.get(entity_list[index], components.velocity_x)
		TEMP_VECTOR.y = evolved.get(entity_list[index], components.velocity_y)
		b2d.body.set_active(body, true)
		b2d.body.set_linear_velocity(body, TEMP_VECTOR)
	end
end


function M.sync_body(chunk, entity_list, entity_count)
	local body_url, position = chunk:components(components.body_url, components.position)
	local velocity_x, velocity_y = chunk:components(components.velocity_x, components.velocity_y)

	for index = 1, entity_count do
		local pos = position[index]
		local body_position = b2d.body.get_position(body_url[index])
		pos.x = body_position.x
		pos.y = body_position.y

		local velocity = b2d.body.get_linear_velocity(body_url[index])
		velocity_x[index] = velocity.x
		velocity_y[index] = velocity.y
	end
end


return M
