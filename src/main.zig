const c              = @import("c.zig").c;
const std            = @import("std");
const Game           = @import("game.zig").Game;
const Renderer       = @import("renderer/renderer.zig").Renderer;
const Shader         = @import("renderer/shader.zig").Shader;
const Buffer         = @import("renderer/buffer.zig").Buffer;
const VertexArray    = @import("renderer/vertex_array.zig").VertexArray;
const Texture        = @import("renderer/texture.zig").Texture;
const Image          = @import("assets/image.zig").Image;
const AnimatedSprite = @import("renderer/objects/animated_sprite.zig").AnimatedSprite;
const Camera         = @import("game/camera.zig").Camera;
const Input          = @import("input/input.zig").Input;
const za             = @import("zalgebra");

pub fn main() !void{
    const allocator = std.heap.page_allocator;

    const vertices = [_]f32{
        -0.5, -0.5, -0.5, 0.0, 0.0,
        0.5,  -0.5, -0.5, 1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        -0.5, 0.5,  -0.5, 0.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 0.0,

        -0.5, -0.5, 0.5,  0.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        -0.5, 0.5,  0.5,  0.0, 1.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,

        -0.5, 0.5,  0.5,  1.0, 0.0,
        -0.5, 0.5,  -0.5, 1.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,
        -0.5, 0.5,  0.5,  1.0, 0.0,

        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, 0.5,  0.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,

        -0.5, -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, -0.5, 1.0, 1.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,

        -0.5, 0.5,  -0.5, 0.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5, 0.5,  0.5,  0.0, 0.0,
        -0.5, 0.5,  -0.5, 0.0, 1.0,
    };

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0){
        std.debug.print("Failed to init sdl\n", .{});
        return;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow(
        "SDL2",
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        800,
        600,
        c.SDL_WINDOW_OPENGL | c.SDL_WINDOW_SHOWN | c.SDL_WINDOW_RESIZABLE
    );
    if (window == null){
        std.debug.print("Failed to init window\n", .{});
        return;
    }
    defer c.SDL_DestroyWindow(window);

    const context = c.SDL_GL_CreateContext(window);
    if (context == null){
        std.debug.print("Failed to create a context\n", .{});
        return;
    }
    defer c.SDL_GL_DeleteContext(context);

    if (c.gladLoadGLLoader(c.SDL_GL_GetProcAddress) == 0){
        std.debug.print("Failed to init glad", .{});
        return;
    }

    var renderer = try Renderer.init(allocator);
    defer renderer.deinit();

    var game = try Game.init(allocator, &renderer, window);
    defer game.deinit();

    var vertex_array = VertexArray.init();
    defer vertex_array.deinit();

    var buffer = Buffer.init();
    defer buffer.deinit();

    vertex_array.bind();
    buffer.buffer_data(@sizeOf(f32) * vertices.len, &vertices);

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    const tex_offset: [*c]c_uint = (3 * @sizeOf(f32));
    c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), tex_offset);
    c.glEnableVertexAttribArray(1);

    var image = try Image.init(allocator, "assets/dices.png");
    defer image.deinit();

    var texture = Texture.init(image);
    defer texture.deinit();

    //const view = za.lookAt(za.Vec3.new(0.0, 0.0, -3.0), za.Vec3.zero(), za.Vec3.up());
    const model = za.Mat4.fromTranslate(za.Vec3.new(1, 1, 1));

    c.glEnable(c.GL_DEPTH_TEST);
    game.renderer.shader.use();
    game.renderer.shader.set_mat4fv("model", model);
    //game.renderer.shader.set_mat4fv("view", view);

    var running = true;
    var event: c.SDL_Event = undefined;
    var debug_octree = false;

    while (running){
        while (c.SDL_PollEvent(&event) != 0){
            if (event.type == c.SDL_QUIT){
                running = false;
            }
        }

        game.input.update();
        game.camera_manager.update();

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    
        c.glActiveTexture(c.GL_TEXTURE0);
        texture.bind();

        game.renderer.shader.use();
        game.renderer.shader.set_mat4fv("projection", game.camera.get_projection());
        game.renderer.shader.set_mat4fv("view", game.camera.get_view());
        // vertex_array.bind();
        //
        // c.glDrawArrays(c.GL_TRIANGLES, 0, 36);
        //
        if (game.input.is_released(c.SDL_SCANCODE_G)){
            debug_octree = !debug_octree;
        }

        game.octree.render(debug_octree, game.renderer);

        c.SDL_GL_SwapWindow(window);
    }
}
