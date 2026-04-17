Camera :: struct {
    target: Vector2;
    zoom := 1.0;
    move_delta: Vector2;
}

camera: Camera;

cam_relative_position :: (pos: Vector2) -> Vector2 {
    return pos - camera.target;
}
