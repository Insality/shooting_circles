---@return table<string, entity> entities By prefab_id
return {
	["bullet_prototype"] = {
		transform = {},
		color = {
			hex_color = "95C8E2",
			sprite_url = "/root#sprite"
		},
		game_object = {
			factory_url = "/spawner/spawner#bullet",
			is_factory = true,
			object_scheme = {
				["root"] = true
			}
		},
		on_collision_damage = 10,
		on_collision_remove = true,
		physics = {},
		collision = true,
		remove_with_delay = 0.5
	},

	["bullet_explosion"] = {
		transform = {},
		game_object = {
			factory_url = "/spawner/spawner#bullet_explosion",
			is_factory = true
		},
		play_fx_on_remove = {
			fx_url = "explosion"
		},
		remove_with_delay = 0,
	},

	["bullet_sniper"] = {
		parent_prefab_id = "bullet_prototype",
		transform = {
			scale_x = 1.25,
			scale_y = 1.25
		},
		on_collision_explosion = {
			power = 50000,
			damage = 30,
			distance = 128
		},
		on_collision_damage = 30,
	},

	["bullet_arcade"] = {
		parent_prefab_id = "bullet_prototype",
		on_collision_damage = 50,
		remove_with_delay = 3,
		on_collision_remove = false
	},
	["bullet_arcade_explosion"] = {
		parent_prefab_id = "bullet_arcade",
		on_collision_explosion = {
			power = 10000,
			damage = 20,
			distance = 256
		},
		remove_with_delay = 1.5
	},
	["bullet_pistol"] = {
		parent_prefab_id = "bullet_prototype",
		on_collision_damage = 50,
		on_collision_remove = true,
		remove_with_delay = 0.7
	},
	["bullet_shotgun"] = {
		parent_prefab_id = "bullet_prototype",
		game_object = {
			factory_url = "/spawner/spawner#bullet_shotgun"
		},
		on_collision_damage = 40,
		remove_with_delay = 0.7,
	},
	["bullet_rocket"] = {
		transform = {},
		color = {
			hex_color = "CA8BD0",
			sprite_url = "/root#sprite"
		},
		game_object = {
			factory_url = "/spawner/spawner#rocket"
		},
		on_collision_damage = 100,
		on_collision_explosion = {
			power = 12000,
			damage = 50,
			distance = 250
		},
		acceleration = {
			value = 500
		},
		on_collision_remove = true,
		physics = {},
		collision = true,
		remove_with_delay = 2,
		play_fx_on_remove = {
			fx_url = "explosion_rocket"
		}
	},
	["bullet_rocket_small"] = {
		transform = {
			scale_x = 0.5,
			scale_y = 0.5
		},
		color = {
			hex_color = "CA8BD0",
			sprite_url = "/root#sprite"
		},
		game_object = {
			factory_url = "/spawner/spawner#rocket"
		},
		on_collision_damage = 20,
		on_collision_explosion = {
			power = 30000,
			damage = 50,
			distance = 128
		},
		acceleration = {
			value = 600
		},
		on_collision_remove = true,
		physics = {},
		collision = true,
		remove_with_delay = 2,
		play_fx_on_remove = {
			fx_url = "explosion_rocket"
		}
	},
	["bullet_pistol_explosion"] = {
		transform = {},
		color = {
			hex_color = "95C8E2",
			sprite_url = "/root#sprite"
		},
		game_object = {
			factory_url = "/spawner/spawner#bullet"
		},
		physics = {},
		collision = true,
		on_collision_remove = true,
		on_collision_damage = 10,
		on_collision_explosion = {
			power = 15000,
			damage = 30,
			distance = 256
		},
		remove_with_delay = 0.7,
	}
}