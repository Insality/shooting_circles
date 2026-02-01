local decore = require("decore.decore")
local command_game_object = require("system.game_object.game_object_command")

---@class entity
---@field game_object component.game_object|nil
---@field hidden boolean|nil

---@class entity.game_object: entity
---@field game_object component.game_object
---@field transform component.transform
---@field hidden boolean|nil

-- { is_factory = true, factory_url = "/entities#window_settings" }
---@class component.game_object
---@field root string|hash
---@field object table<string|hash, string|hash>
---@field sprite_url string|nil # "sprite" as default one. Will try be pick up from the root
---@field factory_url string|nil
---@field is_slice9 boolean|nil
---@field slice9_offset vector3|nil
---@field remove_delay number|nil
---@field is_factory boolean|nil
---@field runtime_created boolean|nil
---@field object_scheme table<string, boolean>|nil Ex: { "root", "circle", "cross" }. Required to set a struct of children game objects to fill inside object field. Used only if entity spawned from the collection with entitty.script
decore.register_component("game_object", {})
decore.register_component("hidden", false)


---@class system.game_object: system
---@field entities entity.game_object[]
---@field root_to_entity table<string|hash, entity>
local M = {}

M.DEBUG_PANEL_UPDATE_MEMORY_LIMIT = 2048
M.DEBUG_PANEL_POSTWRAP_MEMORY_LIMIT = 2048
M.MSG_INIT_ENTITY = hash("init_entity")

local TEMP_VECTOR = vmath.vector3(0, 0, 0)
local TEMP_QUAT = vmath.quat(0, 0, 0, 1)
local VECTOR3_ONE = vmath.vector3(1, 1, 1)
local ROOT_URL = hash("/root")
local HASH_POSITION = hash("position")
local HASH_SIZE = hash("size")
local HASH_SCALE = hash("scale")
local HASH_EULER_Z = hash("euler.z")
local sin = math.sin
local cos = math.cos
local rad = math.rad

---@return system.game_object
function M.create()
	local self = decore.system(M, "game_object")
	self.filter = decore.ecs.requireAll("game_object", "transform", decore.ecs.rejectAll("hidden"))

	self.root_to_entity = {}

	return self
end


function M:onAddToWorld()
	self.world.game_object = command_game_object.create(self)
end


function M:postWrap()
	self.world.event_bus:process("transform_event", self.process_transform_event, self)
end


---@param entity entity.game_object
function M:onAdd(entity)
	local is_already_exists = entity.game_object.root or entity.game_object.object
	if is_already_exists then
		self:refresh_root(entity)
		return
	end

	local object = self:create_object(entity)
	local root = object[ROOT_URL]
	entity.game_object.root = root
	entity.game_object.object = object
	entity.game_object.runtime_created = true
	self:refresh_root(entity)
end


---@param entity entity.game_object
function M:onRemove(entity)
	local remove_delay = entity.game_object.remove_delay

	if not remove_delay then
		self:remove_entity(entity)
	else
		timer.delay(remove_delay, false, function()
			self:remove_entity(entity)
		end)
	end
end


---@param entity entity.game_object
function M:remove_entity(entity)
	local root = entity.game_object.root
	if root then
		self.root_to_entity[root] = nil

		if go.exists(root)then
			go.delete(root, false)
			entity.game_object.root = nil
		end
	end

	local object = entity.game_object.object
	if object then
		for key, node in pairs(object) do
			local related_entity = self.root_to_entity[node]
			if related_entity then
				self.world:removeEntity(related_entity)
			else
				-- TODO: it removes also a childs of the related entity
				-- And I can get errors like panthera trying to play on deleted object
				-- Right before it will be deleted with upper removeEntity
				if go.exists(node) then
					go.delete(node, false)
					object[key] = nil
				end
			end
		end
	end
end


