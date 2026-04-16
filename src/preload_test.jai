Collider :: struct {
    min, max: Vector2;
}

colliders: [10]Collider;

write_collision_to_file :: () {
    file, success := file_open("assets/collision.col", true);
    assert(success, "Failed to open file for writing\n");

    for i: 0..9 {
        min := Vector2.{random_get_zero_to_one() * -5, random_get_zero_to_one() * -5};
        max := Vector2.{random_get_zero_to_one() * 5, random_get_zero_to_one() * 5};
        colliders[i] = .{min = min, max = max};
    }
    defer file_close(*file);

    file_write(*file, *colliders, size_of(type_of(colliders)));
}
