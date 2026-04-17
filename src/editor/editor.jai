editor_init :: () {
    print("Hello from the editor\n");
}

render_editor_grid :: () {
    for i: 0..20 {
        fi := cast(float32)i;
        render_line(.{0, fi * 100}, .{1920, fi * 100});
        render_line(.{fi * 100, 0}, .{fi * 100, 1080});
    }
}
