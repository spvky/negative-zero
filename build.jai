EXECUTABLE_BASE_NAME := "negative-zero";
#run {
    set_build_options_dc(.{do_output = false});
    #import "Compiler";
    #import "Basic";
    Autorun :: #import "Autorun";
    // Parse args
    args := get_build_options().compile_time_command_line;
    dev := array_find(args, "-dev");
    // Create Workspace
    w := compiler_create_workspace("Target workspace");
    // Set build options (just output name for now)
    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);
    executable_name: string;
    if dev {
        executable_name = tprint("%-dev", EXECUTABLE_BASE_NAME);
    } else {
        executable_name = EXECUTABLE_BASE_NAME;
    }

    options.output_executable_name = executable_name;
    set_build_options(options, w);

    // Start compiler intercept loop
    compiler_begin_intercept(w);
    add_build_file("src/game.jai", w);
    add_build_string(tprint("DEV_MODE :: %;", dev), w);
    while true {
        message := compiler_wait_for_message();
        print("Compiler Message: %\n", message.kind);
        if message.kind == .COMPLETE {
            mc := cast(*Message_Complete)message;
            if mc.error_code != .NONE {
                exit(1);
            }
            break;
        }
    }
    compiler_end_intercept(w);
    print("\n");
}
