render_single_thing :: (thing: *Thing) {
    pos := cam_relative_position(thing.position);
    if thing.kind == {
    case .CHARACTER;
        render_sprite_centered(thing.map, pos, thing.size, .{1, 1, 1, 1});
    case .COLLISION;
        edges := get_shape_edges(thing);
        for e: edges {
            origin := pos + e.center;
            render_line(origin, origin + (e.normal * 50), color = .{0.7, 0.5, 0, 1});
        }
        Simp.set_shader_for_color();
        if thing.collision_shape == {
        case .AABB;
            p0 := pos + .{thing.aabb_extents[0].x, thing.aabb_extents[0].y};
            p1 := pos + .{thing.aabb_extents[0].x, thing.aabb_extents[1].y};
            p2 := pos + .{thing.aabb_extents[1].x, thing.aabb_extents[1].y};
            p3 := pos + .{thing.aabb_extents[1].x, thing.aabb_extents[0].y};
            Simp.immediate_quad(p0, p1, p2, p3, .{0, 0, 0.7, 1});
        case .TRIANGLE;
            p0 := pos + thing.triangle_verts[0];
            p1 := pos + thing.triangle_verts[1];
            p2 := pos + thing.triangle_verts[2];
            Simp.immediate_quad(p0, p0, p1, p2, .{0, 0.7, 0, 1});
        case .POLYGON;
            Simp.set_shader_for_images(*bug_tex);
            origin_shift: Vector2 = .{50, -50};
            p0 := pos + thing.polygon_verts[0];
            uv0 := (origin_shift + thing.polygon_verts[0]) / 100;
            p1 := pos + thing.polygon_verts[1];
            uv1 := (origin_shift + thing.polygon_verts[1]) / 100;
            p2 := pos + thing.polygon_verts[2];
            uv2 := (origin_shift + thing.polygon_verts[2]) / 100;
            p3 := pos + thing.polygon_verts[3];
            uv3 := (origin_shift + thing.polygon_verts[3]) / 100;
            Simp.immediate_quad(p0, p1, p2, p3, .{0.7, 0, 0, 1}, uv0, uv1, uv2, uv3);
        }
    }
}

render_things_in_room :: (tm: Thing_Room_Manager) {
    for thing, i: tm {
        pos := cam_relative_position(thing.position);
        render_single_thing(thing);
        #if DEV_MODE {
            selected_entity := i == xx editor_state.selected_entity_idx;
            if selected_entity {
                render_square(pos, .{10, 10}, .{1, 0, 0, 1});
                if editor_state.locked {
                    if thing.kind == .COLLISION {
                        verts := get_collision_vertex_collection(thing);
                        for v: verts {
                            render_square(pos + v, .{10, 10}, .{1, 1, 1, 1});
                        }
                    }
                }
            } else if !selected_entity && !editor_state.locked {
                render_square(pos, .{10, 10}, .{1, 1, 1, 1});
            }
        }
    }
}
