current_theme: s32 = xx Default_Themes.Default;
my_theme: Overall_Theme; // This gets filled out by calling the Theme_Proc for current_theme.

render_editor_ui :: () {
    Simp.set_shader_for_color();
    current_time := to_float64_seconds(current_time_monotonic());
    w, h := Simp.get_render_dimensions(n_window.resource);
    font := editor_assets.font;
    Get_Rect.ui_per_frame_update(n_window.resource, w, h, current_time);

    // Init themes
    label_theme: Get_Rect.Label_Theme;
    label_theme.font = editor_assets.font;

    k := n_window.height / 45.0;
    pad := cast(float)font.character_height * 1.6;
    r := Get_Rect.get_rect(
                           k, h - k * 2,
                           k, xx font.character_height);
    // mouse_x, mouse_y, success := get_mouse_pointer_position();
    // Pos Display
    {
        r.w = xx Simp.prepare_text(font, "Mesh: ");
        Get_Rect.label(r, "Poisition Goes Here: ", *label_theme);
    }
    r.y -= pad;
    Get_Rect.draw_popups();
}
