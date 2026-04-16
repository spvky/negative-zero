Entity :: struct {
    using position: Vector2;
    velocity: Vector2;
    map: *Texture;
}

entities: [..]Entity;

make_entity :: (position: Vector2) {
    print("New Entity\n");
    array_add(*entities, Entity.{position = position, velocity = .{10, 0}, map = *bug_tex});
}

render_entities :: () {
    for e: entities {
        render_sprite_centered(e.map, e.position, .{100, 100}, .{1, 1, 1, 1});
    }
}
