components {
  id: "entity"
  component: "/decore/entity.script"
  properties {
    id: "prefab_id"
    value: "on_spawn_command"
    type: PROPERTY_TYPE_HASH
  }
}
components {
  id: "component_on_spawn_command"
  component: "/system/on_spawn_command/component_on_spawn_command.script"
}
embedded_components {
  id: "command"
  type: "label"
  data: "size {\n"
  "  x: 900.0\n"
  "  y: 100.0\n"
  "}\n"
  "outline {\n"
  "  w: 0.0\n"
  "}\n"
  "shadow {\n"
  "  w: 0.0\n"
  "}\n"
  "pivot: PIVOT_W\n"
  "text: \"command_game_gui, set_text, rocket\\n"
  "\"\n"
  "  \"\"\n"
  "font: \"/druid/fonts/text_regular.font\"\n"
  "material: \"/core/utils/editor_only_label-df.material\"\n"
  ""
  scale {
    x: 2.0
    y: 2.0
  }
}
