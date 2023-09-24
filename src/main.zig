const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));

const SCREEN_WIDTH = 1200;
const SCREEN_HEIGHT = 700;

pub fn main() !void {
    _ = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "Ping Pong Classic",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH,
        SCREEN_HEIGHT,
        sdl.SDL_WINDOW_SHOWN,
    );
    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(
        window,
        -1,
        sdl.SDL_RENDERER_PRESENTVSYNC,
    );
    defer sdl.SDL_DestroyRenderer(renderer);

    var running = true;
    while (running) {
        var event = sdl.SDL_Event{ .type = 0 };
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => running = false,
                else => {},
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00); // Black color
        _ = sdl.SDL_RenderClear(renderer);

        defer sdl.SDL_RenderPresent(renderer);
        defer sdl.SDL_Delay(16);
    }
}
