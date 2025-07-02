return {
    data = {
        animations = {
            {
                animation_id = "default",
                animation_keys = {
                },
                duration = 1,
            },
            {
                animation_id = "hit",
                animation_keys = {
                    {
                        duration = 0.1,
                        easing = "outelastic",
                        end_value = 1.3,
                        key_type = "tween",
                        node_id = "group_text",
                        property_id = "scale_x",
                        start_value = 1,
                    },
                    {
                        duration = 0.1,
                        easing = "outelastic",
                        end_value = 1.3,
                        key_type = "tween",
                        node_id = "group_text",
                        property_id = "scale_y",
                        start_value = 1,
                    },
                    {
                        duration = 0.1,
                        easing = "outsine",
                        end_value = 15,
                        key_type = "tween",
                        node_id = "group_text",
                        property_id = "rotation_z",
                    },
                    {
                        duration = 0.3,
                        easing = "outback",
                        key_type = "tween",
                        node_id = "group_text",
                        property_id = "rotation_z",
                        start_time = 0.1,
                        start_value = 15,
                    },
                    {
                        duration = 0.3,
                        easing = "outback",
                        end_value = 1,
                        key_type = "tween",
                        node_id = "group_text",
                        property_id = "scale_x",
                        start_time = 0.1,
                        start_value = 1.3,
                    },
                    {
                        duration = 0.3,
                        easing = "outback",
                        end_value = 1,
                        key_type = "tween",
                        node_id = "group_text",
                        property_id = "scale_y",
                        start_time = 0.1,
                        start_value = 1.3,
                    },
                },
                duration = 0.4,
            },
            {
                animation_id = "appear",
                animation_keys = {
                    {
                        easing = "outsine",
                        key_type = "tween",
                        node_id = "patrons_reload",
                        property_id = "size_y",
                        start_value = 440,
                    },
                    {
                        duration = 0.67,
                        easing = "outsine",
                        end_value = 1.2,
                        key_type = "tween",
                        node_id = "patrons_reload",
                        property_id = "color_a",
                        start_value = 1,
                    },
                    {
                        duration = 1,
                        easing = "outsine",
                        end_value = 440,
                        key_type = "tween",
                        node_id = "patrons_reload",
                        property_id = "size_y",
                    },
                    {
                        duration = 0.33,
                        easing = "outsine",
                        end_value = 1,
                        key_type = "tween",
                        node_id = "patrons_reload",
                        property_id = "color_a",
                        start_time = 0.67,
                        start_value = 1.2,
                    },
                },
                duration = 1,
            },
        },
        metadata = {
            fps = 60,
            gizmo_steps = {
            },
            gui_path = "widget/shooter_hud/shooter_hud.gui",
            layers = {
            },
            settings = {
                font_size = 40,
            },
            template_animation_paths = {
            },
        },
        nodes = {
        },
    },
    format = "json",
    type = "animation_editor",
    version = 1,
}