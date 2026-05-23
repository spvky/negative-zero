Thing :: struct {
    using position: Vector2;
    kind: Thing_Kind;
    using collision_data: Collision_Data;
    #overlay (collision_data) using character_data: Character_Data;
}

Thing_Kind :: enum {
    NIL :: 0;
    CHARACTER :: 1;
    COLLISION :: 2;
}

Character_Data :: struct @thing_data {
    velocity: Vector2; @editor_display
    size := Vector2.{100, 100}; @editor_display
    jonesy: Vector2; @editor_display
    map: *Texture;
}

// Because of the nature of putting arrays through my codegen proc these will be handled manually until that becomes annoying, leaving the editor display tags here to remind myself
Collision_Data :: struct @thing_data {
    collision_shape: Collision_Shape;
    is_sensor := false;
    verts: void;
    polygon_verts: [4]Vector2; @editor_display
    #overlay (polygon_verts) aabb_extents: [2]Vector2; @editor_display
    #overlay (polygon_verts) triangle_verts: [3]Vector2; @editor_display
}

Collision_Shape :: enum {
    TRIANGLE;
    POLYGON;
    AABB;
}

Character_Kind :: enum {
    BUG :: 0;
}

get_collision_vertex_collection :: (thing: *Thing) -> []Vector2 {
    collection: []Vector2;
    if thing.collision_shape == {
    case .AABB;
        collection = thing.aabb_extents;
    case .TRIANGLE;
        collection = thing.triangle_verts;
    case .POLYGON;
        collection = thing.polygon_verts;
    }
    return collection;
}

apply_thing_velocity :: (delta: float32) {
    for *t: current_room.things {
        if t.kind == .CHARACTER {
            t.position += t.velocity * delta;
        }
    }
}

#load "rendering.jai";
#load "collision.jai";
#load "creation.jai";
#load "manager.jai";
#if DEV_MODE {
    #load "dev.jai";
}
