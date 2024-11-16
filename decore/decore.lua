local event_bus = require("decore.internal.event_bus")
local decore_data = require("decore.internal.decore_data")
local decore_internal = require("decore.internal.decore_internal")
local system_event_bus = require("decore.internal.system_event_bus")

local events = require("event.events")


local EMPTY_HASH = hash("")
local TYPE_TABLE = "table"
local IS_PREHASH_ENTITIES_ID = sys.get_config_int("decore.is_prehash", 0) == 1

---@class world
---@field event_bus decore.event_bus

---@class decore
local M = {}
M.ecs = require("decore.ecs")


---Create a new world instance
---@return world
function M.world(...)
	---@type world
	local world = M.ecs.world()
	world.event_bus = event_bus.create()

	-- To make it works with entity.script to allows make entities in Defold editor via collections
	events.subscribe("decore.create_entity", world.addEntity, world)

	-- Always included systems
	world:addSystem(system_event_bus.create_system())

	-- Add systems passed to world constructor
	world:add(...)

	return world
end


---@generic T
---@param system_module T The module with system functions
---@param system_id string The system id
---@param require_all_filters string|string[]|nil The required components. Example: {"transform", "game_object"} or "transform"
---@return T
function M.system(system_module, system_id, require_all_filters)
	return decore_internal.create_system(M.ecs.system(), system_module, system_id, require_all_filters)
end


---@generic T
---@param system_module T The module with system functions
---@param system_id string The system id
---@param require_all_filters string|string[]|nil The required components. Example: {"transform", "game_object"} or "transform"
---@return T
function M.processing_system(system_module, system_id, require_all_filters)
	return decore_internal.create_system(M.ecs.processingSystem(), system_module, system_id, require_all_filters)
end


---@generic T
---@param system_module T The module with system functions
---@param system_id string The system id
---@param require_all_filters string|string[]|nil The required components. Example: {"transform", "game_object"} or "transform"
---@return T
function M.sorted_system(system_module, system_id, require_all_filters)
	return decore_internal.create_system(M.ecs.sortedSystem(), system_module, system_id, require_all_filters)
end


---@generic T
---@param system_module T The module with system functions
---@param system_id string The system id
---@param require_all_filters string|string[]|nil The required components. Example: {"transform", "game_object"} or "transform"
---@return T
function M.sorted_processing_system(system_module, system_id, require_all_filters)
	return decore_internal.create_system(M.ecs.sortedProcessingSystem(), system_module, system_id, require_all_filters)
end


---Add input event to the world queue
---@param world world
---@param action_id hash
---@param action action
---@return boolean
function M.on_input(world, action_id, action)
	return world.command_input:on_input(action_id, action)
end


function M.on_message(world, message_id, message, sender)
	world.event_bus:trigger("on_message", {
		message_id = message_id,
		message = message,
		sender = sender,
	})
end


function M.final(world)
	events.unsubscribe("decore.create_entity", world.addEntity, world)
	world:clearEntities()
	world:clearSystems()
end


---Register entity to decore entities
---@param entity_id string
---@param entity_data table
---@param pack_id string|nil default "decore"
function M.register_entity(entity_id, entity_data, pack_id)
	pack_id = pack_id or "decore"

	if not decore_data.entities[pack_id] then
		decore_data.entities[pack_id] = {}
		table.insert(decore_data.entities_order, pack_id)
	end

	decore_data.entities[pack_id][entity_id] = entity_data or {}
	if IS_PREHASH_ENTITIES_ID then
		local hashed_id = hash(entity_id)
		decore_data.entities[pack_id][hashed_id] = entity_data or decore_data.entities[pack_id][entity_id]
	end

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


function M.get_entity(prefab_id, pack_id)
	for index = #decore_data.entities_order, 1, -1 do
		local check_pack_id = decore_data.entities_order[index]
		local entities_pack = decore_data.entities[check_pack_id]

		local entity = entities_pack[prefab_id]
		if entity and (not pack_id or pack_id == check_pack_id) then
			return entity
		end
	end

	return nil
end


---Create entity instance from prefab
---@param prefab_id string|hash|nil
---@param pack_id string|nil
---@param data table|nil additional data to merge with prefab
---@return entity
function M.create_entity(prefab_id, pack_id, data)
	if prefab_id == EMPTY_HASH and not data then
		decore_internal.logger:error("The entity_id is empty", {
			prefab_id = prefab_id,
			pack_id = pack_id,
		})
		return {}
	end

	local prefab = prefab_id and M.get_entity(prefab_id, pack_id)

	if not prefab then
		local entity = {}
		if data then
			M.apply_components(entity, data)
		end

		return entity
	end

	local entity
	-- Use parent entity as template
	if prefab.parent_prefab_id then
		local parent_entity = M.create_entity(prefab.parent_prefab_id)
		if parent_entity then
			entity = parent_entity
		end
	end
	entity = entity or {}

	M.apply_components(entity, prefab)
	if data then
		M.apply_components(entity, data)
	end

	return entity
