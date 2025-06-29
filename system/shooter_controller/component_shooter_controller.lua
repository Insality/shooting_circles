local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field shooter_controller evolved.id

	components.shooter_controller = evolved.builder():name("shooter_controller"):spawn()
end


return M