---@param events system.transform.event[]
function M:process_transform_event(events)
	for i = 1, #events do
		local event = events[i]
		local entity = event.entity
		local transform = entity.transform
		local game_object = entity.game_object

		if not self.indices[entity] or not game_object then
			-- skip
		else
			local root = game_object.root
			if root then
				local delay = event.delay or 0

				if event.is_position_changed then
					TEMP_VECTOR.x = transform.position_x
					TEMP_VECTOR.y = transform.position_y
					--TEMP_VECTOR.z = transform.position_z
					TEMP_VECTOR.z = self:get_position_z(transform)
					if event.animate_time then
						local easing = event.easing or go.EASING_OUTSINE
						go.animate(root, HASH_POSITION, go.PLAYBACK_ONCE_FORWARD, TEMP_VECTOR, easing, event.animate_time, delay)
					else
						go.set_position(TEMP_VECTOR, root)
					end
				end

				if event.is_rotation_changed then
					if event.animate_time then
						local easing = event.easing or go.EASING_OUTSINE
						go.animate(root, HASH_EULER_Z, go.PLAYBACK_ONCE_FORWARD, transform.rotation, easing, event.animate_time, delay)
					else
						go.set(root, HASH_EULER_Z, transform.rotation)
					end
				end

				if event.is_scale_changed then
					TEMP_VECTOR.x = transform.scale_x
					TEMP_VECTOR.y = transform.scale_y
					TEMP_VECTOR.z = transform.scale_z
					if event.animate_time then
						local easing = event.easing or go.EASING_OUTSINE
						go.animate(root, HASH_SCALE, go.PLAYBACK_ONCE_FORWARD, TEMP_VECTOR, easing, event.animate_time, delay)
					else
						go.set_scale(TEMP_VECTOR, root)
					end
				end

				if game_object.is_slice9 then
					local component_url = M.get_component_url(entity, game_object.sprite_url or "/root#sprite")

					TEMP_VECTOR.x = transform.size_x
					TEMP_VECTOR.y = transform.size_y
					if event.animate_time then
						local easing = event.easing or go.EASING_OUTSINE
						go.animate(component_url, HASH_SIZE, go.PLAYBACK_ONCE_FORWARD, TEMP_VECTOR, easing, event.animate_time, delay)
					else
						go.set(component_url, HASH_SIZE, TEMP_VECTOR)
					end
				end
			end
		end
	end
end


function M:refresh_transform(entity)
	local root = entity.game_object.root
	if not root then
		return
	end

	go.set_position(entity.transform.position, root)
	go.set_scale(entity.transform.scale, root)

	TEMP_QUAT.z = sin(rad(entity.transform.rotation) * 0.5)
	TEMP_QUAT.w = cos(rad(entity.transform.rotation) * 0.5)
	go.set_rotation(TEMP_QUAT, root)
end


local PROPERTIES = { [ROOT_URL] = { is_spawn_by_entity = true } }
---@param entity entity.game_object
---@return table<string|hash, string|hash>
function M:create_object(entity)
	TEMP_VECTOR.x = entity.transform.position_x
	TEMP_VECTOR.y = entity.transform.position_y
	TEMP_VECTOR.z = self:get_position_z(entity.transform)

	if entity.game_object.is_factory then
		local object = factory.create(entity.game_object.factory_url, TEMP_VECTOR, nil, PROPERTIES[ROOT_URL], entity.transform.scale_x)
		return { [ROOT_URL] = object }
	else
		return collectionfactory.create(entity.game_object.factory_url, TEMP_VECTOR, nil, PROPERTIES, entity.transform.scale_x)
	end
end


---@param t component.transform
---@return number
function M:get_position_z(t)
	return -t.position_y / 10000 + t.position_x / 100000 + t.position_z / 10
end


---@param entity entity.game_object
function M:refresh_root(entity)
	local root = entity.game_object.root
	if not root then
		return
	end

	if entity.game_object.is_slice9 then
		local sprite_id = entity.game_object.sprite_url or "sprite"
		local component_url = M.get_component_url(entity, sprite_id)
		local slice9_offset = entity.game_object.slice9_offset
		TEMP_VECTOR.x = entity.transform.size_x + (slice9_offset and slice9_offset.x or 0)
		TEMP_VECTOR.y = entity.transform.size_y + (slice9_offset and slice9_offset.y or 0)
		go.set(component_url, HASH_SIZE, TEMP_VECTOR)
		go.set(root, HASH_SCALE, VECTOR3_ONE)
	else
		TEMP_VECTOR.x = entity.transform.scale_x
		TEMP_VECTOR.y = entity.transform.scale_y
		TEMP_VECTOR.z = entity.transform.scale_z
		go.set(root, HASH_SCALE, TEMP_VECTOR)
	end

	go.set(root, HASH_EULER_Z, entity.transform.rotation)

	TEMP_VECTOR.x = entity.transform.position_x
	TEMP_VECTOR.y = entity.transform.position_y
	TEMP_VECTOR.z = self:get_position_z(entity.transform)
	go.set(root, HASH_POSITION, TEMP_VECTOR)

	self.root_to_entity[root] = entity
end


---Split string by separator
---@param s string
---@param sep string
function M.split(s, sep)
	sep = sep or "%s"
	local t = {}
	local i = 1
	for str in string.gmatch(s, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


---@param entity entity
---@param sprite_url string
function M.get_component_url(entity, sprite_url)
	local splitted = M.split(sprite_url, "#")
	local object_id, component_id = splitted[1], splitted[2] or "sprite"
	-- If target starts with #, then it's a component id
	if string.sub(sprite_url, 1, 1) == "#" then
		object_id = nil
		component_id = splitted[1]
	end

	local target_url = msg.url(nil, object_id, component_id)
	if entity.game_object and entity.game_object.object then
		local object_url = entity.game_object.object[object_id]
		target_url = msg.url(nil, object_url, component_id)
	end

	return target_url
end


return M
