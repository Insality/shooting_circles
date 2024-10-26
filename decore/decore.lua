local queue = require("decore.queue")
local decore_data = require("decore.decore_data")
local decore_internal = require("decore.decore_internal")

local system_queue = require("decore.system.queue")

local TYPE_TABLE = "table"
local IS_PREHASH_ENTITIES_ID = sys.get_config_int("decore.is_prehash", 0) == 1

---@class world
---@field queue queue

---@class decore
---@field ecs tiny_ecs
local M = {
	ecs = require("decore.ecs"),
}


function M.init()
	M.register_components({
		pack_id = "decore",
		components = {
			id = "",
			prefab_id = false,
			pack_id = false,
		}
	})
end


---Create a new world instance
---@return world
function M.world()
	---@type world
	local world = M.ecs.world()
	world.queue = queue.create()

	-- Always included systems
	world:addSystem(system_queue.create_system())

	return world
end


---@generic T
---@param system_module T
---@param system_id string
---@return T
function M.system(system_module, system_id)
	local system = setmetatable(M.ecs.system(), { __index = system_module })
	system.id = system_id

	return system
end


---@generic T
---@param system_module T
---@param system_id string
---@return T
function M.processing_system(system_module, system_id)
	local system = setmetatable(M.ecs.processingSystem(), { __index = system_module })
	system.id = system_id

	return system
end


---@generic T
---@param system_module T
---@param system_id string
---@return T
function M.sorted_system(system_module, system_id)
	local system = setmetatable(M.ecs.sortedSystem(), { __index = system_module })
	system.id = system_id

	return system
end


---@generic T
---@param system_module T
---@param system_id string
---@return T
function M.sorted_processing_system(system_module, system_id)
	local system = setmetatable(M.ecs.sortedProcessingSystem(), { __index = system_module })
	system.id = system_id

	return system
end


---Add input event to the world queue
---@param world world
---@param action_id hash
---@param action action
---@return boolean
function M.on_input(world, action_id, action)
	action.action_id = action_id
	world.queue:push("input_event", action)
	return false
end


---Register entity to decore entities
---@param entity_id string
---@param entity_data table
---@param pack_id string|nil @default "decore"
function M.register_entity(entity_id, entity_data, pack_id)
	pack_id = pack_id or "decore"

	if not decore_data.entities[pack_id] then
		decore_data.entities[pack_id] = {}
		table.insert(decore_data.entities_order, pack_id)
	end

	decore_data.entities[pack_id][entity_id] = entity_data or {}

	entity_data.prefab_id = entity_id
	entity_data.pack_id = pack_id
end


---Add entities pack to decore entities
---If entities pack with same id already loaded, do nothing.
---If the same id is used in different packs, the last one will be used in M.create_entity
---@param pack_id string
---@param entities table<string, table>
---@return boolean
function M.register_entities(pack_id, entities)
	if IS_PREHASH_ENTITIES_ID then
		for prefab_id, entity_data in pairs(entities) do
			entities[hash(prefab_id)] = entity_data
		end
	end

	-- Merge entities, if conflict - throw error
	for prefab_id, entity_data in pairs(entities) do
		M.register_entity(prefab_id, entity_data, pack_id)
	end

	decore_internal.logger:debug("Load entities pack id", pack_id)
	return true
end


---Unload entities pack from decore entities
---@param pack_id string
function M.unregister_entities(pack_id)
	if not decore_data.entities[pack_id] then
		decore_internal.logger:warn("No entities pack with id to unload", pack_id)
		return
	end

	decore_data.entities[pack_id] = nil
	decore_internal.remove_by_value(decore_data.entities_order, pack_id)

	decore_internal.logger:debug("Unload entities pack id", pack_id)
end


---Create entity instance from prefab
---@param prefab_id string|hash
---@param pack_id string|nil
---@param data table|nil @additional data to merge with prefab
---@return entity
function M.create_entity(prefab_id, pack_id, data)
	for index = #decore_data.entities_order, 1, -1 do
		local check_pack_id = decore_data.entities_order[index]
		local entities_pack = decore_data.entities[check_pack_id]

		local prefab = entities_pack[prefab_id]
		if prefab and (not pack_id or pack_id == check_pack_id) then
			local entity

			-- Use parent entity as template
			if prefab.parent_prefab_id then
				local parent_entity = M.create_entity(prefab.parent_prefab_id)
				if parent_entity then
					entity = parent_entity
				end
			end
			entity = entity or {}

			for component_id, prefab_data in pairs(prefab) do
				M.apply_component(entity, component_id, prefab_data)
			end

			if data then
				M.apply_components(entity, data)
			end

			return entity
		end
	end

	decore_internal.logger:warn("No entity with id", {
		prefab_id = prefab_id,
		pack_id = pack_id,
	})

	local entity = {}
	if data then
		M.apply_components(entity, data)
	end

	return entity
end


