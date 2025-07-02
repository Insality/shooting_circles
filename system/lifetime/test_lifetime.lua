return function()
	describe("System Health", function()
		local evolved = require("evolved")
		local fragments = require("fragments")
		local system_lifetime = require("system.lifetime.lifetime")
		local system_transform = require("system.transform.transform")
		local systems = {}

		before(function()
			system_transform.register_fragments()
			system_lifetime.register_fragments()
			systems = { system_lifetime.create_system() }
		end)

		it("Should decrement lifetime", function()
			local entity = evolved.builder()
				:set(fragments.lifetime, 1)
				:spawn()

			assert(evolved.alive(entity))

			evolved.set(fragments.dt, fragments.dt, 0.5)
			evolved.process(unpack(systems))

			assert(evolved.alive(entity))

			evolved.set(fragments.dt, fragments.dt, 1)
			evolved.process(unpack(systems))

			assert(not evolved.alive(entity))
		end)

		it("Should spawn other entities", function()
			local entity_to_spawn = evolved.builder()
				:name("entity_to_spawn")
				:prefab()
				:spawn()

			local entity = evolved.builder()
				:set(fragments.lifetime, 1)
				:set(fragments.spawn_on_destroy, entity_to_spawn)
				:spawn()

			assert(evolved.alive(entity))

			evolved.set(fragments.dt, fragments.dt, 1)
			evolved.process(unpack(systems))

			assert(not evolved.alive(entity))

			local query = evolved.builder():include(evolved.NAME):spawn()
			local is_spawned = 0
			for chunk, entity_list, entity_count in evolved.execute(query) do
				local names = chunk:components(evolved.NAME)
				for index = 1, entity_count do
					if names[index] == "entity_to_spawn" then
						is_spawned = is_spawned + 1
					end
				end
			end

			evolved.destroy(entity)
			evolved.destroy(entity_to_spawn)
			assert(is_spawned == 1)
		end)
	end)
end
