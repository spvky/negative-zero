main :: () {
    init_window();
    #if DEV_MODE {
        editor_init();
    }
    init_textures();
    make_entity(.{100, 100});
    while !window.close {
        timestep(#code simulate(tickrate()));
        render();
    }
}

Simp :: #import "Simp";
Input :: #import "Input";
Texture :: Simp.Texture;

#import "Basic";
#import "Math";
#import "File";
#import "Random";
#import "Input";
#import "Window_Creation";
#import "Time"(TICK_RATE = 1.0 / 100.0);

#load "window.jai";
#load "render.jai";
#load "camera.jai";
#load "entities.jai";
#load "simulate.jai";
#load "input.jai";
#load "player.jai";
#load "preload_test.jai";

#if DEV_MODE {
    #load "editor/editor.jai";
}
