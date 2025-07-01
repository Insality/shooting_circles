local druid = require("druid.druid")
local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

function M.register_fragments()
	---@class fragments
	---@field druid_widget_class evolved.id
	---@field druid_component_name evolved.id
	---@field druid_widget evolved.id

	fragments.druid_component_name = evolved.builder():name("druid_component_name"):spawn()
	fragments.druid_widget_class = evolved.builder():name("druid_widget_class"):require(fragments.druid_component_name):spawn()
	fragments.druid_widget = evolved.builder():name("druid_widget_instance"):require(fragments.druid_widget_class):spawn()
end



function M.create_system()
	return evolved.builder()
		:name("druid_widget")
		:set(fragments.system)
		:include(fragments.druid_widget_class)
		:exclude(fragments.druid_widget)
		:execute(M.update)
		:spawn()
end


---@param chunk evolved.chunk
---@param entity_list evolved.id[]
---@param entity_count number
function M.update(chunk, entity_list, entity_count)
	local root_url, druid_widget_class, druid_component_name = chunk:components(fragments.root_url, fragments.druid_widget_class, fragments.druid_component_name)

	for index = 1, entity_count do
		local gui_url = msg.url(nil, root_url[index], druid_component_name[index])
		local widget = druid.get_widget(druid_widget_class[index], gui_url, entity_list[index])
		evolved.set(entity_list[index], fragments.druid_widget, widget)
	end
end


return M
