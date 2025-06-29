---@class entities
local M = {
	--[hash("player")] = require("entities.player.player"),
	--[hash("enemy")] = require("entities.enemy.enemy"),
	["level1"] = require("entities.levels.level1"),
}


-- Prehash to able use the entity id from .script properties
for key, value in pairs(M) do
	M[hash(key)] = value
end

return M
