main :: () {
    init_window();
    init_textures();
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
#import "Random";
#import "Window_Creation";

#load "window.jai";
#load "render.jai";
#load "entities.jai";
#load "preload_test.jai";
