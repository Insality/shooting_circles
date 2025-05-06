---@class world
---@field command_transform system.transform.command

---@class system.transform.command
---@field transform system.transform
local M = {}


---@param transform system.transform
---@return system.transform.command
function M.create(transform)
	return setmetatable({ transform = transform }, { __index = M })
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_position(entity, x, y, z)
	assert(entity.transform, "Entity does not have a transform component.")
	---@cast entity entity.transform
	self.transform:set_position(entity, x, y, z)
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:add_position(entity, x, y, z)
	local t = entity.transform
	assert(t, "Entity does not have a transform component.")
	---@cast entity entity.transform

	x = x and t.position_x + x
	y = y and t.position_y + y
	z = z and t.position_z + z
	self.transform:set_position(entity, x, y, z)
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_scale(entity, x, y, z)
	assert(entity.transform, "Entity does not have a transform component.")
	---@cast entity entity.transform
	self.transform:set_scale(entity, x, y, z)
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_size(entity, x, y, z)
	assert(entity.transform, "Entity does not have a transform component.")
	---@cast entity entity.transform
	self.transform:set_size(entity, x, y, z)
end


function M:set_rotation(entity, rotation)
	assert(entity.transform, "Entity does not have a transform component.")
	---@cast entity entity.transform
	self.transform:set_rotation(entity, rotation)
end


---@param entity entity
---@param animate_time number|nil
---@param easing userdata|nil
function M:set_animate_time(entity, animate_time, easing)
	assert(entity.transform, "Entity does not have a transform component.")
	---@cast entity entity.transform
	self.transform:set_animate_time(entity, animate_time, easing)
end


---Return node borders relative to the current node parent
---@param entity entity
---@return number, number, number, number @left, top, right, bottom
function M:get_transform_borders(entity)
	local t = entity.transform --[[@as component.transform]]

	local left = t.position_x - t.size_x * 0.5
	local top = t.position_y + t.size_y * 0.5
	local right = t.position_x + t.size_x * 0.5
	local bottom = t.position_y - t.size_y * 0.5

	return left, top, right, bottom
end


---Check if two entities are overlapping
---@param entity1 entity
---@param entity2 entity
---@return boolean
function M:is_overlap(entity1, entity2)
	local left1, right1, top1, bottom1 = self:get_transform_borders(entity1)
	local left2, right2, top2, bottom2 = self:get_transform_borders(entity2)

	return left1 < right2 and right1 > left2 and top1 > bottom2 and bottom1 < top2
end



return M
