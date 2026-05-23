Editor_State :: struct {
    selected_collider_idx: u32;
    selected_entity_idx: u32;
    held_entity := false;
    held_entity_idx: u32;
    held_component := false;
    held_entity_component_idx: s32 = -1;
    load_window_scroll_value: float32;
    action_state := Editor_Action.NIL;
    current_action_set: s32;
    room_dirty: bool;
    locked: bool;
}

Editor_Action :: enum {
    NIL :: 0;
    MAKE_AABB :: 1;
    MAKE_TRI :: 2;
    MAKE_POLY :: 3;
    MAKE_ENTITY :: 4;
}

editor_state: Editor_State;

editor_init :: () {
    load_editor_assets();
    Get_Rect.ui_init();

    proc := Get_Rect.default_theme_procs[current_theme];
    my_theme = proc();
    Get_Rect.set_default_theme(my_theme);

    input_theme := *my_theme.text_input_theme;
    input_theme.font = editor_assets.font;
    input_theme.alignment = .Left;
    input_theme.alignment_pad_ems = 0.3;
    input_theme.text_baseline_vertical_position = 0.1;

    label_theme := *my_theme.label_theme;
    label_theme.font = editor_assets.font;
    label_theme.alignment = .Left;

    button_theme := *my_theme.button_theme;
    button_theme.font = editor_assets.font;

    checkbox_theme := *my_theme.checkbox_theme;
    checkbox_theme.font = editor_assets.font;
}

float_fmt :: (v: float32) -> FormatFloat #expand {
    return formatFloat(v, 2, 1, zero_removal = .NO);
}

render_editor_grid :: () {
    for i: 0..20 {
        fi := cast(float32)i;
        h_start := Vector2.{0, fi * 100};
        h_end := Vector2.{1920, fi * 100};
        v_start := Vector2.{fi * 100, 0};
        v_end := Vector2.{fi * 100, 1080};

        h_start = cam_relative_position(h_start);
        h_end = cam_relative_position(h_end);
        v_start = cam_relative_position(v_start);
        v_end = cam_relative_position(v_end);
        render_line(h_start, h_end);
        render_line(v_start, v_end);
    }
}

current_theme: s32 = xx Get_Rect.Default_Themes.Default;
my_theme: Get_Rect.Overall_Theme; // This gets filled out by calling the Theme_Proc for current_theme.

render_editor_ui :: () {
    Simp.set_shader_for_color();

    my_theme.subwindow_theme.title_bar.surface_color = ifx editor_state.room_dirty then Vector4.{1, 0, 0, 1} else Vector4.{.165, .233, .379, 1};

    current_time := to_float64_seconds(current_time_monotonic());
    w, h := Simp.get_render_dimensions(n_window.resource);

    captured_mouse, captured_keyboard := Get_Rect.ui_per_frame_update(n_window.resource, w, h, current_time);
    set_capture_input(!(captured_mouse || captured_keyboard));

    Get_Rect.add_subwindow(*inspector_subwindow, *my_theme.subwindow_theme);
    Get_Rect.add_subwindow(*actions_subwindow, *my_theme.subwindow_theme);
    Get_Rect.add_subwindow(*save_subwindow, *my_theme.subwindow_theme);
    Get_Rect.add_subwindow(*load_subwindow, *my_theme.subwindow_theme);
    draw_action_cursor();
    consume_editor_inputs();
    Get_Rect.draw_popups();
}

mouse_pos :: () -> Vector2 {
    mouse_x, mouse_y, ok := get_mouse_pointer_position();
    mouse_y = xx n_window.height - mouse_y;
    if ok {
        return .{xx mouse_x, xx mouse_y};
    } else {
        return .{-100, -100};
    }
}

mouse_position_to_world :: () -> Vector2 {
    pos := mouse_pos();
    return pos + camera.target;
}

