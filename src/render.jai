ASSET_FOLDER :: "assets";

bug_tex: Texture;

init_textures :: () {
    success: bool;
    bug_tex, success = load_texture_from_file("bug1.png");
    assert(success, "Failed to load the damn texture\n");
}

render :: () {
    #if DEV_MODE {
        Simp.clear_render_target(0, 1, 0, 1);
    } else {
        Simp.clear_render_target(0.2, 0.1, 0.5, 1);
    }
    #if DEV_MODE {
        render_editor_grid();
    }
    // Draw Scene
    render_collision_shape(tri);
    render_collision_shape(aabb);
    render_square(cam_relative_position(.{0, 0}), .{10, 10});
    render_entities();
    Simp.swap_buffers(n_window.resource);

    #if DEV_MODE {
        render_editor_ui();
    }
}

load_texture_from_file :: (name: string) -> Texture, bool {
    filename := tprint("%/%", ASSET_FOLDER, name);
    result: Texture;
    success := Simp.texture_load_from_file(*result, filename);
    return result, success;
}

render_sprite_centered :: (texture: *Texture, pos: Vector2, size: Vector2, color: Vector4, theta := 0.0) {
    Simp.set_shader_for_images(texture);
    h := Vector2.{size.x * 0.5, 0};
    v := Vector2.{0, size.y * 0.5};

    radians := (TAU / 360.0) * theta;

    h = rotate(h, radians);
    v = rotate(v, radians);

    p0 := pos - h - v;
    p1 := pos + h - v;
    p2 := pos + h + v;
    p3 := pos - h + v;
    Simp.immediate_quad(p0, p1, p2, p3, color);
    // Simp.immediate_quad(.{0, 200}, .{100, 200}, .{100, 300}, .{0, 300}, .{1, 1, 1, 1});
}

render_square :: (position: Vector2, extents: Vector2) {
    Simp.set_shader_for_color();
    he := extents * 0.5;
    p0 := position + .{-he.x, he.y};
    p1 := position + .{he.x, he.y};
    p2 := position + .{he.x, -he.y};
    p3 := position + .{-he.x, -he.y};
    Simp.immediate_quad(p0, p1, p2, p3, .{0, 0, 0, 1});
}

angle_between :: (start: Vector2, end: Vector2) -> float32 {
    return atan2(end.y - start.y, end.x - start.x);
}

render_line :: (start: Vector2, end: Vector2, thickness := 5.0) {
    Simp.set_shader_for_color(true);
    dist := distance(start, end);
    theta := angle_between(start, end);
    center := (start + end) * 0.5;

    h := Vector2.{dist * 0.5, 0};
    v := Vector2.{0, thickness * 0.5};

    h = rotate(h, theta);
    v = rotate(v, theta);

    p0 := center - h + v;
    p1 := center + h + v;
    p2 := center + h - v;
    p3 := center - h - v;

    line_color: Vector4 = .{0, 0, 0, 0.3};
    Simp.immediate_quad(p0, p1, p2, p3, line_color);
}
