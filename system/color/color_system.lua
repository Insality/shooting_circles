local color = require("druid.color")
local decore = require("decore.decore")

---@class entity
---@field color component.color|nil

---@class entity.color: entity
---@field color component.color
---@field game_object component.game_object

---@class component.color
---@field color_id string|nil
---@field color vector4 # color of the entity, constructor can be string
---@field sprites string # "/root#sprite,/root#sprite2"
---@field random_color vector4[] # two colors for lerp
decore.register_component("color", {
	color = vmath.vector4(1),
})

---@class system.color.event
---@field entity entity
---@field color vector4

---@class system.color: system
---@field entities entity.color[]
local M = {}


---@return system.color
function M.create_system()
	return decore.system(M, "color", { "color", "game_object" })
end


---@param entity entity.color
function M:onAdd(entity)
	local random_color = entity.color.random_color
	if random_color then
		entity.color.color = color.lerp(math.random(), random_color[1], random_color[2])
	end

	local color_data = entity.color.color
	if type(color_data) == "string" then
		entity.color.color = color.hex2vector4(color_data)
	end

	if entity.color.color then
		self:apply_color(entity, entity.color.color, entity.color.sprites)
	end
end


---@param entity entity.color
---@param color vector4|nil
---@param sprites string|nil "/root#sprite,/root#sprite2"
function M:apply_color(entity, color, sprites)
	if not color or not sprites then
		return
	end

	local splitted_sprites = M.split(sprites, ",")
	for index = 1, #splitted_sprites do
		local target = splitted_sprites[index]

		local splitted = M.split(target, "#")
		local object_id, component_id = splitted[1], splitted[2] or "sprite"

		-- If target starts with #, then it's a component id
		if string.sub(target, 1, 1) == "#" then
			object_id = nil
			component_id = splitted[1]
		end

		local object = entity.game_object.object
		if object_id then
			if object and object[object_id] then
				local sprite_url = msg.url(nil, object[object_id], component_id)
				go.set(sprite_url, "color", color) -- vertex attribute
			end
		else
			local root = entity.game_object.root
			if root then
				local sprite_url = msg.url(nil, root, component_id)
				go.set(sprite_url, "color", color) -- vertex attribute
			end
		end
	end
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
