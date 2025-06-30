local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.register_fragments()
	---@class fragments
	---@field velocity_x evolved.id
	---@field velocity_y evolved.id
	---@field velocity evolved.id

	fragments.velocity_x = evolved.builder():name("velocity_x"):default(0):spawn()
	fragments.velocity_y = evolved.builder():name("velocity_y"):default(0):spawn()
	fragments.velocity = evolved.builder():name("velocity"):tag():require(fragments.velocity_x, fragments.velocity_y):spawn()
end


function M.create_system()
	local group = evolved.builder():spawn()

	evolved.builder()
		:name("system.velocity")
		:group(group)
		:include(fragments.velocity, fragments.position)
		:exclude(fragments.physics)
		:set(fragments.system)
		:execute(M.update)
		:spawn()

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update(chunk, entity_list, entity_count)
	local dt = evolved.get(fragments.dt, fragments.dt)
	local velocity_x, velocity_y, position = chunk:components(fragments.velocity_x, fragments.velocity_y, fragments.position)

	for index = 1, entity_count do
		position[index].x = position[index].x + velocity_x[index] * dt
		position[index].y = position[index].y + velocity_y[index] * dt
	end
end


return M
