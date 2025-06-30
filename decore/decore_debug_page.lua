local property_system = require("decore.properties_panel.property_system")
local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.render_properties_panel(druid, properties_panel)
	properties_panel:next_scene()
	properties_panel:set_header("Decore Panel")

	properties_panel:add_button(function(button)
		button:set_text_property("Systems")
		button:set_text_button(string.format("Inspect"))
		button:set_color("#E6DF9F")
		button.button.on_click:subscribe(function()
			M.render_systems_page(druid, properties_panel)
		end)
	end)
end


---@param system evolved.id
---@return evolved.query
local function get_system_query(system)
	local system_query = evolved.get(system, evolved.QUERY)
	if system_query then
		return system_query
	else
		local includes = evolved.get(system, evolved.INCLUDES) or {}
		local excludes = evolved.get(system, evolved.EXCLUDES) or {}

		local query = evolved.builder()
			:include(unpack(includes))
			:exclude(unpack(excludes))
			:spawn()

		return query
	end
end


---@param system_query evolved.query
---@return number, evolved.entity[]
local function get_entity_count_from_system(system_query)
	local count = 0
	local entities = {}
	for chunk, entity_list, entity_count in evolved.execute(system_query) do
		count = count + entity_count
		for i = 1, entity_count do
			table.insert(entities, entity_list[i])
		end
	end
	return count, entities
end


---@param druid druid.instance
---@param properties_panel druid.widget.properties_panel
function M.render_entities_page(druid, properties_panel)
	properties_panel:next_scene()
	properties_panel:set_header("Entities")
end


---@param druid druid.instance
---@param properties_panel druid.widget.properties_panel
function M.render_systems_page(druid, properties_panel)
	properties_panel:next_scene()
	properties_panel:set_header("Systems")

	local systems_query = evolved.builder():include(fragments.system):spawn()

	local systems = {}
	for chunk, entity_list, entity_count in evolved.execute(systems_query) do
		for i = 1, entity_count do
			table.insert(systems, entity_list[i])
		end
	end

	table.sort(systems, function(a, b)
		return evolved.get(a, evolved.NAME) < evolved.get(b, evolved.NAME)
	end)

	properties_panel.text_header:set_text("World systems (" .. #systems .. ")")
	for i = 1, #systems do
		local system = systems[i]
		local system_id = evolved.get(system, evolved.NAME) or "Unknown"
		local system_query = get_system_query(system)

		properties_panel:add_widget(function()
			local widget = druid:new_widget(property_system, "property_system", "root")
			widget:set_system(system)
			local prev_count = nil
			widget:set_text_function(function()
				local entity_count = get_entity_count_from_system(system_query)
				if prev_count ~= entity_count then
					prev_count = entity_count
					return string.format("%s | %s", entity_count or 0, system_id)
				end
				return nil
			end)
			widget.button_inspect.on_click:subscribe(function()
				M.render_system_page(system, system_query, properties_panel)
			end)

			return widget
		end)
	end
end


---@param system evolved.id
---@param system_query evolved.query
---@param properties_panel druid.widget.properties_panel
function M.render_system_page(system, system_query, properties_panel)
	local system_id = evolved.get(system, evolved.NAME) or "Unknown"

	properties_panel:next_scene()
	properties_panel:set_header(string.format("System %s", system_id))

	local entity_count = get_entity_count_from_system(system_query)

	properties_panel:add_button(function(button)
		button:set_text_property("Inspect")
		button:set_text_button(string.format("Entities (%s)", entity_count or 0))
		button.button.on_click:subscribe(function()
			M.render_entities(system, properties_panel)
		end)
	end)
end


---@param system_query evolved.query
---@param properties_panel druid.widget.properties_panel
function M.render_entities(system_query, properties_panel)
	properties_panel:next_scene()
	properties_panel:set_header(string.format("Entities"))

	local entity_count, entities = get_entity_count_from_system(system_query)

	for index = 1, entity_count do
		properties_panel:add_button(function(button)
			local entity = entities[index]
			local id = evolved.unpack(entity)
			local name = evolved.get(entity, evolved.NAME) or "entity"
			button:set_text_property(string.format("%s. %s", id, name))
			button:set_text_button("View")
			button.button.on_click:subscribe(function()
				M.render_entity(entity, properties_panel)
			end)
		end)
	end
end


---@return string[]
function M.get_components(entity)
	local component_lists = {}
	for k, v in pairs(fragments) do
		if evolved.has(entity, v) then
			table.insert(component_lists, k)
		end
	end
	table.sort(component_lists)
	return component_lists
end


---@param entity evolved.id
---@param properties_panel druid.widget.properties_panel
function M.render_entity(entity, properties_panel)
	properties_panel:next_scene()
	properties_panel:set_header(string.format("Entity"))

	properties_panel:add_text(function(text)
		text:set_text_property("Index")
		text:set_text_value(tostring(evolved.unpack(entity)))
	end)

	for fragment, value in evolved.each(entity) do
		if type(value) == "table" then
			properties_panel:add_button(function(button)
				local data = value
				button:set_text_property(evolved.get(fragment, evolved.NAME) or "Unknown")
				button:set_text_button("View")
				button.button.on_click:subscribe(function()
					properties_panel:next_scene()
					properties_panel:set_header(evolved.get(fragment, evolved.NAME) or "Unknown")
					properties_panel:render_lua_table(data)
				end)
			end)
		else
			properties_panel:add_text(function(text)
				text:set_text_property(evolved.get(fragment, evolved.NAME) or "Unknown")
				text:set_text_value(evolved.get(entity, fragment))
			end)
		end
	end
end


return M
