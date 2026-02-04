local decore = require("decore.decore")

local command_game_manager = require("system.game_manager.game_manager_command")

---@class system.game_manager: system
local M = {}


---@return system.game_manager
function M.create()
	return decore.system(M, "game_manager")
end


function M:onAddToWorld()
	self.world.game_manager = command_game_manager.create(self)
end


function M:start()
	self.world.game_manager:start()
end


return M
