components {
  id: "component_physics"
  component: "/systems/physics/component_physics.script"
}
components {
  id: "component_remove_with_delay"
  component: "/systems/remove_with_delay/component_remove_with_delay.script"
}
components {
  id: "entity"
  component: "/decore/entity.script"
  properties {
    id: "prefab_id"
    value: "bullet_sniper"
    type: PROPERTY_TYPE_HASH
  }
  properties {
    id: "size_x"
    value: "32.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "size_y"
    value: "32.0"
    type: PROPERTY_TYPE_NUMBER
  }
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_DYNAMIC\n"
  "mass: 0.003\n"
  "friction: 0.1\n"
  "restitution: 1.0\n"
  "group: \"bullet\"\n"
  "mask: \"solid\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_SPHERE\n"
  "    position {\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 1\n"
  "  }\n"
  "  data: 16.811594\n"
  "}\n"
  "locked_rotation: true\n"
  "bullet: true\n"
  ""
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"ui_circle_32\"\n"
  "material: \"/panthera/materials/sprite.material\"\n"
  "size {\n"
  "  x: 32.0\n"
  "  y: 32.0\n"
  "}\n"
  "attributes {\n"
  "  name: \"color\"\n"
  "  double_values {\n"
  "    v: 1.0\n"
  "    v: 1.0\n"
  "    v: 1.0\n"
  "    v: 1.0\n"
  "  }\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/atlases/game_shooting_circle.atlas\"\n"
  "}\n"
  ""
}
