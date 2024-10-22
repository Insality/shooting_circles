local ecs = require("decore.ecs")

---@class entity
---@field color component.color|nil

---@class entity.color: entity
---@field color component.color
---@field game_object component.game_object

---@class component.color
---@field hex_color string
---@field color vector4|nil
---@field sprite_url string @"/root#sprite" or "/root#sprite,/root#sprite2"

---@class system.color: system
---@field entities entity.color[]
local M = {}


---@static
---@return system.color
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("color", "game_object")
	system.id = "color"

	return system
end


---@param entity entity.color
function M:onAdd(entity)
	local hex_color = entity.color.hex_color
	if hex_color then
		local r, g, b, a = M.hex2rgb(entity.color.hex_color, 1)
		local color = vmath.vector4(r, g, b, a)
		self:apply_color(entity, color, entity.color.sprite_url)
	end
end


---@param entity entity.color
---@param color vector4|nil
---@param sprite_url string|nil "/root#sprite,/root#sprite2"
function M:apply_color(entity, color, sprite_url)
	if not color or not sprite_url then
		return
	end

	local splitted_sprites = M.split(sprite_url, ",")
	for index = 1, #splitted_sprites do
		local target = splitted_sprites[index]

		local splitted = M.split(target, "#")
		local object_id, component_id = splitted[1], splitted[2] or "sprite"

		local object = entity.game_object.object
		if object and object[object_id] then
			local sprite_url = msg.url(nil, object[object_id], component_id)
			go.set(sprite_url, "color", color) -- vertex attribute
		end
	end

	entity.color.color = color
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


---@param hex string
---@param alpha number|nil
---@return number, number, number, number
function M.hex2rgb(hex, alpha)
	alpha = alpha or 1
	if alpha > 1 then
		alpha = alpha / 100
	end

	-- Remove leading #
	if string.sub(hex, 1, 1) == "#" then
		hex = string.sub(hex, 2)
	end

	-- Expand 3-digit hex codes to 6 digits
	if #hex == 3 then
		hex = string.rep(string.sub(hex, 1, 1), 2) ..
				string.rep(string.sub(hex, 2, 2), 2) ..
				string.rep(string.sub(hex, 3, 3), 2)
	end

	local r = tonumber("0x" .. string.sub(hex, 1, 2)) / 255
	local g = tonumber("0x" .. string.sub(hex, 3, 4)) / 255
	local b = tonumber("0x" .. string.sub(hex, 5, 6)) / 255
	return r, g, b, alpha
end


return M