/* 
	These macros will be written at compile time to enable automatically display
	struct members in the inpsector window If they are noted with @editor_display
*/
#placeholder draw_character_data_fields;
draw_collision_data_fields :: (col_shape: Collision_Shape) #expand {
    position_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
    // shift y_pos when we finish defining rects for a row
    `y_pos -= (`label_extents.y + 5);
    position_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
    position_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
    `y_pos -= (`text_extents.y + 10);

    Get_Rect.label(position_label_rect, "position", *my_theme.label_theme);
    {
        x_str := float_str(`entity.position.x);
        action_x, new_text_x, state_x := Get_Rect.text_input(position_x_rect, x_str, *my_theme.text_input_theme);
        if action_x & .ENTERED {
            if modify_float_from_string(*`entity.position.x, new_text_x) {
                new_x_str := float_str(`entity.position.x);
            }
        }
        if !state_x.active {
            Get_Rect.reset(state_x);
        }
    }

    {
        y_str := float_str(`entity.position.y);
        action_y, new_text_y, state_y := Get_Rect.text_input(position_y_rect, y_str, *my_theme.text_input_theme);
        if action_y & .ENTERED {
            if modify_float_from_string(*`entity.position.y, new_text_y) {
                new_y_str := float_str(`entity.position.y);
            }
        }
        if !state_y.active {
            Get_Rect.reset(state_y);
        }
    }

    if col_shape == {
    case .AABB;
        min_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        min_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        min_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(min_label_rect, "min", *my_theme.label_theme); {
            x_str := float_str(`entity.aabb_extents[0].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(min_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.aabb_extents[0].x, new_text_x) {
                    new_x_str := float_str(`entity.aabb_extents[0].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.aabb_extents[0].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(min_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.aabb_extents[0].y, new_text_y) {
                    new_y_str := float_str(`entity.aabb_extents[0].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }

        max_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        max_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        max_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(max_label_rect, "max", *my_theme.label_theme); {
            x_str := float_str(`entity.aabb_extents[1].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(max_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.aabb_extents[1].x, new_text_x) {
                    new_x_str := float_str(`entity.aabb_extents[1].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.aabb_extents[1].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(max_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.aabb_extents[1].y, new_text_y) {
                    new_y_str := float_str(`entity.aabb_extents[1].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }
    case .TRIANGLE;
        a_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        a_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        a_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(a_label_rect, "a", *my_theme.label_theme); {
            x_str := float_str(`entity.triangle_verts[0].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(a_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.triangle_verts[0].x, new_text_x) {
                    new_x_str := float_str(`entity.triangle_verts[0].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.triangle_verts[0].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(a_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.triangle_verts[0].y, new_text_y) {
                    new_y_str := float_str(`entity.triangle_verts[0].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }

        b_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        b_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        b_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(b_label_rect, "b", *my_theme.label_theme); {
            x_str := float_str(`entity.triangle_verts[1].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(b_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.triangle_verts[1].x, new_text_x) {
                    new_x_str := float_str(`entity.triangle_verts[1].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.triangle_verts[1].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(b_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.triangle_verts[1].y, new_text_y) {
                    new_y_str := float_str(`entity.triangle_verts[1].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }

        c_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        c_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        c_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(c_label_rect, "c", *my_theme.label_theme); {
            x_str := float_str(`entity.triangle_verts[2].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(c_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.triangle_verts[2].x, new_text_x) {
                    new_x_str := float_str(`entity.triangle_verts[2].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.triangle_verts[2].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(c_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.triangle_verts[2].y, new_text_y) {
                    new_y_str := float_str(`entity.triangle_verts[2].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }
    case .POLYGON;
        a_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        a_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        a_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(a_label_rect, "a", *my_theme.label_theme); {
            x_str := float_str(`entity.polygon_verts[0].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(a_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[0].x, new_text_x) {
                    new_x_str := float_str(`entity.polygon_verts[0].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.polygon_verts[0].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(a_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[0].y, new_text_y) {
                    new_y_str := float_str(`entity.polygon_verts[0].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }

        b_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        b_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        b_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(b_label_rect, "b", *my_theme.label_theme); {
            x_str := float_str(`entity.polygon_verts[1].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(b_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[1].x, new_text_x) {
                    new_x_str := float_str(`entity.polygon_verts[1].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.polygon_verts[1].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(b_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[1].y, new_text_y) {
                    new_y_str := float_str(`entity.polygon_verts[1].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }

        c_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        c_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        c_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(c_label_rect, "c", *my_theme.label_theme); {
            x_str := float_str(`entity.polygon_verts[2].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(c_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[2].x, new_text_x) {
                    new_x_str := float_str(`entity.polygon_verts[2].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.polygon_verts[2].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(c_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[2].y, new_text_y) {
                    new_y_str := float_str(`entity.polygon_verts[2].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }

        d_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
        `y_pos -= (`label_extents.y + 5);
        d_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
        d_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
        `y_pos -= (`text_extents.y + 10);

        Get_Rect.label(d_label_rect, "d", *my_theme.label_theme); {
            x_str := float_str(`entity.polygon_verts[3].x);
            action_x, new_text_x, state_x := Get_Rect.text_input(d_x_rect, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[3].x, new_text_x) {
                    new_x_str := float_str(`entity.polygon_verts[3].x);
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        } {
            y_str := float_str(`entity.polygon_verts[3].y);
            action_y, new_text_y, state_y := Get_Rect.text_input(d_y_rect, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*`entity.polygon_verts[3].y, new_text_y) {
                    new_y_str := float_str(`entity.polygon_verts[3].y);
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }
    }
}

modify_float_from_string :: (value_ptr: *float32, float_str: string) -> success: bool {
    new_value, ok := parse_float(*float_str);
    if ok {
        value_ptr.* = new_value;
    } else {
        assert(false, "Unable to parse float from string '%'", float_str);
    }
    return ok;
}

modify_string :: (ps: *string, new_value: string) {
    free(ps.*);
    ps.* = copy_string(new_value);
}

// Formats a float and returns the resultant string, using the temporary allocator
float_str :: (f: float32) -> string {
    return tprint("%", formatFloat(f, 2, 0, zero_removal = .NO));
}

draw_action_cursor :: () {
    pos := mouse_pos();
    Simp.set_shader_for_color(true);
    if editor_state.action_state == {
    case .MAKE_AABB;
        p0 := pos + .{-50, 50};
        p1 := pos + .{-50, -50};
        p2 := pos + .{50, -50};
        p3 := pos + .{50, 50};
        Simp.immediate_quad(p0, p1, p2, p3, .{0, 0, 0.7, 0.5});
    case .MAKE_TRI;
        p0 := pos + .{-50, 50};
        p1 := pos + .{-50, -50};
        p2 := pos + .{50, -50};
        Simp.immediate_quad(p0, p0, p1, p2, .{0, 0.7, 0, 0.5});
    case .MAKE_POLY;
        p0 := pos + .{-50, 50};
        p1 := pos + .{-50, -50};
        p2 := pos + .{50, -50};
        p3 := pos + .{50, 50};
        Simp.immediate_quad(p0, p1, p2, p3, .{0.7, 0, 0, 0.5});
    }
}

consume_editor_inputs :: () {
    if is_action_buffered(.EDITOR_SELECT) {
        pos := mouse_position_to_world();
        if editor_state.action_state == {
        case .MAKE_AABB;
            aabb := make_collision_aabb_simple(pos);
            add_thing(*current_room.things, aabb);
            editor_state.action_state = .NIL;
            editor_state.room_dirty = true;
        case .MAKE_TRI;
            tri := make_collision_right_tri(pos);
            add_thing(*current_room.things, tri);
            editor_state.action_state = .NIL;
            editor_state.room_dirty = true;
        case .MAKE_POLY;
            poly := make_collision_poly_square(pos);
            add_thing(*current_room.things, poly);
            editor_state.action_state = .NIL;
            editor_state.room_dirty = true;
        case .MAKE_ENTITY;
            entity := make_character(pos);
            add_thing(*current_room.things, entity);
            editor_state.action_state = .NIL;
            editor_state.room_dirty = true;
        }
    }

    if is_action_held(.EDITOR_LOCK) {
        editor_state.locked = true;
    } else {
        editor_state.locked = false;
    }
}

Editor_Assets :: struct {
    font: *Simp.Dynamic_Font;
}

editor_assets: Editor_Assets;

load_editor_assets :: () {
    editor_assets.font = Simp.get_font_at_size("assets/fonts", "dungeon-mode.ttf", 24);
    assert(editor_assets.font != null);
}

#load "subwindows.jai";
