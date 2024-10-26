local bindings = require("gui.bindings")
local decore = require("decore.decore")

local game_gui_command = require("gui.game.game_system_command")

---@class entity
---@field game_gui component.game_gui|nil

---@class entity.game_gui: entity
---@field game_gui component.game_gui
---@field game_object component.game_object

---@class component.game_gui
---@field component gui.game
---@field current_level_index number
decore.register_component("game_gui")

---@class system.game_gui: system
---@field entities entity.game_gui[]
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
---@return system.game_gui, system.game_gui_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("game_gui", "game_object")
	system.id = "game_gui"

	return system, game_gui_command.create_system(system)
end


---@param entity entity.game_gui
function M:onAdd(entity)
	entity.game_gui.current_level_index = 1
	entity.game_gui.component = bindings.get_widget(entity.game_object.root) --[[@as gui.game]]

	local component = entity.game_gui.component
	component.button_left.on_click:subscribe(function() self:on_click_button(entity, -1) end)
	component.button_right.on_click:subscribe(function() self:on_click_button(entity, 1) end)

	--self:spawn_world(LEVELS[entity.game_gui.current_level_index])
end


function M:on_click_button(entity, direction)
	local index = entity.game_gui.current_level_index + direction
	if index < 1 then
		index = #LEVELS
	end
	if index > #LEVELS then
		index = 1
	end

	entity.game_gui.current_level_index = index
	--self:spawn_world(LEVELS[index])
end


function M:spawn_world(world_id)
	self.world.level_loader_command:load_world(world_id, nil, 0, 0, "level")
end


return M