---Register component to decore components
---@param component_id string
---@param component_data any
---@param pack_id string|nil @default "decore"
function M.register_component(component_id, component_data, pack_id)
	pack_id = pack_id or "decore"

	if not decore_data.components[pack_id] then
		decore_data.components[pack_id] = {}
		table.insert(decore_data.components_order, pack_id)
	end

	decore_data.components[pack_id][component_id] = component_data or {}
end


---Register components pack to decore components
---@param components_data_or_path decore.components_pack_data|string @if string, load data from JSON file from custom resources
---@return boolean
function M.register_components(components_data_or_path)
	local components_pack_data = decore_internal.load_config(components_data_or_path)
	if not components_pack_data then
		return false
	end

	local pack_id = components_pack_data.pack_id

	if decore_data.components[pack_id] then
		decore_internal.logger:info("The components pack with the same id already loaded", pack_id)
		return false
	end

	for component_id, component_data in pairs(components_pack_data.components) do
		M.register_component(component_id, component_data, pack_id)
	end

	decore_internal.logger:debug("Load components pack id", pack_id)
	return true
end


---Unload components pack from decore components
---@param pack_id string
function M.unregister_components(pack_id)
	if not decore_data.components[pack_id] then
		decore_internal.logger:warn("No components pack with id to unload", pack_id)
		return
	end

	decore_data.components[pack_id] = nil
	decore_internal.remove_by_value(decore_data.components_order, pack_id)

	decore_internal.logger:debug("Unload components pack id", pack_id)
end


---Return new component instance from prefab
---@param component_id string
---@param component_pack_id string|nil @if nil, use first found from latest loaded pack
---@return any|nil @return nil if component not found
function M.create_component(component_id, component_pack_id)
	for index = #decore_data.components_order, 1, -1 do
		local pack_id = decore_data.components_order[index]
		local components_pack = decore_data.components[pack_id]
		local prefab = components_pack[component_id]

		if prefab ~= nil and (not component_pack_id or component_pack_id == pack_id) then
			if type(prefab) == TYPE_TABLE then
				return sys.deserialize(sys.serialize(prefab))
			else
				return prefab
			end
		end
	end

	decore_internal.logger:error("No component_id in components data", {
		component_id = component_id,
		component_pack_id = component_pack_id
	})
	decore_internal.logger:debug("Traceback", debug.traceback())

	return nil
end


---Add component to entity.
---If component not exists, it will be created with default values
---If component already exists, it will be merged with the new data
---To refresh system filters, call world:addEntity(entity) after this function
---@param entity entity
---@param component_id string
---@param component_data any|nil @if nil, create component with default values
---@return entity
function M.apply_component(entity, component_id, component_data)
	component_data = component_data or {}

	if not entity[component_id] then
		-- Create default component with default values if not exists
		entity[component_id] = M.create_component(component_id)
	end

	if type(component_data) == TYPE_TABLE then
		decore_internal.merge_tables(entity[component_id], component_data)
	else
		entity[component_id] = component_data
	end

	return entity
end


---Add components to entity
---To refresh system filters, call world:addEntity(entity) after this function
---@param entity entity
---@param components table<string, any>
---@return entity
function M.apply_components(entity, components)
	for component_id, component_data in pairs(components) do
		M.apply_component(entity, component_id, component_data)
	end

	return entity
end


---@param world_id string
---@param world_data decore.world.instance
---@param pack_id string|nil @default "decore"
function M.register_world(world_id, world_data, pack_id)
	pack_id = pack_id or "decore"

	if not decore_data.worlds[pack_id] then
		decore_data.worlds[pack_id] = {}
		table.insert(decore_data.worlds_order, pack_id)
	end

	decore_data.worlds[pack_id][world_id] = world_data or {}
end


---@param world_data_or_path decore.worlds_pack_data|string
---@return boolean, string|nil
function M.register_worlds(world_data_or_path)
	local world_pack_data = decore_internal.load_config(world_data_or_path)
	if not world_pack_data then
		return false
	end

	local pack_id = world_pack_data.pack_id
	for world_id, world_data in pairs(world_pack_data.worlds) do
		M.register_world(world_id, world_data, pack_id)
	end

	decore_internal.logger:debug("Load worlds pack id", pack_id)

	return true
end


---@param pack_id string
function M.unregister_worlds(pack_id)
	if not decore_data.worlds[pack_id] then
		decore_internal.logger:warn("No worlds pack with id to unload", pack_id)
		return
	end

	decore_data.worlds[pack_id] = nil
	decore_internal.remove_by_value(decore_data.worlds_order, pack_id)

	decore_internal.logger:debug("Unload worlds pack id", pack_id)
end


