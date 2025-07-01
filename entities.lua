---@class entities
local M = {
	["player"] = require("entity.player.player"),
	["enemy"] = require("entity.enemy.enemy"),
	["bullet"] = require("entity.bullet.bullet"),
	["explosion"] = require("entity.explosion.explosion"),
	["damage_number"] = require("entity.damage_number.damage_number"),
	--[hash("enemy")] = require("entity.enemy.enemy"),
	["level1"] = require("entity.levels.level1"),

	["game_gui"] = require("entity.game_gui.entity_game_gui"),
}


-- Prehash to able use the entity id from .script properties
for key, value in pairs(M) do
	M[hash(key)] = value
end

return M
