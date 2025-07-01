local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

---@class fragments.shooter_controller
---@field prefab evolved.id
---@field cooldown number
---@field current_cooldown number
---@field spread_euler number
---@field shoot_count number

local empty_state = {}
local function clone_state(state)
	state = state or empty_state
	return {
		prefab = state.prefab or nil,
		cooldown = state.cooldown or 0.1,
		current_cooldown = state.current_cooldown or 0,
		spread_euler = state.spread_euler or 5,
		shoot_count = state.shoot_count or 0,
	}
end


function M.register_fragments()
	---@class fragments
	---@field shooter_controller evolved.id
	---@field selected_shooter_controller evolved.id

	fragments.selected_shooter_controller = evolved.builder():name("last_shooter_controller"):spawn()
	fragments.shooter_controller = evolved.builder()
		:name("shooter_controller")
		:default(clone_state)
		:duplicate(clone_state)
		:on_set(function(entity, fragment, component)
			-- Global state
			evolved.set(fragments.selected_shooter_controller, fragments.selected_shooter_controller, component)
		end)
		:spawn()
end


return M
