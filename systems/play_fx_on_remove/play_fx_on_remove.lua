local ecs = require("decore.ecs")

---@class entity
---@field play_fx_on_remove component.play_fx_on_remove|nil

---@class entity.play_fx_on_remove: entity
---@field play_fx_on_remove component.play_fx_on_remove
---@field game_object component.game_object

---@class component.play_fx_on_remove
---@field fx_url string

---@class system.play_fx_on_remove: system
---@field entities entity.play_fx_on_remove[]
local M = {}


---@static
---@return system.play_fx_on_remove
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("play_fx_on_remove", "game_object")

	return system
end


---@param entity entity.play_fx_on_remove
function M:onRemove(entity)
	local fx_url = msg.url(nil, entity.game_object.root, entity.play_fx_on_remove.fx_url)
	particlefx.play(fx_url)
end


return M
