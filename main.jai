main :: () {
    init_window();
    while !window.close {
        render();
    }
}

Simp :: #import "Simp";
Input :: #import "Input";
Texture :: Simp.Texture;

#import "Basic";
#import "Math";
#import "File";
#import "Window_Creation";

#load "window.jai";
#load "render.jai";
#load "entities.jai";
#load "preload_test.jai";
