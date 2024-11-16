local decore = require("decore.decore")

---@class entity
---@field on_target_count_command component.on_target_count_command|nil

---@class entity.on_target_count_command: entity
---@field on_target_count_command component.on_target_count_command

---@class component.on_target_count_command
---@field amount number
---@field command string
---@field command_label boolean
decore.register_component("on_target_count_command", {
	amount = 0,
})

---@class system.on_target_count_command: system
local M = {}


---@static
---@return system.on_target_count_command
function M.create_system()
	return decore.system(M, "on_target_count_command", "on_target_count_command")
end


---@param entity entity.on_target_count_command
function M:onAdd(entity)
	local command = entity.on_target_count_command
	if command.command_label and entity.game_object then
		local root = entity.game_object.root
		local label_url = msg.url(nil, root, "label")
		command.command = label.get_text(label_url)
		-- Trim
		command.command = command.command:match("^%s*(.-)%s*$")
	end
end


function M:postWrap()
	self.world.event_bus:process("target_tracker_event", self.process_target_tracker_event, self)
end


---@param amount event.target_tracker_event
function M:process_target_tracker_event(amount)
	for _, entity in ipairs(self.entities) do
		local command = entity.on_target_count_command
		if command then
			if command.amount == amount then
				local data = json.decode(entity.on_target_count_command.command)
				decore.call_command(self.world, data)
			end
		end
	end
end


return M
