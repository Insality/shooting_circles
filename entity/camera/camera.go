components {
  id: "entity"
  component: "/entity/entity.script"
  properties {
    id: "size_x"
    value: "1920.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "size_y"
    value: "1080.0"
    type: PROPERTY_TYPE_NUMBER
  }
}
components {
  id: "component_camera"
  component: "/entity/camera/component_camera.script"
}
embedded_components {
  id: "camera"
  type: "camera"
  data: "aspect_ratio: 1.0\n"
  "fov: 1.0\n"
  "near_z: 0.001\n"
  "far_z: 100.0\n"
  "orthographic_projection: 1\n"
  ""
}
embedded_components {
  id: "screen_overlay"
  type: "sprite"
  data: "default_animation: \"empty\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 1920.0\n"
  "  y: 1080.0\n"
  "}\n"
  "size_mode: SIZE_MODE_MANUAL\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/entity/camera/screen_overlay.atlas\"\n"
  "}\n"
  ""
  position {
    z: -10.0
  }
}
