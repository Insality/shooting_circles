local decore = require("decore.decore")

return function()
	describe("System Health", function()
		local world ---@type world
		local system_health ---@type system.health

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
