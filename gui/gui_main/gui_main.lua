local bindings = require("gui.bindings")
local ecs = require("decore.ecs")

local gui_main_command = require("gui.gui_main.gui_main_command")

---@class entity
---@field gui_main component.gui_main|nil

---@class entity.gui_main: entity
---@field gui_main component.gui_main
---@field game_object component.game_object

---@class component.gui_main
---@field bindings gui.main.bindings
---@field current_level_index number

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
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("gui_main", "game_object")

	return system, gui_main_command.create_system(system)
end


---@param entity entity.gui_main
function M:onAdd(entity)
	entity.gui_main.bindings = bindings.get(entity.game_object.root) --[[@as gui.main.bindings]]
	local gui_bindings = entity.gui_main.bindings

	entity.gui_main.current_level_index = 1

	gui_bindings.on_left:subscribe(function()
		local prev_index = entity.gui_main.current_level_index - 1
		if prev_index < 1 then
			prev_index = #LEVELS
		end
		entity.gui_main.current_level_index = prev_index
		self:spawn_world(LEVELS[prev_index])
	end)

	gui_bindings.on_right:subscribe(function()
		local next_index = entity.gui_main.current_level_index + 1
		if next_index > #LEVELS then
			next_index = 1
		end
		entity.gui_main.current_level_index = next_index
		self:spawn_world(LEVELS[next_index])
	end)

	self:spawn_world(LEVELS[entity.gui_main.current_level_index])
end


function M:spawn_world(world_id)
	---@type component.level_loader_command
	local level_loader_command = {
		world_id = world_id,
		slot_id = "level"
	}
	self.world:addEntity({ level_loader_command = level_loader_command })
end


return M
