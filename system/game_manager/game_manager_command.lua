local decore = require("decore.decore")

---@class world
---@field game_manager command.game_manager

---@class command.game_manager
---@field game_manager system.game_manager
---@field world world
local M = {}


---@param game_manager system.game_manager
---@return command.game_manager
function M.create(game_manager)
	return setmetatable({ game_manager = game_manager, world = game_manager.world }, { __index = M })
end


function M:start()
	self.world:addEntity(decore.create_prefab("game_gui"))
end


return M
