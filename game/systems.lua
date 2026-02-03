local M = {}

function M.get_systems()
	return unpack({
		require("system.camera.camera_system").create(),
		require("system.window_event.window_event_system").create(),
		require("system.transform.transform_system").create(),
		-- why here order matter
		require("system.play_fx_on_remove.play_fx_on_remove_system").create(),
		require("system.game_object.game_object_system").create(),
		require("system.input.input_system").create(),
		require("system.panthera.panthera_system").create(),
		require("system.physics.physics_system").create(),
		require("system.remove_with_delay.remove_with_delay_system").create(),
		require("system.collision.collision_system").create(),
		require("system.health.health_system").create(),

		require("system.color.color_system").create(),
		require("system.acceleration.acceleration_system").create(),
		require("system.movement_controller.movement_controller_system").create(),
		require("system.shooter_controller.shooter_controller_system").create(),
		require("system.collision.on_collision.on_collision_remove").create(),
		require("system.collision.on_collision.on_collision_explosion").create(),
		require("system.collision.on_collision.on_collision_damage").create(),
		require("system.damage_number.damage_number_system").create(),
		require("system.health_circle_visual.health_circle_visual_system").create(),
		require("system.target_tracker.target_tracker_system").create(),
		require("gui.game.system_game_gui").create()
	})
end

return M
