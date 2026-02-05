local M = {}

function M.merge(entities, dictionary)
	for k, v in pairs(dictionary) do
		entities[k] = v
	end
end

function M.get_entities()
	local entities = {
		["player"] = require("entity.player.entity_player"),
		["camera"] = require("system.camera.camera_entity"),
		["game_gui"] = require("entity.game_gui.game_gui_entity"),
		["damage_number"] = require("system.damage_number.damage_number_entity"),
		["explosion"] = require("entity.explosion.entity_explosion"),
	}

	M.merge(entities, require("entity.enemy.entities_enemies"))
	M.merge(entities, require("system.shooter_controller.entities_bullets"))

	return entities
end


return M
