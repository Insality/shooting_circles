---@class entities
local M = {
	["player"] = require("entity.player.player"),
	["enemy"] = require("entity.enemy.enemy"),
	["bullet"] = require("entity.bullet.bullet"),
	["explosion"] = require("entity.explosion.explosion"),
	["damage_number"] = require("entity.damage_number.damage_number"),
	["level1"] = require("entity.levels.level1"),

	["game_gui"] = require("entity.game_gui.entity_game_gui"),
}


-- Prehash to able use the entity id from .script properties
local prehashed_keys = {}
for key, value in pairs(M) do
	prehashed_keys[key] = value
	prehashed_keys[hash(key)] = value
end
M = prehashed_keys

return M
