local decore = require("decore.decore")

---@class event.collision_event
---@field entity entity
---@field other entity
---@field trigger_event physics.collision.trigger_event|nil
---@field collision_event physics.collision.collision_event|nil

---@class system.collision: system
---@field root_to_entity table<url, entity>
---@field collided_this_frame table<entity, entity>
local M = {}


---@static
---@return system.collision
function M.create_system()
	local system = setmetatable(decore.ecs.processingSystem(), { __index = M })
	system.filter = decore.ecs.requireAll("game_object")
	system.id = "collision"

	system.root_to_entity = {}
	system.collided_this_frame = {}

	return system
end


function M:onAddToWorld()
	physics.set_listener(function(_, event_id, event)
		M.physics_world_listener(self, event_id, event)
	end)

	self.world.queue:set_merge_policy("collision_event", function(events, new_event)
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
	self.root_to_entity[entity.game_object.root] = entity
end


---@param entity entity
function M:onRemove(entity)
	self.root_to_entity[entity.game_object.root] = nil
end


function M:preWrap()
	self.collided_this_frame = {}
end


local CONTACT_POINT_EVENT = hash("contact_point_event")
local COLLISION_EVENT = hash("collision_event")
local TRIGGER_EVENT = hash("trigger_event")
local RAY_CAST_RESPONSE = hash("ray_cast_response")
local RAY_CAST_MISSED = hash("ray_cast_missed")

---@class physics.collision.object
---@field id hash @Id of the object
---@field group hash @Group of the object
---@field position vector3|nil @Position of the object
---@field relative_velocity vector3|nil @Relative velocity of the object
---@field mass number|nil @Mass of the object
---@field normal vector3|nil @Normal of the object

---@class physics.collision.contact_point_event
---@field a physics.collision.object
---@field b physics.collision.object
---@field applied_impulse number @Applied impulse
---@field distance number @Distance

---@class physics.collision.collision_event
---@field a physics.collision.object
---@field b physics.collision.object

---@class physics.collision.ray_cast_response
---@field requst_id number @Request id
---@field group hash @Group of the object
---@field position vector3 @Position of the object
---@field normal vector3 @Normal of the object
---@field fraction number @Fraction of the object

---@class physics.collision.ray_cast_missed
---@field requst_id number @Request id

---@class physics.collision.trigger_event
---@field a physics.collision.object
---@field b physics.collision.object
---@field enter boolean @True if the trigger interaction is entering, false if it is exiting

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
			self.world.queue:push("collision_event", collision_event)

			if entity_target then
				self.collided_this_frame[entity_source] = self.collided_this_frame[entity_source] or {}
				self.collided_this_frame[entity_source][entity_target] = true
			end

			if entity_source.on_collision_remove then
				b2d.body.set_linear_velocity(entity_source.physics.box2d_body, vmath.vector3(0))
				b2d.body.set_awake(entity_source.physics.box2d_body, false)
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
			self.world.queue:push("collision_event", collision_event)
			if entity_source then
				self.collided_this_frame[entity_target] = self.collided_this_frame[entity_target] or {}
				self.collided_this_frame[entity_target][entity_source] = true
			end

			if entity_target.on_collision_remove then
				b2d.body.set_linear_velocity(entity_target.physics.box2d_body, vmath.vector3(0))
				b2d.body.set_awake(entity_target.physics.box2d_body, false)
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
			self.world.queue:push("collision_event", collision_event)
		end

		if entity_target and entity_target.collision then
			---@type event.collision_event
			local collision_event = {
				entity = entity_target,
				other = entity_source,
				trigger_event = event_data
			}
			self.world.queue:push("collision_event", collision_event)
		end
	elseif event == RAY_CAST_RESPONSE then
		-- Handle raycast hit data
	elseif event == RAY_CAST_MISSED then
		-- Handle raycast miss data
	end
end


return M
