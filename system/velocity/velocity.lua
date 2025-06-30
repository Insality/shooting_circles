local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field velocity_x evolved.id
	---@field velocity_y evolved.id
	---@field velocity evolved.id

	components.velocity_x = evolved.builder():name("velocity_x"):default(0):spawn()
	components.velocity_y = evolved.builder():name("velocity_y"):default(0):spawn()
	components.velocity = evolved.builder():name("velocity"):tag():require(components.velocity_x, components.velocity_y):spawn()
end


function M.create_system()
	local group = evolved.builder():spawn()

	evolved.builder()
		:name("system.velocity")
		:group(group)
		:include(components.velocity, components.position)
		:exclude(components.physics)
		:set(components.system)
		:execute(M.update)
		:spawn()

	return group
end


function M.update(chunk, entity_list, entity_count)
	local dt = evolved.get(components.dt, components.dt)
	local velocity_x, velocity_y, position = chunk:components(components.velocity_x, components.velocity_y, components.position)

	for index = 1, entity_count do
		position[index].x = position[index].x + velocity_x[index] * dt
		position[index].y = position[index].y + velocity_y[index] * dt
	end
end


return M
