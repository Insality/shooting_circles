local M = {}


function M.register_components()
	require("system.transform.transform").register_components()
	require("system.game_objects.factory_object").register_components()
	require("system.game_objects.collectionfactory_object").register_components()
	require("system.game_objects.sync_game_object_position").register_components()
	require("system.physics.physics_movement_controller").register_components()
	require("system.color.color").register_components()
	require("system.panthera.panthera").register_components()
	require("system.velocity.velocity").register_components()
	require("system.camera.camera").register_components()
	require("system.physics.physics").register_components()
	require("system.physics.collision").register_components()
	require("system.lifetime.lifetime").register_components()
	require("system.health.health").register_components()
	require("system.play_particlefx.play_particlefx").register_components()
	require("system.shooter_controller.component_shooter_controller").register_components()

	require("entities.damage_number.system_damage_number").register_components()
	require("entities.enemy.enemy_visual").register_components()

	--require("system.velocity").register_components()
	--require("system.velocity_angle").register_components()
	--require("system.movement_controller").register_components()
	--require("system.camera").register_components()
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

		require("entities.damage_number.system_damage_number").create_system(),
		require("entities.enemy.enemy_visual").create_system(),

		require("system.game_objects.sync_game_object_position").create_system(),
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
