embedded_components {
  id: "bullet"
  type: "factory"
  data: "prototype: \"/entity/bullet/bullet.go\"\n"
  ""
}
embedded_components {
  id: "bullet_explosion"
  type: "factory"
  data: "prototype: \"/entity/bullet/bullet_explosion.go\"\n"
  ""
}
embedded_components {
  id: "bullet_shotgun"
  type: "collectionfactory"
  data: "prototype: \"/entity/bullet/bullet_shotgun.collection\"\n"
  ""
}
embedded_components {
  id: "damage_number"
  type: "collectionfactory"
  data: "prototype: \"/entity/damage_number/damage_number.collection\"\n"
  ""
}
embedded_components {
  id: "explosion"
  type: "factory"
  data: "prototype: \"/entity/explosion/explosion.go\"\n"
  ""
}
embedded_components {
  id: "rocket"
  type: "collectionfactory"
  data: "prototype: \"/entity/bullet/rocket.collection\"\n"
  ""
}
embedded_components {
  id: "game_gui"
  type: "collectionfactory"
  data: "prototype: \"/entity/game_gui/game_gui.collection\"\n"
  "load_dynamically: true\n"
  ""
}
