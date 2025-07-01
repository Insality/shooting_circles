local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

---@param children evolved.id[]
local function clone_children(children)
	local new_children = {}
	for index = 1, #children do
		new_children[index] = children[index]
	end
	return new_children
end

function M.register_fragments()
	---@class fragments
	---@field parent_entity evolved.id
	---@field parent_entity_handled evolved.id
	---@field children evolved.id

	fragments.children = evolved.builder()
		:name("children")
		:duplicate(clone_children)
		:on_remove(M.on_remove_children)
		:default({})
		:spawn()

	fragments.parent_entity = evolved.builder()
		:name("parent_entity")
		:on_set(M.on_set_parent_entity)
		:on_remove(M.on_remove_parent_entity)
		:spawn()
end


---@param entity evolved.id
---@param fragment evolved.id
---@param parent_entity evolved.id
function M.on_set_parent_entity(entity, fragment, parent_entity)
	local is_alive = evolved.alive(parent_entity)
	if not is_alive then
		return
	end

	if not evolved.has(parent_entity, fragments.children) then
		evolved.set(parent_entity, fragments.children, { entity })
		return
	end

	local children = evolved.get(parent_entity, fragments.children)
	table.insert(children, entity)
end


---@param entity evolved.id
---@param fragment evolved.id
---@param parent_entity evolved.id
function M.on_remove_parent_entity(entity, fragment, parent_entity)
	if not evolved.has(parent_entity, fragments.children) then
		return
	end

	local children = evolved.get(parent_entity, fragments.children)
	for index = #children, 1, -1 do
		if children[index] == entity then
			table.remove(children, index)
			return
		end
	end
end


---@param entity evolved.id
---@param fragment evolved.id
---@param children evolved.id[]
function M.on_remove_children(entity, fragment, children)
	for index = #children, 1, -1 do
		evolved.destroy(children[index])
	end
end


return M
