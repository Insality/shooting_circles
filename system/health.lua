local evolved = require("evolved")
local components = require("components")

local min = math.min

local M = {}

function M.register_components()
	---@class components
	---@field max_health evolved.id
	---@field health evolved.id
	---@field request_damage evolved.id
	---@field remove_on_death evolved.id

	components.max_health = evolved.builder():name("max_health"):default(3):spawn()
	components.health = evolved.builder():name("health"):default(3):spawn()
	components.request_damage = evolved.builder():name("request_damage"):default(1):spawn()
	components.remove_on_death = evolved.builder():tag():name("remove_on_death"):spawn()
end


function M.create_system()
	local group = evolved.id()

	evolved.builder()
		:group(group)
		:set(components.system)
		:name("health.damage")
		:include(components.request_damage, components.health)
		:execute(M.update_request_damage)
		:spawn()

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update_request_damage(chunk, entity_list, entity_count)
	local request_damage, health, max_health = chunk:components(components.request_damage, components.health, components.max_health)

	for index = 1, entity_count do
		health[index] = min(health[index] - request_damage[index], max_health[index])

		local entity = entity_list[index]
		if health[index] <= 0 and evolved.has(entity, components.remove_on_death) then
			evolved.remove(entity)
		end
	end
end


return M
