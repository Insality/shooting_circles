local bindings = require("gui.bindings")
local decore = require("decore.decore")

local gui_main_command = require("gui.game.game_system_command")

---@class entity
---@field gui_main component.gui_main|nil

---@class entity.gui_main: entity
---@field gui_main component.gui_main
---@field game_object component.game_object

---@class component.gui_main
---@field component gui.game
---@field current_level_index number
decore.register_component("gui_main")

---@class system.gui_main: system
---@field entities entity.gui_main[]
local M = {}

local LEVELS = {
	"game.level1",
	"game.level2",
	"game.level3",
	"game.level4",
	"game.level5",
	"game.level6",
	"game.level7",
	"game.level8",
	"game.level9",
	"game.level10",
	"game.level11",
	"game.level12",
	"game.level13",
	"game.level14",
}

---@static
---@return system.gui_main, system.gui_main_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("gui_main", "game_object")
	system.id = "gui_main"

	return system, gui_main_command.create_system(system)
end


---@param entity entity.gui_main
function M:onAdd(entity)
	entity.gui_main.current_level_index = 1
	entity.gui_main.component = bindings.get_widget(entity.game_object.root) --[[@as gui.game]]

	local component = entity.gui_main.component
	component.button_left.on_click:subscribe(function() self:on_click_button(entity, -1) end)
	component.button_right.on_click:subscribe(function() self:on_click_button(entity, 1) end)

	self:spawn_world(LEVELS[entity.gui_main.current_level_index])
end


function M:spawn_world(world_id)
	self.world.level_loader_command:load_world(world_id, nil, 0, 0, "level")
end


function M:on_click_button(entity, direction)
	local index = entity.gui_main.current_level_index + direction
	if index < 1 then
		index = #LEVELS
	end
	if index > #LEVELS then
		index = 1
	end

	entity.gui_main.current_level_index = index
	self:spawn_world(LEVELS[index])
end


return M
