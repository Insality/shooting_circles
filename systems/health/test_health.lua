local decore = require("decore.decore")

---@param world world
---@param component_name string
---@return entity|nil
local function get_entity_with_component(world, component_name)
	local entities = world.entities
	for _, entity in ipairs(entities) do
		if entity[component_name] then
			return entity
		end
	end

	-- We trying to look also in entities which will be changed in this frame
	local entities2c = world.entitiesToChange
	for _, entity in ipairs(entities2c) do
		if entity[component_name] then
			return entity
		end
	end

	return nil
end


return function()
	local system_health

	describe("System Health", function()
		---@type world
		local world
		before(function()
			system_health = require("systems.health.health")

			world = decore.world()
			world:add(system_health.create_system())
		end)

		it("Should set current health", function()
			---@type entity
			local entity = { health = { health = 100 } }
			world:add(entity)
			world:update(0)

			assert(entity.health.current_health == 100)
		end)

		it("Should catch health command", function()
			---@type entity
			local entity = { health = { health = 100 } }
			world:addEntity(entity)
			world:refresh()

			world.health_command:apply_damage(entity, 10)
			assert(entity.health.current_health == 90)
		end)

		it("Should produce health_event", function()
			---@type entity
			local entity = { health = { health = 100 } }
			world:addEntity(entity)
			world:refresh()

			world.health_command:apply_damage(entity, 10)

			world.queue:stash_to_events()
			assert(world.queue:get_events("health_event"))
			assert(#world.queue:get_events("health_event") == 1)

			world.queue:process("health_event", function(event)
				assert(event.entity == entity)
				assert(event.damage == 10)
			end)
		end)
	end)
end
