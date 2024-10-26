---@return table<string, entity>
return {
	["enemy"] = {
		color = {
			hex_color = "612C2C",
			sprite_url = "/root#sprite"
		},
		game_object = {
			factory_url = "/spawner/spawner#enemy",
			object = {
				["root"] = true,
				["health"] = true
			}
		},
		health = {
			health = 20
		},
		health_circle_visual = {},
		panthera = {
			animation_path = "/resources/animations/health_visual_circle.json"
		},
		physics = {},
		play_fx_on_remove = {
			fx_url = "explosion_enemy"
		},
		target = true
	},
	["enemy_rectangle"] = {
		target = true,
		parent_prefab_id = "enemy",
		game_object = {
			factory_url = "/spawner/spawner#enemy_rectangle"
		},
		health = {
			health = 400
		},
		panthera = {
			animation_path = "/resources/animations/health_visual_rectangle.json"
		}
	}
}