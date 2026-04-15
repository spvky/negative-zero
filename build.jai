OUTPUT_EXECUTABLE_NAME := "goofin-with-jai";
#run {
    set_build_options_dc(.{do_output = false});
    #import "Compiler";
    #import "Basic";
    Autorun :: #import "Autorun";
    // Parse args
    args := get_build_options().compile_time_command_line;
    run := array_find(args, "-r");
    // Create Workspace
    w := compiler_create_workspace("Target workspace");
    // Set build options (just output name for now)
    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);
    options.output_executable_name = OUTPUT_EXECUTABLE_NAME;
    set_build_options(options, w);

    // Start compiler intercept loop
    compiler_begin_intercept(w);
    add_build_file("main.jai", w);
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
    if run Autorun.run_build_result_of_workspace(w);
}
