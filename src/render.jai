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
        Simp.clear_render_target(1, 0, 1, 1);
    }
    // Draw Scene
    render_entities();
    Simp.swap_buffers(window.resource);
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

    h = rotate(h, theta);
    v = rotate(v, theta);

    p0 := pos - h - v;
    p1 := pos + h - v;
    p2 := pos + h + v;
    p3 := pos - h + v;
    Simp.immediate_quad(p0, p1, p2, p3, color);
    // Simp.immediate_quad(.{0, 200}, .{100, 200}, .{100, 300}, .{0, 300}, .{1, 1, 1, 1});
}
