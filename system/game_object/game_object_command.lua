---@class world
---@field game_object system.game_object.command

---@class system.game_object.command
---@field game_object system.game_object
local M = {}


---@return system.game_object.command
function M.create(game_object)
	return setmetatable({ game_object = game_object }, { __index = M })
end


---@param entity entity
function M:refresh_transform(entity)
	assert(entity.game_object, "Entity should have game_object component")
	assert(entity.transform, "Entity should have transform component")
	---@cast entity entity.game_object
	self.game_object:refresh_transform(entity)
end


---@param entity entity
---@param enabled boolean
function M:set_enabled(entity, enabled)
	assert(entity.game_object, "Entity has no game_object component")

	for _, game_object in pairs(entity.game_object.object) do
		if enabled then
			msg.post(game_object, "enable")
		else
			msg.post(game_object, "disable")
		end
	end
end


---@param id string|hash
---@return entity|nil
function M:get_entity(id)
	return self.game_object.root_to_entity[id]
end


return M
