local M = {}

function M.merge(entities, dictionary)
	for k, v in pairs(dictionary) do
		entities[k] = v
	end
end

function M.get_entities()
	local entities = {
		["player"] = require("game.objects.player.entity_player"),
		["camera"] = require("game.objects.entity_camera"),
		["game_gui"] = require("gui.game.entity_game_gui"),
		["damage_number"] = require("system.damage_number.damage_number_entity"),
		["explosion"] = require("game.objects.explosion.entity_explosion"),
	}

	M.merge(entities, require("game.objects.enemy.entities_enemies"))
	M.merge(entities, require("system.shooter_controller.entities_bullets"))

	return entities
end


return M
