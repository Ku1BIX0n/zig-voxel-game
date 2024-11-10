const std    = @import("std");
const Shader = @import("shader.zig").Shader;

pub const Renderer = struct{
    shader: Shader, 

    pub fn init(allocator: std.mem.Allocator) !Renderer{
        const shader = try Shader.init(allocator, "vertex.glsl", "fragment.glsl");

        return Renderer{
            .shader = shader
        };
    }

    pub fn deinit(self: *Renderer) void{
        self.shader.deinit();
    }
};
