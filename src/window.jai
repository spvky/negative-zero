window: Window;

Window :: struct {
    resource: Window_Type;
    width := 1920;
    height := 1080;
    name := "Goofin With Jai";
    close := false;
}

init_window :: () {
    window.resource = create_window(window.width, window.height, window.name);
    Simp.set_render_target(window.resource);
}
