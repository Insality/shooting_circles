local ecs = require("decore.ecs")

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
		local world = {}
		before(function()
			system_health = require("systems.health.health")

			world = ecs.world()
			world:add(system_health.create_system())
		end)

		it("Should set current health", function()
			---@type entity
			local entity = { health = { health = 100 } }
			world:add(entity)
			world:update()

			assert(entity.health.current_health == 100)
		end)

		it("Should catch health command", function()
			---@type entity
			local entity = { health = { health = 100 } }
			world:add(entity)
			world:update()

			world:addEntity({ health_command = { entity = entity, damage = 10 } })
			world:update()

			assert(entity.health.current_health == 90)
		end)

		it("Should produce health_event", function()
			---@type entity
			local entity = { health = { health = 100 } }
			world:add(entity)
			world:update()

			world:addEntity({ health_command = { entity = entity, damage = 10 } })
			world:update()

			local event_entity = get_entity_with_component(world, "health_event")
			assert(event_entity)
			assert(event_entity.health_event.entity == entity)
			assert(event_entity.health_event.damage == 10)
		end)
	end)
end
