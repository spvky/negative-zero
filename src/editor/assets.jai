Editor_Assets :: struct {
    font: *Simp.Dynamic_Font;
}

editor_assets: Editor_Assets;

load_editor_assets :: () {
    editor_assets.font = Simp.get_font_at_size("assets/fonts", "dungeon-mode.ttf", 24);
    assert(editor_assets.font != null);
}
