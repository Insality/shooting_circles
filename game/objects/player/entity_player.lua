---@diagnostic disable: missing-fields
---@type entity
return {
	color = {
		color = "#95C8E2",
		sprites = "/root#sprite"
	},
	game_object = {
		factory_url = "/spawner/spawner#player",
		object_scheme = {
			["/root"] = true,
		}
	},
	movement_controller = {
		speed = 4000
	},
	physics = {},
	shooter_controller = {
		bullet_prefab_id = "bullet_pistol",
		bullet_speed = 3000,
		burst_count = 8,
		burst_rate = 0.5,
		damage = 1,
		fire_rate = 0.05,
		is_auto_shoot = true,
		spread = 32,
		spread_angle = 14
	}
}
