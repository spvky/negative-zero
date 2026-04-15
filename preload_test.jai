Collider :: struct {
    min, max: Vector2;
}

colliders: [10]Collider;

write_collision_to_file :: () {
    file, success := file_open("assets/collision.col", true);
    #assert (success, "Failed to open file for writing");
    defer file_close(*file);

    file_write(*file, *colliders, size_of(colliders));
}
