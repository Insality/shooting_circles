local M = {}


---Call on loader step of the game
function M.register_fragments()
	require("system.transform.transform").register_fragments()
	require("system.game_objects.parent_entity").register_fragments()
	require("system.game_objects.factory_object").register_fragments()
	require("system.game_objects.collectionfactory_object").register_fragments()
	require("system.game_objects.sync_game_object_position").register_fragments()
	require("system.physics.physics_movement_controller").register_fragments()
	require("system.color.color").register_fragments()
	require("system.panthera.panthera").register_fragments()
	require("system.velocity.velocity").register_fragments()
	require("system.camera.camera").register_fragments()
	require("system.physics.physics").register_fragments()
	require("system.physics.collision").register_fragments()
	require("system.lifetime.lifetime").register_fragments()
	require("system.health.health").register_fragments()
	require("system.play_particlefx.play_particlefx").register_fragments()
	require("system.shooter_controller.fragment_shooter_controller").register_fragments()
	require("system.druid_widget.druid_widget").register_fragments()

	require("entity.damage_number.system_damage_number").register_fragments()
	require("entity.enemy.enemy_visual").register_fragments()
	require("entity.game_gui.system_game_gui").register_fragments()

	--require("system.velocity").register_fragments()
	--require("system.velocity_angle").register_fragments()
	--require("system.movement_controller").register_fragments()
	--require("system.camera").register_fragments()
end


---@return table<string, evolved.id>
function M.get_systems()
	return {
		require("system.debug.debug").create_system(),
		require("system.game_objects.factory_object").create_system(),
		require("system.game_objects.collectionfactory_object").create_system(),
		require("system.physics.physics_movement_controller").create_system(),
		require("system.shooter_controller.system_shooter_controller").create_system(),
		require("system.panthera.panthera").create_system(),
		require("system.camera.camera").create_system(),
		require("system.color.color").create_system(),
		require("system.velocity.velocity").create_system(),
		require("system.health.health").create_system(),
		require("system.lifetime.lifetime").create_system(),
		require("system.play_particlefx.play_particlefx").create_system(),

		require("entity.damage_number.system_damage_number").create_system(),
		require("entity.enemy.enemy_visual").create_system(),

		require("system.game_objects.sync_game_object_position").create_system(),

		require("system.druid_widget.druid_widget").create_system(),

		require("entity.game_gui.system_game_gui").create_system(),
		--require("system.velocity").create_system(),
		--require("system.velocity_angle").create_system(),
		--require("system.movement_controller").create_system(),
		--require("system.camera").create_system(),
	}
end


---@return table<string, evolved.id>
function M.get_systems_fixed()
	return {
		require("system.physics.physics").create_system(),
		require("system.physics.collision").create_system(),
	}
end

return M
