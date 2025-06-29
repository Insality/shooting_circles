---@class entities
local M = {
	["player"] = require("entities.player.player"),
	["enemy"] = require("entities.enemy.enemy"),
	["bullet"] = require("entities.bullet.bullet"),
	["explosion"] = require("entities.explosion.explosion"),
	["damage_number"] = require("entities.damage_number.damage_number"),
	--[hash("enemy")] = require("entities.enemy.enemy"),
	["level1"] = require("entities.levels.level1"),
}


-- Prehash to able use the entity id from .script properties
for key, value in pairs(M) do
	M[hash(key)] = value
end

return M
