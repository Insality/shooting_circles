---@return table<string, entity>
return {
	["enemy"] = {
		color = {
			color = "612C2C",
			sprites = "/root#sprite"
		},
		game_object = {
			factory_url = "/entities#enemy",
			object_scheme = {
				["/root"] = true,
				["/health"] = true
			}
		},
		health = {
			max_health = 20,
			remove_on_death = true
		},
		health_circle_visual = {},
		collision = {},
		panthera = {
			animation_path = require("entity.enemy.health_visual_circle_panthera")
		},
		physics = {},
		play_fx_on_remove = {
			fx_url = "explosion_enemy"
		},
		target = true
	},
	["enemy_rectangle"] = {
		parent_prefab_id = "enemy",
		game_object = {
			factory_url = "/entities#enemy_rectangle"
		},
		health = {
			max_health = 400
		},
		panthera = {
			animation_path = require("entity.enemy.health_visual_rectangle_panthera")
		}
	}
}
