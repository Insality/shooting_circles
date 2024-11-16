local decore = require("decore.decore")

---@class entity
---@field damage_number number|nil

---@class entity.damage_number: entity
---@field damage_number number
---@field game_object component.game_object
---@field transform component.transform

---@class component.damage_number
---@field damage_number number
decore.register_component("damage_number", {
	damage_number = 0,
})

---@class system.damage_number: system
---@field entities entity.damage_number[]
local M = {}


---@static
---@return system.damage_number
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("damage_number", "game_object")
	system.id = "damage_number"

	return system
end


---@param entity entity.damage_number
function M:onAdd(entity)
	local time_1 = 0.4
	local time_2 = 0.7
	local offset_x = math.random(-100, 100)
	local offset_y = math.random(-50, 0)
	local height = math.random(50, 100)

	-- Set damage text
	local label_url = self:get_component_url(entity.game_object.object, "/root#label")
	label.set_text(label_url, tostring(entity.damage_number))
	local root = entity.game_object.root

	local t = entity.transform
	go.set(root, "position.x", t.position_x + offset_x)
	go.animate(root, "position.x", go.PLAYBACK_ONCE_FORWARD, t.position_x + offset_x + offset_x/2, go.EASING_OUTSINE, time_1, 0, function()
		go.animate(root, "position.x", go.PLAYBACK_ONCE_FORWARD, t.position_x + offset_x, go.EASING_INSINE, time_2, 0)
	end)

	go.set(root, "position.y", t.position_y + offset_y)
	go.animate(root, "position.y", go.PLAYBACK_ONCE_FORWARD, t.position_y + height + offset_y, go.EASING_OUTSINE, time_1 + time_2, 0, function()
		self.world:removeEntity(entity)
	end)

	local z = self:get_position_z(t)
	go.set(root, "position.z", z)
	go.animate(root, "position.z", go.PLAYBACK_ONCE_FORWARD, z - 1, go.EASING_LINEAR, time_1 + time_2)

	go.animate(root, "scale.x", go.PLAYBACK_ONCE_FORWARD, 1.2, go.EASING_OUTSINE, time_1, 0, function()
		go.animate(root, "scale.x", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INSINE, time_2, 0)
	end)

	go.animate(root, "scale.y", go.PLAYBACK_ONCE_FORWARD, 1.2, go.EASING_OUTSINE, time_1, 0, function()
		go.animate(root, "scale.y", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INSINE, time_2, 0)
	end)

	go.animate(label_url, "color.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_OUTSINE, time_2 + time_1)
	go.animate(label_url, "outline.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_OUTSINE, time_2 + time_1)
end


---@param object table<string|hash, string|hash> @Table from game_object.object
---@param component_url string @ Example: "/root#sprite"
---@return url
function M:get_component_url(object, component_url)
	local path_ids = M.split(component_url, "#")
	local object_id = path_ids[1]
	local fragment_id = path_ids[2]

	local object_url = msg.url(object[hash(object_id)])
	object_url.fragment = fragment_id

	return object_url
end


---@param t component.transform
---@return number
function M:get_position_z(t)
	return -t.position_y / 10000 + t.position_x / 100000 + t.position_z / 10 + 5
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


return M
