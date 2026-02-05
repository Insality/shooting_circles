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
            gui_path = "/game/objects/enemy/enemy.collection",
        },
        animations = {
            {
                duration = 1,
                animation_id = "health",
                animation_keys = {
                    {
                        property_id = "position_y",
                        end_value = -32,
                        easing = "outsine",
                        key_type = "tween",
                        node_id = "health",
                    },
                    {
                        property_id = "size_y",
                        start_value = 64,
                        easing = "outsine",
                        key_type = "tween",
                        node_id = "health#sprite",
                    },
                    {
                        property_id = "position_y",
                        start_value = -32,
                        easing = "linear",
                        key_type = "tween",
                        end_value = -16,
                        node_id = "health",
                        duration = 0.5,
                    },
                    {
                        property_id = "size_y",
                        duration = 0.5,
                        easing = "linear",
                        key_type = "tween",
                        end_value = 32,
                        node_id = "health#sprite",
                    },
                    {
                        property_id = "slice9_bottom",
                        duration = 1,
                        easing = "linear",
                        key_type = "tween",
                        end_value = 64,
                        node_id = "health#sprite",
                    },
                },
            },
            {
                duration = 0.3,
                animation_id = "on_damage",
                animation_keys = {
                    {
                        property_id = "color_a",
                        start_value = 1,
                        easing = "outsine",
                        key_type = "tween",
                        end_value = 0.5,
                        node_id = "root#impact",
                    },
                    {
                        property_id = "color_a",
                        start_value = 0.5,
                        easing = "insine",
                        key_type = "tween",
                        node_id = "root#impact",
                        duration = 0.3,
                    },
                },
            },
        },
    },
}