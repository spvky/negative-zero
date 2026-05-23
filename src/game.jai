tri: Collision_Shape;
poly: Collision_Shape;
aabb: Collision_Shape;

getrect_captured_mouse: bool;
getrect_captured_keyboard: bool;

Test_Action :: enum {
    Foo;
    Bar;
    Jump;
    Hang;
    Run;
}

main :: () {
    buffer: Input_Buffer(Test_Action);
    print("Buffer Value Size: %\n", buffer.MAP_SIZE);
    init_window();
    init_textures();
    init_input();
    for room_list() {
        _, _, _, filename := path_decomp(it);
        print("%\n", filename);
    }
    #if DEV_MODE {
        editor_init();
    }
    print("Thing Size: %\n", size_of(Thing));
    while !n_window.close {
        update_window_events();
        now := seconds_since_init();
        delta: float64 = now - last_time;
        current_dt = cast(float)delta;

        if current_dt > DT_MAX current_dt = DT_MAX;

        last_time = now;
        process_input(current_dt);
        simulate(current_dt);
        render();
        reset_temporary_storage();
    }
}

current_dt: float = 0.016667;
last_time: float64;
DT_MAX: float: 0.15;
Simp :: #import "Simp";
Input :: #import "Input";
Texture :: Simp.Texture;
Get_Rect :: #import "GetRect";
File_Util :: #import "File_Utilities";

#import "Basic";
#import "Math";
#import "File";
#import "Random";
#import "Input";
#import "String";
#import "Window_Creation";

#load "window.jai";
#load "render.jai";
#load "camera.jai";
#load "thing/core.jai";
#load "room/core.jai";
#load "simulate.jai";
#load "input.jai";
#load "player.jai";
#load "preload_test.jai";
