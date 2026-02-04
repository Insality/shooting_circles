local decore = require("decore.decore")
local druid = require("druid.druid")

local command_game_gui = require("entity.game_gui.game_gui_command")

---@class entity
---@field game_gui component.game_gui|nil

---@class entity.game_gui: entity
---@field game_gui component.game_gui
---@field game_object component.game_object

---@class component.game_gui
---@field component entity.game_gui
---@field current_level_index number
decore.register_component("game_gui", {})

---@class system.game_gui: system
---@field entities entity.game_gui[]
local M = {}

local LEVELS = {
	"/worlds#level_barrage",
	"/worlds#level_sniper",
	"/worlds#level_rocket",
	"/worlds#level_arcade",
	"/worlds#level_minigun",
}


---@return system.game_gui
function M.create()
	local system = decore.system(M, "game_gui", { "game_gui", "game_object" })

	system.prev_level = nil

	return system
end


function M:onAddToWorld()
	self.world.command_game_gui = command_game_gui.create(self)
end


---@param entity entity.game_gui
function M:onAdd(entity)
	entity.game_gui.current_level_index = 2

	local component = entity.druid_widget.widget --[[@as entity.game_gui]]
	component.button_left.on_click:subscribe(function() self:on_click_button(entity, -1) end)
	component.button_right.on_click:subscribe(function() self:on_click_button(entity, 1) end)

	self:spawn_world(LEVELS[entity.game_gui.current_level_index])
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
	self:spawn_world(LEVELS[index])
end


function M:spawn_world(world_url)
	if self.prev_level then
		self.world:removeEntity(self.prev_level)
		self.prev_level = nil
	end

	local entity_load_scene = decore.create({
		transform = {},
		game_object = {
			factory_url = world_url
		}
	})

	self.world:addEntity(entity_load_scene)
	self.prev_level = entity_load_scene
end


return M
