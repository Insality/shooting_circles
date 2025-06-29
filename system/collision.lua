local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field on_collision_damage evolved.id
	---@field on_collision_remove evolved.id
	---@field on_collision_spawn_entity evolved.id
	---@field collision evolved.id
	---@field collision_event evolved.id

	components.on_collision_damage = evolved.builder():name("on_collision_damage"):default(10):spawn()
	components.on_collision_remove = evolved.builder():name("on_collision_remove"):tag():spawn()
	components.on_collision_spawn_entity = evolved.builder():name("on_collision_spawn_entity"):spawn()
	components.collision = evolved.builder():name("collision"):tag():spawn()
	components.collision_event = evolved.builder():name("collision_event"):spawn()
end



function M.create_system()
	M.collision_event_prefab = evolved.builder()
		:name("collision_event")
		:prefab()
		:spawn()

	physics.set_listener(function(_, event_id, event)
		M.physics_world_listener(event_id, event)
	end)

	local group = evolved.builder()
		:name("collision")
		:include(components.collision)
		:spawn()

	evolved.builder()
		:group(group)
		:set(components.system)
		:name("collisiton.store_root")
		:include(components.collision, components.root_url)
		:execute(M.store_root)
		:spawn()

	evolved.builder()
		:group(group)
		:set(components.system)
		:include(components.single_update)
		:name("collisiton.reset_collided_this_frame")
		:execute(M.reset_collided_this_frame)
		:spawn()

	return group
end


local root_to_entity = {}
function M.store_root(chunk, entity_list, entity_count)
	local root_url = chunk:components(components.root_url)

	for index = 1, entity_count do
		root_to_entity[root_url[index]] = entity_list[index]
	end
end


local collided_this_frame = {}
function M.reset_collided_this_frame(chunk, entity_list, entity_count)
	collided_this_frame = {}
end


local CONTACT_POINT_EVENT = hash("contact_point_event")
local COLLISION_EVENT = hash("collision_event")
local TRIGGER_EVENT = hash("trigger_event")
local RAY_CAST_RESPONSE = hash("ray_cast_response")
local RAY_CAST_MISSED = hash("ray_cast_missed")

---@param event hash @Event type
---@param data any
function M.physics_world_listener(event, data)
	if event == CONTACT_POINT_EVENT then
		M.handle_contact_point_event(data)
	elseif event == COLLISION_EVENT then
		M.handle_collision_event(data)
	elseif event == TRIGGER_EVENT then
		M.handle_trigger_event(data)
	elseif event == RAY_CAST_RESPONSE then
		-- Handle raycast hit data
	elseif event == RAY_CAST_MISSED then
		-- Handle raycast miss data
	end
end


---@param entity_source evolved.entity?
---@param entity_target evolved.entity?
---@param event_data physics.collision.contact_point_event|physics.collision.trigger_event|physics.collision.collision_event
---@param event_type string @"contact_point_event"|"trigger_event"|"collision_event"
local function handle_collision_event(entity_source, entity_target, event_data, event_type)
	if entity_source and evolved.has(entity_source, components.collision) then
		local collision = evolved.get(entity_source, components.collision)

		if evolved.has(entity_source, components.on_collision_remove) then
			evolved.destroy(entity_source)
		end

		--if collision.trigger_event and event_type == "trigger_event" then
		--end

		local collision_event = {
			entity = entity_source,
			other = entity_target,
			[event_type] = event_data
		}
		evolved.clone(M.collision_event_prefab, {
			[components.collision_event] = collision_event,
		})
	end

	if entity_target and evolved.has(entity_target, components.collision) then
		local collision = evolved.get(entity_target, components.collision)

		if evolved.has(entity_target, components.on_collision_remove) then
			evolved.destroy(entity_target)
		end

		--if collision.trigger_event and event_type == "trigger_event" then
		--end

		local collision_event = {
			entity = entity_target,
			other = entity_source,
			[event_type] = event_data
		}
		evolved.clone(M.collision_event_prefab, {
			[components.collision_event] = collision_event,
		})
	end
end


---@param event_data physics.collision.contact_point_event
function M.handle_contact_point_event(event_data)
	-- Handle contact point data
	local entity_source = root_to_entity[event_data.a.id]
	local entity_target = root_to_entity[event_data.b.id]
	handle_collision_event(entity_source, entity_target, event_data, "contact_point_event")
end


---@param event_data physics.collision.trigger_event
function M.handle_trigger_event(event_data)
	-- Handle trigger interaction data
	local entity_source = root_to_entity[event_data.a.id]
	local entity_target = root_to_entity[event_data.b.id]
	handle_collision_event(entity_source, entity_target, event_data, "trigger_event")
end


---@param event_data physics.collision.collision_event
function M.handle_collision_event(event_data)
	local entity_source = root_to_entity[event_data.a.id]
	local entity_target = root_to_entity[event_data.b.id]

	local is_source_collided = collided_this_frame[entity_source] and collided_this_frame[entity_source][entity_target]
	if entity_source and evolved.has(entity_source, components.collision) and not is_source_collided then
		handle_collision_event(entity_source, entity_target, event_data, "collision_event")

		if entity_target then
			collided_this_frame[entity_source] = collided_this_frame[entity_source] or {}
			collided_this_frame[entity_source][entity_target] = true

			collided_this_frame[entity_target] = collided_this_frame[entity_target] or {}
			collided_this_frame[entity_target][entity_source] = true
		end
	end

	local is_target_collided = collided_this_frame[entity_target] and collided_this_frame[entity_target][entity_source]
	if entity_target and evolved.has(entity_target, components.collision) and not is_target_collided then
		handle_collision_event(entity_target, entity_source, event_data, "collision_event")

		if entity_source then
			collided_this_frame[entity_target] = collided_this_frame[entity_target] or {}
			collided_this_frame[entity_target][entity_source] = true

			collided_this_frame[entity_source] = collided_this_frame[entity_source] or {}
			collided_this_frame[entity_source][entity_target] = true
		end
	end
end

return M
