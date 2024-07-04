local ecs = require("decore.ecs")
local decore = require("decore.decore")

local logger = decore.get_logger("system.level_loader")

local level_loader_command = require("systems.level_loader.level_loader_command")

---@class system.level_loader: system
---@field loaded_world_list table<string, entity[]> @slot_id -> entity[]
local M = {}


---@static
---@return system.level_loader, system.level_loader_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.id = "level_loader"

	system.loaded_world_list = {}

	return system, level_loader_command.create_system(system)
end


---@param world_id string
---@param pack_id string|nil
---@param offset_x number|nil
---@param offset_y number|nil
---@param slot_id string|nil
function M:load_world(world_id, pack_id, offset_x, offset_y, slot_id)
	logger:debug("load_world", { world_id = world_id,
		pack_id = pack_id,
		offset_x = offset_x,
		offset_y = offset_y,
		slot_id = slot_id
	})

	offset_x = offset_x or 0
	offset_y = offset_y or 0

	local entities = decore.create_world(world_id, pack_id)
	if not entities then
		logger:error("Failed to load world", world_id)
		return
	end

	-- Remove old world
	if slot_id then
		if self.loaded_world_list[slot_id] then
			local world_entities = self.loaded_world_list[slot_id]
			for index = 1, #world_entities do
				self.world:removeEntity(world_entities[index])
			end
		end

		self.loaded_world_list[slot_id] = entities
	end

	-- Spawn new world
	for index = 1, #entities do
		local new_entity = entities[index]

		if new_entity.transform then
			new_entity.transform.position_x = new_entity.transform.position_x + offset_x
			new_entity.transform.position_y = new_entity.transform.position_y + offset_y
		end

		self.world:addEntity(new_entity)
	end
end


return M
