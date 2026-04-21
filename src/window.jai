n_window: Window;

Window :: struct {
    resource: Window_Type;
    width := 1920;
    height := 1080;
    name := "Goofin With Jai";
    close := false;
}

init_window :: () {
    n_window.resource = create_window(n_window.width, n_window.height, n_window.name);
    Simp.set_render_target(n_window.resource);
}
