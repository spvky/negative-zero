Input_Action :: enum {
    CAM_UP;
    CAM_DOWN;
    CAM_LEFT;
    CAM_RIGHT;
    MOVE_RIGHT;
    MOVE_LEFT;
    MOVE_UP;
    MOVE_DOWN;
    JUMP;
    EDITOR_SELECT;
    EDITOR_LOCK;
}

init_input :: () {
    init_input_buffer();
    register_input(.CAM_UP, .ARROW_UP);
    register_input(.CAM_DOWN, .ARROW_DOWN);
    register_input(.CAM_RIGHT, .ARROW_RIGHT);
    register_input(.CAM_LEFT, .ARROW_LEFT);
    register_input(.EDITOR_LOCK, .CTRL);
    register_input(.EDITOR_SELECT, .MOUSE_BUTTON_LEFT);
}

process_input :: (delta: float32) {
    for event: events_this_frame {
        if event.key_code == .ESCAPE && event.key_pressed {
            n_window.close = true;
            break;
        }

        #if DEV_MODE {
            Get_Rect.getrect_handle_event(event);
        }
    }
    update_buffer(delta);
}
#import "InputBuffer"(ACTION_TYPE = Input_Action);
