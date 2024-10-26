return {
    type = "animation_editor",
    version = 1,
    format = "json",
    data = {
        nodes = {
        },
        metadata = {
            settings = {
                font_size = 40,
            },
            gizmo_steps = {
            },
            fps = 60,
            layers = {
            },
            gui_path = "/game/levels/level_sniper.collection",
        },
        animations = {
            {
                duration = 1,
                animation_id = "default",
                animation_keys = {
                },
            },
            {
                duration = 5,
                animation_id = "level",
                animation_keys = {
                    {
                        property_id = "position_x",
                        duration = 1.42,
                        easing = "outsine",
                        key_type = "tween",
                        end_value = -460,
                        node_id = "enemy/root",
                    },
                    {
                        property_id = "position_y",
                        duration = 1.42,
                        easing = "outsine",
                        key_type = "tween",
                        end_value = 470,
                        node_id = "enemy/root",
                    },
                    {
                        property_id = "position_x",
                        start_value = -460,
                        easing = "outsine",
                        end_value = 460,
                        key_type = "tween",
                        start_time = 1.42,
                        node_id = "enemy/root",
                        duration = 2.18,
                    },
                    {
                        property_id = "position_x",
                        start_value = 460,
                        easing = "outsine",
                        key_type = "tween",
                        start_time = 3.6,
                        node_id = "enemy/root",
                        duration = 1.4,
                    },
                },
            },
        },
    },
}