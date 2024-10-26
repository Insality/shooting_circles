local decore = require("decore.decore")
local decore_internal = require("decore.decore_internal")

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
---@field entities entity.on_target_count_command[]
local M = {}


---@static
---@return system.on_target_count_command
function M.create_system(on_target_count)
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAny("on_target_count_command")
	system.on_target_count = on_target_count
	system.id = "on_target_count_command"

	return system
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

	pprint(entity)
end


function M:postWrap()
	self.world.queue:process("target_tracker_event", self.process_target_tracker_event, self)
end


---@param amount event.target_tracker_event
function M:process_target_tracker_event(amount)
	for _, entity in ipairs(self.entities) do
		local command = entity.on_target_count_command
		if command then
			pprint(command, amount)
			if command.amount == amount then
				local data = json.decode(entity.on_target_count_command.command)
				pprint(data)
				decore.call_command(self.world, data)
			end
		end
	end
end


return M
