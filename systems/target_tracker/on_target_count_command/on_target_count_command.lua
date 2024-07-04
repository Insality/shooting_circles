local ecs = require("decore.ecs")

---@class entity
---@field on_target_count_command component.on_target_count_command|nil

---@class entity.on_target_count_command: entity
---@field on_target_count_command component.on_target_count_command

---@class component.on_target_count_command
---@field amount number
---@field command string

---@class system.on_target_count_command: system
---@field entities entity.on_target_count_command[]
local M = {}


---@static
---@return system.on_target_count_command
function M.create_system(on_target_count)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("on_target_count_command", "target_tracker_event")
	system.on_target_count = on_target_count

	return system
end


---@param entity entity.on_target_count_command
function M:onAdd(entity)
	local target_tracker_event = entity.target_tracker_event
	if target_tracker_event then
		self:process_target_tracker_event(target_tracker_event)
	end
end


---@param target_tracker_event component.target_tracker_event
function M:process_target_tracker_event(target_tracker_event)
	for _, entity in ipairs(self.entities) do
		local command = entity.on_target_count_command
		if command then
			if target_tracker_event.target_count == command.amount then
				local data = json.decode(entity.on_target_count_command.command)
				self.world:addEntity(data)
			end
		end
	end
end


return M
