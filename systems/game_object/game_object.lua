local decore = require("decore.decore")

---@class entity
---@field game_object component.game_object|nil
---@field hidden boolean|nil

---@class entity.game_object: entity
---@field game_object component.game_object
---@field transform component.transform
---@field hidden boolean|nil

---@class component.game_object
---@field factory_url string
---@field root string|hash|url
---@field object table<string|hash, string|hash|url>
---@field is_slice9 boolean|nil
---@field remove_delay number|nil
decore.register_component("game_object", {
	factory_url = "",
})
decore.register_component("hidden", false)


---@class system.game_object: system
local M = {}

local TEMP_VECTOR = vmath.vector3()
local ROOT_URL = hash("/root")


---@static
---@return system.game_object
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("game_object", "transform", decore.ecs.rejectAll("hidden"))
	system.id = "game_object"

	return system
end


function M:postWrap()
	self.world.queue:process("transform_event", self.process_transform_event, self)
end


---@param entity entity.game_object
function M:onAdd(entity)
	local is_already_exists = entity.game_object.root or entity.game_object.object
	if is_already_exists then
		return
	end

	local object = self:create_object(entity)
	local root = object[ROOT_URL]
	entity.game_object.root = root
	entity.game_object.object = object

	if root then
		if entity.game_object.is_slice9 then
			TEMP_VECTOR.x = entity.transform.size_x
			TEMP_VECTOR.y = entity.transform.size_y
			TEMP_VECTOR.z = 0
			local sprite_url = msg.url(nil, root, "sprite")
			go.set(sprite_url, "size", TEMP_VECTOR)

			-- Set scale to initial 1
			TEMP_VECTOR.x = 1
			TEMP_VECTOR.y = 1
			TEMP_VECTOR.z = 1
			go.set(root, "scale", TEMP_VECTOR)
		else
			TEMP_VECTOR.x = entity.transform.scale_x
			TEMP_VECTOR.y = entity.transform.scale_y
			TEMP_VECTOR.z = entity.transform.scale_x -- X to keep uniform for physics
			go.set(root, "scale", TEMP_VECTOR)
		end

		go.set(root, "euler.z", entity.transform.rotation)
	end
end


---@param entity entity.game_object
function M:onRemove(entity)
	local remove_delay = entity.game_object.remove_delay

	if not remove_delay then
		for _, object in pairs(entity.game_object.object) do
			go.delete(object)
		end
	else
		timer.delay(remove_delay, false, function()
			for _, object in pairs(entity.game_object.object) do
				go.delete(object)
			end
		end)
	end
end


---@param transform_event event.transform_event
function M:process_transform_event(transform_event)
	local target_entity = transform_event.entity
	local game_object = target_entity.game_object
	if not game_object or target_entity.physics then
		return
	end

	local root = target_entity.game_object.root
	if root and transform_event.is_position_changed then
		TEMP_VECTOR.x = target_entity.transform.position_x
		TEMP_VECTOR.y = target_entity.transform.position_y
		TEMP_VECTOR.z = target_entity.transform.position_z

		local animate_time = transform_event.animate_time
		if animate_time then
			local easing = transform_event.easing or go.EASING_LINEAR
			go.animate(target_entity.game_object.root, "position", go.PLAYBACK_ONCE_FORWARD, TEMP_VECTOR, easing, animate_time)
		else
			go.set_position(TEMP_VECTOR, root)
		end
	end
end



---@param entity entity.game_object
---@return table<string|hash, string|hash>
function M:create_object(entity)
	TEMP_VECTOR.x = entity.transform.position_x
	TEMP_VECTOR.y = entity.transform.position_y
	TEMP_VECTOR.z = self:get_position_z(entity.transform)

	return collectionfactory.create(entity.game_object.factory_url, TEMP_VECTOR, nil, nil, entity.transform.scale_x)
end


---@param t component.transform
---@return number
function M:get_position_z(t)
	return -t.position_y / 10000 + t.position_x / 100000 + t.position_z / 10
end


return M
