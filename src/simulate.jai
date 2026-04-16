simulate :: (delta: float32) {
    for *e: entities {
        e.position += e.velocity * delta;
    }
}
