local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

local empty_state = {}
local clone_state = function(state)
	---@class fragments.game_gui
	---@field shoot_count number
	---@field patrons number

	state = state or empty_state
	return {
		shoot_count = state.shoot_count or 0,
		patrons = state.patrons or 6,
	}
end

function M.register_fragments()
	---@class fragments
	---@field game_gui evolved.id

	fragments.game_gui = evolved.builder()
		:name("game_gui")
		:default(clone_state())
		:duplicate(clone_state)
		:spawn()
end


function M.create_system()
	return evolved.builder()
		:name("system_game_gui")
		:set(fragments.system)
		:include(fragments.game_gui, fragments.druid_widget)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local widgets, game_guis = chunk:components(fragments.druid_widget, fragments.game_gui)

	local shooter_controller = evolved.get(fragments.selected_shooter_controller, fragments.selected_shooter_controller) --[[@as fragments.shooter_controller ]]

	for index = 1, entity_count do
		local game_gui = game_guis[index] ---@type fragments.game_gui
		local widget = widgets[index] ---@type widget.game_gui

		if game_gui.shoot_count ~= shooter_controller.shoot_count then
			game_gui.shoot_count = shooter_controller.shoot_count

			widget:play_hit()
			widget:set_shoot_count(shooter_controller.shoot_count)
		end
	end
end


return M
