local evolved = require("evolved")
local components = require("components")


local M = {}


function M.register_components()
	---@class components
	---@field speed evolved.id
	---@field velocity_angle evolved.id
	components.speed = evolved.builder():name("speed"):default(0):spawn()
	components.velocity_angle = evolved.builder():name("velocity_angle"):default(0):spawn()
end


---@return evolved.id
function M.create_system()
	return evolved.builder()
		:name("velocity_angle")
		:set(components.system)
		:include(components.velocity_x, components.velocity_y)
		:include(components.velocity_angle, components.speed)
		:execute(M.execute)
		:spawn()
end


local cos = math.cos
local sin = math.sin
local rad = math.rad

---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.execute(chunk, entity_list, entity_count)
	local dt = evolved.get(components.dt, components.dt)
	local velocity_circle, velocity_x, velocity_y, speed = chunk:components(components.velocity_angle, components.velocity_x, components.velocity_y, components.speed)

	for index = 1, entity_count do
		velocity_circle[index] = velocity_circle[index] + dt * speed[index]
		local current_angle = velocity_circle[index]

		local vx = cos(rad(current_angle)) * (speed[index])
		local vy = sin(rad(current_angle)) * (speed[index])
		velocity_x[index] = vx
		velocity_y[index] = vy
	end
end


return M
