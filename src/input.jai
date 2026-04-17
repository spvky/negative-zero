process_input :: () {
    update_window_events();
    action_frame = 0;
    for event: events_this_frame {
        if event.type == .QUIT {
            window.close = true;
            break;
        }

        if event.key_code == .ESCAPE {
            if event.key_pressed window.close = true;
            break;
        }

        if event.key_code == {
        case .ARROW_UP; if event.key_pressed action_frame |= .CAM_UP;
        case .ARROW_DOWN; if event.key_pressed action_frame |= .CAM_DOWN;
        case .ARROW_LEFT; if event.key_pressed action_frame |= .CAM_LEFT;
        case .ARROW_RIGHT; if event.key_pressed action_frame |= .CAM_RIGHT;
        }
    }
    print("%\n", action_frame);
}

Input_Action :: enum_flags u32 {
    CAM_UP;
    CAM_DOWN;
    CAM_LEFT;
    CAM_RIGHT;
    MOVE_RIGHT;
    MOVE_LEFT;
    MOVE_UP;
    MOVE_DOWN;
    JUMP;
}

action_frame: Input_Action;

is_action_pressed :: (action: Input_Action) -> bool {
    return (action_frame & action) == action;
}
