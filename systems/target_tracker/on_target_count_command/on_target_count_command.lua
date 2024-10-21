local decore = require("decore.decore")

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
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAny("on_target_count_command")
	system.on_target_count = on_target_count

	return system
end


function M:postWrap()
	self.world.queue:process("target_tracker_event", self.process_target_tracker_event, self)
end


---@param amount event.target_tracker_event
function M:process_target_tracker_event(amount)
	for _, entity in ipairs(self.entities) do
		local command = entity.on_target_count_command
		if command then
			if amount == command.amount then
				local data = json.decode(entity.on_target_count_command.command)
				decore.call_command(self.world, data)
			end
		end
	end
end


return M
