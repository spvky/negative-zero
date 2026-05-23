thing_editor_picking :: (tm: *Thing_Room_Manager) {
    pos := mouse_position_to_world();
    if is_action_held(.EDITOR_SELECT) {
        if editor_state.locked {
            thing := get_thing_ptr(tm, editor_state.selected_entity_idx);
            verts := get_collision_vertex_collection(thing);
            for v, i: verts {
                adjusted_v := thing.position + v;
                if distance(pos, adjusted_v) < 30 {
                    editor_state.held_entity_component_idx = xx i;
                    editor_state.held_component = true;
                    break;
                }
            }
        } else {
            for thing, i: tm {
                if distance(pos, thing.position) < 30 && !editor_state.held_entity {
                    editor_state.held_entity = true;
                    editor_state.held_entity_idx = xx i;
                    editor_state.selected_entity_idx = xx i;
                    break;
                }
            }
        }
    } else {
        editor_state.held_entity = false;
        editor_state.held_component = false;
    }
    if editor_state.held_entity {
        thing := get_thing_ptr(tm, editor_state.held_entity_idx);
        thing.position = pos;
    }
    if editor_state.held_component {
        thing := get_thing_ptr(tm, editor_state.held_entity_idx);
        comp_ptr := *thing.polygon_verts[editor_state.held_entity_component_idx];
        comp_ptr.* = pos - thing.position;
    }
}
