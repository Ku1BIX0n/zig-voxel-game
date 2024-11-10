const Mesh        = @import("../renderer/mesh.zig").Mesh;
const std         = @import("std");

pub const Square = struct{
    pub fn init(size: f32) Mesh{
        const vertices = [_]f32{
            -size, -size, -size, 0.0, 0.0,
            size, -size, -size, 1.0, 0.0,
            size,  size, -size, 1.0, 1.0,
            size,  size, -size, 1.0, 1.0,
            -size,  size, -size, 0.0, 1.0,
            -size, -size, -size, 0.0, 0.0,

            -size, -size,  size, 0.0, 0.0,
            size, -size,  size, 1.0, 0.0,
            size,  size,  size, 1.0, 1.0,
            size,  size,  size, 1.0, 1.0,
            -size,  size,  size, 0.0, 1.0,
            -size, -size,  size, 0.0, 0.0,

            -size,  size,  size, 1.0, 0.0,
            -size,  size, -size, 1.0, 1.0,
            -size, -size, -size, 0.0, 1.0,
            -size, -size, -size, 0.0, 1.0,
            -size, -size,  size, 0.0, 0.0,
            -size,  size,  size, 1.0, 0.0,

            size,  size,  size, 1.0, 0.0,
            size,  size, -size, 1.0, 1.0,
            size, -size, -size, 0.0, 1.0,
            size, -size, -size, 0.0, 1.0,
            size, -size,  size, 0.0, 0.0,
            size,  size,  size, 1.0, 0.0,

            -size, -size, -size, 0.0, 1.0,
            size, -size, -size, 1.0, 1.0,
            size, -size,  size, 1.0, 0.0,
            size, -size,  size, 1.0, 0.0,
            -size, -size,  size, 0.0, 0.0,
            -size, -size, -size, 0.0, 1.0,

            -size,  size, -size, 0.0, 1.0,
            size,  size, -size, 1.0, 1.0,
            size,  size,  size, 1.0, 0.0,
            size,  size,  size, 1.0, 0.0,
            -size,  size,  size, 0.0, 0.0,
            -size,  size, -size, 0.0, 1.0,
        };

        return Mesh.init(vertices.len * @sizeOf(f32), vertices.len, &vertices);
    }
};
