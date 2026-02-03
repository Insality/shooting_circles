local M = {}

function M.get_systems()
	return unpack({
		require("system.camera.camera_system").create(),
		require("system.window_event.system_window_event").create_system(),
		require("system.transform.transform_system").create(),
		-- why here order matter
		require("system.play_fx_on_remove.play_fx_on_remove").create_system(),
		require("system.game_object.game_object_system").create(),
		require("system.input.input_system").create(),
		require("system.panthera.panthera_system").create(),
		require("system.physics.system_physics").create_system(),
		require("system.remove_with_delay.system_remove_with_delay").create_system(),
		require("system.collision.system_collision").create_system(),
		require("system.health.health_system").create(),

		require("system.color.color_system").create_system(),
		require("system.acceleration.system_acceleration").create_system(),
		require("system.movement_controller.movement_controller").create_system(),
		require("system.shooter_controller.shooter_controller").create_system(),
		require("system.collision.on_collision.on_collision_remove").create_system(),
		require("system.collision.on_collision.on_collision_explosion").create_system(),
		require("system.collision.on_collision.on_collision_damage").create_system(),
		require("system.damage_number.damage_number").create_system(),
		require("system.health_circle_visual.health_circle_visual").create_system(),
		require("system.target_tracker.target_tracker").create_system(),
		--require("system.target_tracker.on_target_count_command.on_target_count_command").create_system(),
		require("gui.game.system_game_gui").create_system()
	})
end

return M
