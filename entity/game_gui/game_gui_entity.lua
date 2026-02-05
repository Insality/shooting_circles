---@return entity.game_gui
return {
	transform = {},
	game_object = { factory_url = "/entities#game_gui" },
	druid_widget = { widget_class = require("entity.game_gui.game_gui"), widget_id = "game_gui" },
	game_gui = true
}
