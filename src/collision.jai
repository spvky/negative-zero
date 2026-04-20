MAX_SHAPES_PER_ROOM :: 128;

Collision_Shape :: struct {
    kind: Collision_Shape_Kind;
    polygon_verts: [4]Vector2;
    #overlay (polygon_verts) aabb_extents: [2]Vector2;
    #overlay (polygon_verts) triangle_verts: [3]Vector2;
}

Collision_Shape_Kind :: enum {
    Triangle;
    Polygon;
    AABB;
}

// Shapes for a room
Room_Collision_Shapes :: struct {
    items: [MAX_SHAPES_PER_ROOM]Collision_Shape;
    used: [MAX_SHAPES_PER_ROOM]bool;
    next_free: int = 0;
}

for_expansion :: (rs: Room_Collision_Shapes, body: Code, flags: For_Flags) #expand {
    for ok, index: rs.used {
        if !ok continue;
        `it_index := index;
        `it := rs.items[index];
        #insert body;
    }
}

add_collision_shape :: (rs: *Room_Collision_Shapes, shape: Collision_Shape) {
    for i: 0..rs.next_free {
        if !rs.used[i] {
            rs.used[i] = true;
            rs.items[i] = shape;
            return;
        }
    }
    rs.used[rs.next_free] = true;
    rs.items[rs.next_free] = shape;
    rs.next_free += 1;
}

clear_collision_shape_at_index :: (rs: *Room_Collision_Shapes, index: int) {
    rs.items[index] = .{};
    rs.used[index] = false;
}

make_aabb :: (min: Vector2, max: Vector2) -> Collision_Shape {
    aabb: Collision_Shape;
    aabb.kind = .AABB;
    aabb.aabb_extents = .[min, max];
    return aabb;
}

make_tri :: (points: [3]Vector2) -> Collision_Shape {
    tri: Collision_Shape;
    tri.kind = .Triangle;
    tri.triangle_verts = points;
    return tri;
}

make_poly :: (points: [4]Vector2) -> Collision_Shape {
    poly: Collision_Shape;
    poly.kind = .Polygon;
    poly.polygon_verts = points;
    return poly;
}

render_collision_shape :: (s: Collision_Shape) {
    Simp.set_shader_for_color();
    if s.kind == {
    case .Triangle;
        p0 := cam_relative_position(s.triangle_verts[0]);
        p1 := cam_relative_position(s.triangle_verts[1]);
        p2 := cam_relative_position(s.triangle_verts[2]);
        Simp.immediate_quad(p0, p0, p1, p2, .{0, 0.7, 0, 1});

    case .Polygon;
        p0 := cam_relative_position(s.polygon_verts[0]);
        p1 := cam_relative_position(s.polygon_verts[1]);
        p2 := cam_relative_position(s.polygon_verts[2]);
        p3 := cam_relative_position(s.polygon_verts[3]);
        Simp.immediate_quad(p0, p1, p2, p3, .{0.7, 0, 0, 1});

    case .AABB;
        p0: Vector2 = cam_relative_position(.{s.aabb_extents[0].x, s.aabb_extents[0].y});
        p1: Vector2 = cam_relative_position(.{s.aabb_extents[0].x, s.aabb_extents[1].y});
        p2: Vector2 = cam_relative_position(.{s.aabb_extents[1].x, s.aabb_extents[1].y});
        p3: Vector2 = cam_relative_position(.{s.aabb_extents[1].x, s.aabb_extents[0].y});
        Simp.immediate_quad(p0, p1, p2, p3, .{0, 0, 0.7, 1});
    }
}