---Create entity instances from world prefab
---@param world_id string
---@param world_pack_id string|nil @if nil, use first found from latest loaded pack
---@return entity[]|nil
function M.create_world(world_id, world_pack_id)
	for index = #decore_data.worlds_order, 1, -1 do
		local pack_id = decore_data.worlds_order[index]
		local worlds_pack = decore_data.worlds[pack_id]

		local prefab = worlds_pack[world_id]
		if worlds_pack[world_id] and (not world_pack_id or (world_pack_id == pack_id)) then
			local entities = {}

			-- Create all template entities
			if prefab.included_worlds then
				for world_index = 1, #prefab.included_worlds do
					local world_instance = prefab.included_worlds[world_index]
					local world_entities = M.create_world(world_instance.world_id, world_instance.pack_id)
					if world_entities then
						for _, entity in ipairs(world_entities) do
							table.insert(entities, entity)
						end
					end
				end
			end

			if prefab.entities then
				for entity_index = 1, #prefab.entities do
					local entity_info = prefab.entities[entity_index]

					local entity
					if entity_info.prefab_id and entity_info.prefab_id ~= "" then
						-- Create entity from decore entities
						entity = M.create_entity(entity_info.prefab_id, entity_info.pack_id)
					else
						-- Create empty entity
						entity = {}
					end

					if entity then
						local components = entity_info.components
						if components then
							M.apply_components(entity, components)
						end

						table.insert(entities, entity)
					end

					-- Entities can spawn a world
					-- TODO: Add parent relations
					local world_prefab_id = entity.world_prefab_id
					if world_prefab_id then
						local child_entities = M.create_world(world_prefab_id)
						if child_entities then
							for _, child_entity in ipairs(child_entities) do
								child_entity.tiled_id = entity.tiled_id .. ":" .. child_entity.tiled_id
								child_entity.transform.position_x = child_entity.transform.position_x + entity.transform.position_x - entity.transform.size_x/2
								child_entity.transform.position_y = child_entity.transform.position_y + entity.transform.position_y - entity.transform.size_y/2

								table.insert(entities, child_entity)
							end
						else
							decore_internal.logger:error("Failed to create world prefab", {
								world_prefab_id = world_prefab_id,
							})
						end
					end
				end
			end

			return entities
		end
	end

	decore_internal.logger:error("No world with id", {
		world_id = world_id,
		world_pack_id = world_pack_id,
	})

	return nil
end


---@param world world
---@param id number
---@return entity|nil
function M.get_entity_by_id(world, id)
	return M.find_entities_by_component_value(world, "id", id)[1]
end


---Return all entities with component_id equal to component_value or all entities with component_id if component_value is nil.
---It looks for component_id in entity and entityToChange tables
---@param world world
---@param component_id string
---@param component_value any|nil @if nil, return all entities with component_id
---@return entity[]
function M.find_entities_by_component_value(world, component_id, component_value)
	local entities = {}

	for index = 1, #world.entities do
		local entity = world.entities[index]
		if entity[component_id] and (not component_value or entity[component_id] == component_value) then
			table.insert(entities, entity)
		end
	end

	for index = 1, #world.entitiesToChange do
		local entity = world.entitiesToChange[index]
		if entity[component_id] and (not component_value or entity[component_id] == component_value) then
			table.insert(entities, entity)
		end
	end

	return entities
end


---Return if entity is alive in the system
---@param system system
---@param entity entity
function M.is_alive(system, entity)
	return system.indices[entity] ~= nil
end


---Unload all entities, components and worlds
---Useful for tests
---@return nil
function M.unload_all()
	decore_data.entities = {}
	decore_data.entities_order = {}

	decore_data.components = {}
	decore_data.components_order = {}

	decore_data.worlds = {}
	decore_data.worlds_order = {}
end


---Log all loaded packs for entities, components and worlds
function M.print_loaded_packs_debug_info()
	local logger = decore_internal.logger

	logger:debug("Entities packs:")
	for _, pack_id in ipairs(decore_data.entities_order) do
		logger:debug(" - " .. pack_id)
		for prefab_id, _ in pairs(decore_data.entities[pack_id]) do
			logger:debug("   - " .. prefab_id)
		end
	end

	logger:debug("Components packs:")
	for _, pack_id in ipairs(decore_data.components_order) do
		logger:debug(" - " .. pack_id)
		for component_id, _ in pairs(decore_data.components[pack_id]) do
			logger:debug("   - " .. component_id)
		end
	end

	logger:debug("Worlds packs:")
	for _, pack_id in ipairs(decore_data.worlds_order) do
		logger:debug(" - " .. pack_id)
		for world_id, _ in pairs(decore_data.worlds[pack_id]) do
			logger:debug("   - " .. world_id)
		end
	end
end


---Call command from params array. Example: {"system_name", "function_name", "arg1", "arg2", ...}
---@param world world
---@param command any[] Example: [ "debug_command", "toggle_profiler", true ],
function M.call_command(world, command)
	local system_command = world[command[1]]
	if not system_command then
		print("System not found: " .. command[1])
		return
	end

	local func = command[2]
	if not system_command[func] then
		print("Function not found: " .. func)
		return
	end

	local args = {}
	for i = 3, #command do
		table.insert(args, command[i])
	end

	system_command[func](system_command, unpack(args))
end


---@param logger_instance decore.logger|table|nil
function M.set_logger(logger_instance)
	decore_internal.logger = logger_instance or decore_internal.empty_logger
end


---@param name string
---@param level string|nil
---@return decore.logger
function M.get_logger(name, level)
	return setmetatable({ name = name, level = level }, { __index = decore_internal.logger })
end


return M
