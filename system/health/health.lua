local evolved = require("evolved")
local fragments = require("fragments")

local min = math.min

local M = {}

function M.register_fragments()
	---@class fragments
	---@field health_max evolved.id
	---@field health evolved.id
	---@field request_damage evolved.id
	---@field remove_on_death evolved.id

	fragments.health_max = evolved.builder():name("health_max"):default(3):spawn()
	fragments.health = evolved.builder():name("health"):default(3):spawn()
	fragments.remove_on_death = evolved.builder():tag():name("remove_on_death"):spawn()
end


function M.create_system()
	local group = evolved.id()

	evolved.builder()
		:group(group)
		:set(fragments.system)
		:name("health.collision_damage")
		:include(fragments.collision_event)
		:execute(M.collision_damage)
		:spawn()

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.collision_damage(chunk, entity_list, entity_count)
	local collision_event = chunk:components(fragments.collision_event)

	for index = 1, entity_count do
		local event = collision_event[index]
		local source = event.entity
		local target = event.other

		if source and evolved.has(source, fragments.on_collision_damage) and target and evolved.has(target, fragments.health) then
			local current_health = evolved.get(target, fragments.health)
			local new_health = current_health - evolved.get(source, fragments.on_collision_damage)
			evolved.set(target, fragments.health, new_health)

			if new_health <= 0 and evolved.has(target, fragments.remove_on_death) then
				--evolved.destroy(target)
				evolved.set(target, fragments.lifetime, 0)
			end
		end
	end
end


return M
