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
                animation_id = "health",
                animation_keys = {
                    {
                        easing = "outsine",
                        end_value = -32,
                        key_type = "tween",
                        node_id = "fill",
                        property_id = "position_y",
                    },
                    {
                        easing = "outsine",
                        is_editor_only = true,
                        key_type = "tween",
                        node_id = "fill#fill",
                        property_id = "color_b",
                        start_value = 1,
                    },
                    {
                        easing = "outsine",
                        is_editor_only = true,
                        key_type = "tween",
                        node_id = "fill#fill",
                        property_id = "color_g",
                        start_value = 1,
                    },
                    {
                        easing = "outsine",
                        key_type = "tween",
                        node_id = "fill#fill",
                        property_id = "size_y",
                        start_value = 64,
                    },
                    {
                        duration = 0.5,
                        easing = "linear",
                        end_value = -16,
                        key_type = "tween",
                        node_id = "fill",
                        property_id = "position_y",
                        start_value = -32,
                    },
                    {
                        duration = 0.5,
                        easing = "linear",
                        end_value = 32,
                        key_type = "tween",
                        node_id = "fill#fill",
                        property_id = "size_y",
                    },
                    {
                        duration = 1,
                        easing = "linear",
                        end_value = 64,
                        key_type = "tween",
                        node_id = "fill#fill",
                        property_id = "slice9_bottom",
                    },
                },
                duration = 1,
            },
            {
                animation_id = "on_hit",
                animation_keys = {
                    {
                        easing = "outsine",
                        end_value = 1.4,
                        key_type = "tween",
                        node_id = "root#sprite",
                        property_id = "color_a",
                        start_value = 1,
                    },
                    {
                        duration = 0.2,
                        easing = "outsine",
                        end_value = 1,
                        key_type = "tween",
                        node_id = "root#sprite",
                        property_id = "color_a",
                        start_value = 1.4,
                    },
                },
                duration = 0.2,
            },
        },
        metadata = {
            fps = 60,
            gizmo_steps = {
            },
            gui_path = "entities/enemy/enemy.collection",
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