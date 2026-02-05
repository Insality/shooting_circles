local decore = require("decore.decore")

local command_game_gui = require("entity.game_gui.game_gui_command")
local levels = require("game.levels")

---@class entity
---@field game_gui component.game_gui|nil

---@class entity.game_gui: entity
---@field game_gui component.game_gui
---@field game_object component.game_object

---@class component.game_gui
decore.register_component("game_gui", false)

---@class system.game_gui: system
---@field entities entity.game_gui[]
local M = {}


---@return system.game_gui
function M.create()
	return decore.system(M, "game_gui", { "game_gui", "game_object" })
end


function M:onAddToWorld()
	self.world.game_gui = command_game_gui.create(self)
end


---@param entity entity.game_gui
function M:onAdd(entity)
	local widget = entity.druid_widget.widget --[[@as widget.game_gui]]
	widget.button_left.on_click:subscribe(function() levels.spawn_next(self.world, -1) end)
	widget.button_right.on_click:subscribe(function() levels.spawn_next(self.world, 1) end)
end


return M
