local M = {}


function M.register_components()
	require("system.transform").register_components()
	require("system.factory_object").register_components()
	require("system.collectionfactory_object").register_components()
	require("system.sync_game_object_position").register_components()
	require("system.camera").register_components()
	--require("system.color").register_components()
	--require("system.velocity").register_components()
	--require("system.velocity_angle").register_components()
	--require("system.movement_controller").register_components()
	--require("system.camera").register_components()
end


---@return table<string, evolved.id>
function M.get_systems()
	return {
		require("system.factory_object").create_system(),
		require("system.collectionfactory_object").create_system(),
		require("system.sync_game_object_position").create_system(),
		require("system.camera").create_system(),
		--require("system.color").create_system(),
		--require("system.velocity").create_system(),
		--require("system.velocity_angle").create_system(),
		--require("system.movement_controller").create_system(),
		--require("system.camera").create_system(),
	}
end

return M
