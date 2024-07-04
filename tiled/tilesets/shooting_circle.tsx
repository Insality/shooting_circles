<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="2022.09.22" name="shooting_circle" class="shooting_circle" tilewidth="1080" tileheight="200" tilecount="9" columns="0">
 <editorsettings>
  <export target="../../../resources/tilesets/shooting_circle.json" format="json"/>
 </editorsettings>
 <grid orientation="orthogonal" width="1" height="1"/>
 <tile id="0" class="player">
  <properties>
   <property name="color" type="class" propertytype="color">
    <properties>
     <property name="hex_color" value="95C8E2"/>
     <property name="sprite_url" value="/root#sprite"/>
    </properties>
   </property>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#player"/>
    </properties>
   </property>
   <property name="movement_controller" type="class" propertytype="movement_controller">
    <properties>
     <property name="speed" type="float" value="4000"/>
    </properties>
   </property>
   <property name="physics" type="class" propertytype="physics"/>
   <property name="shooter_controller" type="class" propertytype="shooter_controller">
    <properties>
     <property name="bullet_prefab_id" value="bullet_pistol"/>
     <property name="bullet_speed" type="float" value="3000"/>
     <property name="burst_count" type="int" value="8"/>
     <property name="burst_rate" type="float" value="0.5"/>
     <property name="damage" type="float" value="1"/>
     <property name="fire_rate" type="float" value="0.05"/>
     <property name="is_auto_shoot" type="bool" value="true"/>
     <property name="spread" type="float" value="32"/>
     <property name="spread_angle" type="float" value="14"/>
    </properties>
   </property>
  </properties>
  <image width="64" height="64" source="../images/ui_circle_64.png"/>
 </tile>
 <tile id="2" class="enemy">
  <properties>
   <property name="color" type="class" propertytype="color">
    <properties>
     <property name="hex_color" value="612C2C"/>
     <property name="sprite_url" value="/root#sprite"/>
    </properties>
   </property>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#enemy"/>
    </properties>
   </property>
   <property name="health" type="class" propertytype="health">
    <properties>
     <property name="health" type="float" value="20"/>
    </properties>
   </property>
   <property name="health_circle_visual" type="class" propertytype="health_circle_visual"/>
   <property name="panthera" type="class" propertytype="panthera">
    <properties>
     <property name="animation_path" value="/resources/animations/health_visual_circle.json"/>
    </properties>
   </property>
   <property name="physics" type="class" propertytype="physics"/>
   <property name="play_fx_on_remove" type="class" propertytype="play_fx_on_remove">
    <properties>
     <property name="fx_url" value="explosion_enemy"/>
    </properties>
   </property>
   <property name="target" type="bool" value="true"/>
  </properties>
  <image width="64" height="64" source="../images/enemy.png"/>
 </tile>
 <tile id="4" class="arena_background">
  <properties>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#background"/>
     <property name="is_slice9" type="bool" value="true"/>
    </properties>
   </property>
  </properties>
  <image width="200" height="200" source="../images/arena_background.png"/>
 </tile>
 <tile id="5" class="wall">
  <properties>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#wall"/>
     <property name="is_slice9" type="bool" value="false"/>
    </properties>
   </property>
  </properties>
  <image width="200" height="50" source="../images/wall.png"/>
 </tile>
 <tile id="6" class="pit">
  <properties>
   <property name="color" type="class" propertytype="color">
    <properties>
     <property name="hex_color" value="612C2C"/>
     <property name="sprite_url" value="/root#sprite"/>
    </properties>
   </property>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#pit"/>
     <property name="is_slice9" type="bool" value="true"/>
    </properties>
   </property>
  </properties>
  <image width="16" height="16" source="../images/pit.png"/>
 </tile>
 <tile id="7" class="wall_pit">
  <properties>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#wall_pit"/>
     <property name="is_slice9" type="bool" value="false"/>
    </properties>
   </property>
  </properties>
  <image width="200" height="50" source="../images/wall.png"/>
 </tile>
 <tile id="8" class="enemy_rectangle">
  <properties>
   <property name="color" type="class" propertytype="color">
    <properties>
     <property name="hex_color" value="612C2C"/>
     <property name="sprite_url" value="/root#sprite"/>
    </properties>
   </property>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#enemy_rectangle"/>
    </properties>
   </property>
   <property name="health" type="class" propertytype="health">
    <properties>
     <property name="health" type="float" value="400"/>
    </properties>
   </property>
   <property name="health_circle_visual" type="class" propertytype="health_circle_visual"/>
   <property name="panthera" type="class" propertytype="panthera">
    <properties>
     <property name="animation_path" value="/resources/animations/health_visual_rectangle.json"/>
    </properties>
   </property>
   <property name="physics" type="class" propertytype="physics"/>
   <property name="target" type="bool" value="true"/>
  </properties>
  <image width="128" height="64" source="../images/enemy_rectangle.png"/>
 </tile>
 <tile id="9" class="level_controller">
  <properties>
   <property name="on_spawn_command" type="class" propertytype="on_spawn_command">
    <properties>
     <property name="command" value="{&quot;gui_main_command&quot;: {&quot;text&quot;: &quot;Shoot&quot;}}"/>
    </properties>
   </property>
   <property name="on_target_count_command" type="class" propertytype="on_target_count_command">
    <properties>
     <property name="command" value="{&quot;gui_main_command&quot;: {&quot;level_complete&quot;: true}}"/>
    </properties>
   </property>
  </properties>
  <image width="200" height="200" source="../images/arena_background.png"/>
 </tile>
 <tile id="10" class="pit">
  <properties>
   <property name="game_object" type="class" propertytype="game_object">
    <properties>
     <property name="factory_url" value="/spawner/spawner#pit"/>
     <property name="is_slice9" type="bool" value="false"/>
    </properties>
   </property>
  </properties>
  <image width="1080" height="140" source="../images/wall_pit.png"/>
 </tile>
</tileset>
