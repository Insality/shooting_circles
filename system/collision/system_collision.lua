local decore = require("decore.decore")

---If true, will get collision events.
---@class component.collision: boolean
decore.register_component("collision", false)

---@class event.collision_event
---@field entity entity
---@field other entity
---@field trigger_event physics.collision.trigger_event|nil
---@field collision_event physics.collision.collision_event|nil

---@class system.collision: system
---@field root_to_entity table<url, entity>
---@field collided_this_frame table<entity, entity>
local M = {}


---@return system.collision
function M.create_system()
	local system = decore.system(M, "collision", "game_object")

	system.root_to_entity = {}
	system.collided_this_frame = {}

	return system
end


function M:onAddToWorld()
	physics.set_listener(function(_, event_id, event)
		M.physics_world_listener(self, event_id, event)
	end)

	self.world.event_bus:set_merge_policy("collision_event", function(events, new_event)
		for index = #events, 1, -1 do
			local event = events[index]
			if event.entity == new_event.entity and event.other == new_event.other then
				return true
			end
		end
		return false
	end)
end


function M:onRemoveFromWorld()
	physics.set_listener(nil)
end


---@param entity entity
function M:onAdd(entity)
	local root = entity.game_object.root
	if root then
		self.root_to_entity[root] = entity
	end
end


---@param entity entity
function M:onRemove(entity)
	local root = entity.game_object.root
	if root then
		self.root_to_entity[root] = nil
	end
end


function M:preWrap()
	self.collided_this_frame = {}
end


local CONTACT_POINT_EVENT = hash("contact_point_event")
local COLLISION_EVENT = hash("collision_event")
local TRIGGER_EVENT = hash("trigger_event")
local RAY_CAST_RESPONSE = hash("ray_cast_response")
local RAY_CAST_MISSED = hash("ray_cast_missed")

---@param self system.collision
---@param event hash @Event type
---@param data any
function M.physics_world_listener(self, event, data)
	if event == CONTACT_POINT_EVENT then
		-- Handle detailed contact point data
	elseif event == COLLISION_EVENT then
		local event_data = data --[[@as physics.collision.collision_event]]
		-- Handle general collision data
		local entity_source = self.root_to_entity[event_data.a.id]
		local entity_target = self.root_to_entity[event_data.b.id]

		local is_source_collided = self.collided_this_frame[entity_source] and self.collided_this_frame[entity_source][entity_target]
		if entity_source and entity_source.collision and not is_source_collided then
			---@type event.collision_event
			local collision_event = {
				entity = entity_source,
				other = entity_target,
				collision_event = event_data
			}
			self.world.event_bus:trigger("collision_event", collision_event)

			if entity_target then
				self.collided_this_frame[entity_source] = self.collided_this_frame[entity_source] or {}
				self.collided_this_frame[entity_source][entity_target] = true
			end
		end

		local is_target_collided = self.collided_this_frame[entity_target] and self.collided_this_frame[entity_target][entity_source]
		if entity_target and entity_target.collision and not is_target_collided then
			---@type event.collision_event
			local collision_event = {
				entity = entity_target,
				other = entity_source,
				collision_event = event_data
			}
			self.world.event_bus:trigger("collision_event", collision_event)
			if entity_source then
				self.collided_this_frame[entity_target] = self.collided_this_frame[entity_target] or {}
				self.collided_this_frame[entity_target][entity_source] = true
			end
		end

	elseif event == TRIGGER_EVENT then
		local event_data = data --[[@as physics.collision.trigger_event]]
		-- Handle trigger interaction data
		local entity_source = self.root_to_entity[event_data.a.id]
		local entity_target = self.root_to_entity[event_data.b.id]

		if entity_source and entity_source.collision then
			---@type event.collision_event
			local collision_event = {
				entity = entity_source,
				other = entity_target,
				trigger_event = event_data
			}
			self.world.event_bus:trigger("collision_event", collision_event)
		end

		if entity_target and entity_target.collision then
			---@type event.collision_event
			local collision_event = {
				entity = entity_target,
				other = entity_source,
				trigger_event = event_data
			}
			self.world.event_bus:trigger("collision_event", collision_event)
		end
	elseif event == RAY_CAST_RESPONSE then
		-- Handle raycast hit data
	elseif event == RAY_CAST_MISSED then
		-- Handle raycast miss data
	end
end


return M
