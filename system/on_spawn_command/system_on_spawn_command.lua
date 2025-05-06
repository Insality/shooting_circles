local decore = require("decore.decore")

---@class entity
---@field on_spawn_command component.on_spawn_command|nil

---@class entity.on_spawn_command: entity
---@field on_spawn_command component.on_spawn_command
decore.register_component("on_spawn_command")

---@class component.on_spawn_command
---@field command any[]
---@field command_label boolean

---@class system.on_spawn_command: system
---@field entities entity.on_spawn_command[]
local M = {}


---@static
---@return system.on_spawn_command
function M.create_system()
	return decore.system(M, "on_spawn_command", { "on_spawn_command" })
end


---@param entity entity.on_spawn_command
function M:onAdd(entity)
	if entity.on_spawn_command.command then
		decore.call_command(self.world, entity.on_spawn_command.command)
	end

	if entity.on_spawn_command.command_label and entity.game_object then
		local root = entity.game_object.root
		local label_url = msg.url(nil, root, "command")
		local command = decore.parse_command(label.get_text(label_url))
		if command then
			decore.call_command(self.world, command)
		end
	end
end



return M
