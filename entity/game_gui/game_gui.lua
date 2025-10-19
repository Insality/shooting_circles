local shooter_hud = require("widget.shooter_hud.shooter_hud")
local memory_panel = require("druid.widget.memory_panel.memory_panel")
local fps_panel = require("druid.widget.fps_panel.fps_panel")
local properties_panel = require("druid.widget.properties_panel.properties_panel")
local decore_debug_page = require("decore.decore_debug_page")
local evolved = require("evolved")
local fragments = require("fragments")

---@class widget.game_gui: druid.widget
local M = {}


function M:init()
	self.shooter_hud = self.druid:new_widget(shooter_hud, "shooter_hud")
	self.shooter_hud:set_shoot_count(10)
	self.shooter_hud:set_patrons(6)

	self.memory_panel = self.druid:new_widget(memory_panel, "memory_panel")
	self.fps_panel = self.druid:new_widget(fps_panel, "fps_panel")
	self.properties_panel = self.druid:new_widget(properties_panel, "properties_panel")
	self.properties_panel:set_properties_per_page(18)

	self.properties_panel:add_button(function(button)
		local profiler_mode = nil
		button:set_text_property("Profiler")
		button:set_text_button("Toggle")
		button.button.on_click:subscribe(function()
			if not profiler_mode then
				profiler_mode = profiler.VIEW_MODE_MINIMIZED
				profiler.enable_ui(true)
				profiler.set_ui_view_mode(profiler_mode)
			elseif profiler_mode == profiler.VIEW_MODE_MINIMIZED then
				profiler_mode = profiler.VIEW_MODE_FULL
				profiler.enable_ui(true)
				profiler.set_ui_view_mode(profiler_mode)
			else
				profiler.enable_ui(false)
				profiler_mode = nil
			end
		end)
	end)

	self.properties_panel:add_button(function(button)
		local systems = evolved.builder():include(fragments.system):spawn()
		local count = 0
		for _, _, entity_count in evolved.execute(systems) do
			count = count + entity_count
		end

		button:set_text_property("Systems")
		button:set_text_button(string.format("Inspect (%d)", count))
		button:set_color("#E6DF9F")
		button.button.on_click:subscribe(function()
			decore_debug_page.render_systems_page(self.druid, self.properties_panel)
		end)
	end)

	self.properties_panel:add_button(function(button)
		button:set_text_property("Prefabs")
		button:set_text_button(string.format("Inspect"))
		button.button.on_click:subscribe(function()
			decore_debug_page.render_prefabs_page(self.druid, self.properties_panel, _G.ENTITIES)
		end)
	end)
end


function M:play_hit()
	self.shooter_hud:play_hit()
end


function M:set_shoot_count(count)
	self.shooter_hud:set_shoot_count(count)
end


return M