end


---Register component to decore components
---@param component_id string
---@param component_data any
---@param pack_id string|nil default "decore"
function M.register_component(component_id, component_data, pack_id)
	pack_id = pack_id or "decore"

	if not decore_data.components[pack_id] then
		decore_data.components[pack_id] = {}
		table.insert(decore_data.components_order, pack_id)
	end

	decore_data.components[pack_id][component_id] = component_data or {}
end


---Register components pack to decore components
---@param components_data_or_path decore.components_pack_data|string if string, load data from JSON file from custom resources
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
---@param component_pack_id string|nil if nil, use first found from latest loaded pack
---@return any|nil return nil if component not found
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
---@param component_data any|nil if nil, create component with default values
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
---@param pack_id string|nil default "decore"
function M.register_world(world_id, world_data, pack_id)
	pack_id = pack_id or "decore"

	if not decore_data.worlds[pack_id] then
		decore_data.worlds[pack_id] = {}
		table.insert(decore_data.worlds_order, pack_id)
	end

	decore_data.worlds[pack_id][world_id] = world_data or {}
end


---@param worlds table<string, decore.world.instance>
---@param pack_id string
---@return boolean, string|nil
function M.register_worlds(worlds, pack_id)
	for world_id, world_data in pairs(worlds) do
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


function M.get_world(world_id, pack_id)
	for index = #decore_data.worlds_order, 1, -1 do
		local check_pack_id = decore_data.worlds_order[index]
		local worlds_pack = decore_data.worlds[check_pack_id]

		local world = worlds_pack[world_id]
		if world and (not pack_id or pack_id == check_pack_id) then
			return world
		end
	end

	return nil
end


---Create entity instances from world prefab
---@param world_id string
---@param world_pack_id string|nil if nil, use first found from latest loaded pack
---@return entity[]|nil
function M.create_world(world_id, world_pack_id)
	local world = M.get_world(world_id, world_pack_id)
	if not world then
		decore_internal.logger:error("No world with id", {
			world_id = world_id,
			pack_id = world_pack_id,
		})

		return nil
	end

	local entities = {}

	-- Create all template entities
	if world.included_worlds then
		for world_index = 1, #world.included_worlds do
			local world_instance = world.included_worlds[world_index]
			local world_entities = M.create_world(world_instance.world_id, world_instance.pack_id)
			if world_entities then
				for _, entity in ipairs(world_entities) do
					table.insert(entities, entity)
				end
			end
		end
	end

	if world.entities then
		for entity_index = 1, #world.entities do
			local entity_info = world.entities[entity_index]

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
---@param component_value any|nil if nil, return all entities with component_id
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
			if type(prefab_id) == "string" then
				logger:debug("   - " .. prefab_id)
			end
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



---@param command string Example: "system_name.function_name, arg1, arg2". Separators are : " ", "," and "\n" only
---@return any[]
function M.parse_command(command)
	-- Split the command string into a table. check numbers, remove newlines and spaces
	local command_table = decore_internal.split_by_several_separators(command, { " ", ",", "\n" })

	-- Trim the command table
	for i = 1, #command_table do
		command_table[i] = string.gsub(command_table[i], "%s+", "")
	end

	-- Checks types
	for i = 1, #command_table do
		-- Check number
		if tonumber(command_table[i]) then
			command_table[i] = tonumber(command_table[i])
		end
		-- Check boolean
		if command_table[i] == "true" then
			command_table[i] = true
		elseif command_table[i] == "false" then
			command_table[i] = false
		end
	end


	return command_table
end


---Call command from params array. Example: {"system_name", "function_name", "arg1", "arg2", ...}
---@param world world
---@param command any[] Example: [ "command_debug", "toggle_profiler", true ],
function M.call_command(world, command)
	if not command then
		decore_internal.logger:error("Command is nil")
		print(debug.traceback())
		return
	end

	local command_system = world[command[1]]
	if not command_system then
		decore_internal.logger:error("System not found", command[1])
		return
	end

	local func = command[2]
	if not command_system[func] then
		decore_internal.logger:error("Function not found", func)
		return
	end

	local args = {}
	for i = 3, #command do
		table.insert(args, command[i])
	end

	command_system[func](command_system, unpack(args))
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
