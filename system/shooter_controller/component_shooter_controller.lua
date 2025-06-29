local evolved = require("evolved")
local components = require("components")

local M = {}

---@class components.shooter_controller
---@field prefab evolved.id
---@field cooldown number
---@field current_cooldown number

local function clone_state(state)
	return {
		prefab = state.prefab,
		cooldown = state.cooldown,
		current_cooldown = state.current_cooldown,
		spread_euler = 5
	}
end


function M.register_components()
	---@class components
	---@field shooter_controller evolved.id

	components.shooter_controller = evolved.builder():name("shooter_controller"):default({
		prefab = nil,
		cooldown = 0.1,
		current_cooldown = 0,
		spread_euler = 5,
	}):duplicate(clone_state):spawn()
end


return M
