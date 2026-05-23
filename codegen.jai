// Editor Codegen
Editor_Codegen_Field :: struct {
    member_name: string;
    member_type: Type;
    member_type_name: string;
    member_notes: [..]string;
}

PLACEHOLDER_INSERTION_STRING :: #string END
draw_character_data_fields :: () #expand {
	%1
}
END

VEC2_ARRAY_INSPECTOR_STRING :: #string END
%3{
	//1 for the label and 2 for each Vector
	rects: [1 + (%4 * 2)]Get_Rect.Rect;
	rects[0] = Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
  Get_Rect.label(rects[0], "%1", *my_theme.label_theme, identifier = 0);
	`y_pos -= (`label_extents.y + 5);

	for i: 0..%4 {
		rects[i+1] = Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
		rects[i+2] = Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
		`y_pos -= (`text_extents.y + 10);

		{
			x_str := float_str(`entity.%2.x);
			action_x, new_text_x, state_x := Get_Rect.text_input(rects[1], x_str, *my_theme.text_input_theme);
			if action_x & .ENTERED {
					if modify_float_from_string(*`entity.%2[i].x, new_text_x) {
							new_x_str := float_str(`entity.%2[i].x);
					}
			}
			if !state_x.active {
					Get_Rect.reset(state_x);
			}
		}

		{
			y_str := float_str(`entity.%2.y);
			action_y, new_text_y, state_y := Get_Rect.text_input(rects[2], y_str, *my_theme.text_input_theme);
			if action_y & .ENTERED {
					if modify_float_from_string(*`entity.%2[i].y, new_text_y) {
							new_y_str := float_str(`entity.%2[i].y);
					}
			}
			if !state_y.active {
					Get_Rect.reset(state_y);
			}
		}
	}
}
END

VEC2_INSPECTOR_STRING :: #string END
%3{
	rects: [3]Get_Rect.Rect;
	rects[0] = Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
	// shift y_pos when we finish defining rects for a row
	`y_pos -= (`label_extents.y + 5);
	rects[1] = Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
	rects[2] = Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
	`y_pos -= (`text_extents.y + 10);


  Get_Rect.label(rects[0], "%1", *my_theme.label_theme);

	{
		x_str := float_str(`entity.%2.x);
		action_x, new_text_x, state_x := Get_Rect.text_input(rects[1], x_str, *my_theme.text_input_theme);
		if action_x & .ENTERED {
				if modify_float_from_string(*`entity.%2.x, new_text_x) {
						new_x_str := float_str(`entity.%2.x);
				}
		}
		if !state_x.active {
				Get_Rect.reset(state_x);
		}
	}

  {
		y_str := float_str(`entity.%2.y);
		action_y, new_text_y, state_y := Get_Rect.text_input(rects[2], y_str, *my_theme.text_input_theme);
		if action_y & .ENTERED {
				if modify_float_from_string(*`entity.%2.y, new_text_y) {
						new_y_str := float_str(`entity.%2.y);
				}
		}
		if !state_y.active {
				Get_Rect.reset(state_y);
		}
  }
}
END

vec2_inspector_field :: (labels: []string, access_pattern: []string, count: int = 0, condition: string = "") -> string {
    output: String_Builder;
    for i: 0..count {
        print_to_builder(*output, VEC2_INSPECTOR_STRING, labels[i], access_pattern[i], condition);
    }
    return builder_to_string(*output);
}

// Generate the code to handle character data fields
editor_codegen :: (char_fields: []Editor_Codegen_Field, col_fields: []Editor_Codegen_Field) -> string {
    // Build character data proc
    char_data_builder: String_Builder;

    print_to_builder(*char_data_builder, vec2_inspector_field(.["position"], .["position"]));

    for field: char_fields {
        if equal(field.member_type_name, "Vector2") {
            print_to_builder(*char_data_builder, vec2_inspector_field(.[field.member_name], .[field.member_name]));
        }
    }

    char_data_string := builder_to_string(*char_data_builder);
    // //////////////////////////

    // Build collision data proc
    col_data_builder: String_Builder;
    for field: col_fields {
        contains_array := contains(field.member_type_name, "]");
        if equal(field.member_type_name, "Vector2") {
            print_to_builder(*char_data_builder, vec2_inspector_field(.[field.member_name], .[field.member_name]));
        }
        if contains_array {
            typename, depth := parse_array_type(field.member_type_name);
        }
    }

    col_data_string := builder_to_string(*col_data_builder);

    final_string := tprint(PLACEHOLDER_INSERTION_STRING, char_data_string);
    return final_string;
}

parse_array_type :: (type_name: string) -> string, int {
    parse_array_depth :: (input: string) -> int {
        chunks := split(input, "[");
        array_depth := parse_int(*chunks[1]);
        return array_depth;
    }
    chunks := split(type_name, "] ");
    type_string := chunks[1];
    array_depth := parse_array_depth(chunks[0]);
    return type_string, array_depth;
}

math :: #import "Math";
