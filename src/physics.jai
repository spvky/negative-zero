Interval :: struct {
    min: float32;
    max: float32;
}

Collision :: struct {
    normal: Vector2;
    depth: float32;
}

Circle :: struct {
    center: Vector2;
    radius: float32;
}

interval_overlap :: (a: Interval, b: Interval) -> (overlaps: bool, amount: float32) {
    overlaps := a.min <= b.max && b.min <= a.max;
    amount: float32 = min(a.max, b.max) - max(a.min, b.min);
    return overlaps, amount;
}

vertices_axis_interval :: (vertices: []Vector2, axis: Vector2) -> Interval {
    interval: Interval;
    interval.min = FLOAT32_INFINITY;
    interval.max = -FLOAT32_INFINITY;
    for v: vertices {
        dot := dot(v, axis);
        if dot < interval.min {
            interval.min = dot;
        }
        if dot > interval.max {
            interval.max = dot;
        }
    }
    return interval;
}

circle_axis_interval :: (c: Circle, axis: Vector2) -> Interval {
    return Interval.{min = dot(c.center + (-axis * c.radius), axis), max = dot(c.center + (axis * c.radius), axis)};
}
