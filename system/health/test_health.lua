return function()
	describe("System Health", function()
		local decore = require("decore.decore")

		local world ---@type world
		local system_health ---@type system.health

		before(function()
			system_health = require("core.system.health.system_health")

			world = decore.world()
			world:add(system_health.create_system())
		end)

		it("Should set current health", function()
			local entity = world:add({ health = { health = 100 } })
			world:refresh()

			assert(entity.health.current_health == 100)
		end)

		it("Should catch health command", function()
			local entity = world:add({ health = { health = 100 } })
			world:refresh()

			world.command_health:apply_damage(entity, 10)
			assert(entity.health.current_health == 90)
		end)

		it("Should produce health_event", function()
			local entity = world:add({ health = { health = 100 } })
			world:refresh()

			world.command_health:apply_damage(entity, 10)

			assert(world.event_bus:get_stash("health_event"))
			assert(#world.event_bus:get_stash("health_event") == 1)
			local event = world.event_bus:get_stash("health_event")[1]
			assert(event.entity == entity)
			assert(event.damage == 10)
		end)
	end)
end
