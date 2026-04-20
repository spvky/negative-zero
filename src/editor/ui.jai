render_editor_ui :: () {
    Simp.set_shader_for_color();
    current_time := to_float64_seconds(current_time_monotonic());
    w, h := Simp.get_render_dimensions(window.resource);
    Get_Rect.ui_per_frame_update(window.resource, w, h, current_time);

    // Init themes
    label_theme: Get_Rect.Label_Theme;
    label_theme.font = editor_assets.font;
}
