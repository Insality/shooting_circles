local panthera = require("panthera.panthera")
local animation = require("widget.shooter_hud.shooter_hud_panthera")

---@class widget.shooter_hud: druid.widget
local M = {}


function M:init()
	self.root = self:get_node("root")
	self.prefab_bullet = self:get_node("prefab_bullet")
	self.text_shoot_count = self.druid:new_text("text_shoot_count")
	self.layout = self.druid:new_layout("patrons", "vertical")
	self.animation = panthera.create_gui(animation, self:get_template(), self:get_nodes())
	self.animation_hit = panthera.clone_state(self.animation)

	gui.set_enabled(self.prefab_bullet, false)

	self.patron_nodes = {}

	panthera.play(self.animation, "appear")
end


---@param count number
function M:set_shoot_count(count)
	self.text_shoot_count:set_text(tostring(count))
end



function M:set_patrons(count)
	self.layout:clear_layout()
	for _, node in ipairs(self.patron_nodes) do
		gui.delete_node(node)
	end

	for i = 1, count do
		local node = gui.clone(self.prefab_bullet)
		gui.set_enabled(node, true)
		self.layout:add(node)
		table.insert(self.patron_nodes, node)
	end
end


function M:play_hit()
	panthera.play(self.animation_hit, "hit")
end


return M
