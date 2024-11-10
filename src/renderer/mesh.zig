const VertexArray = @import("vertex_array.zig").VertexArray;
const Buffer      = @import("buffer.zig").Buffer;
const c           = @import("../c.zig").c;

pub const Mesh = struct{
    vbo:      Buffer,
    vao:      VertexArray,
    vertices: u32,

    pub fn init(vertices_size: usize, vertices_amount: u32, vertices: ?*const anyopaque) Mesh{
        var vbo = Buffer.init();
        var vao = VertexArray.init();

        vao.bind();
        vbo.buffer_data(vertices_size, vertices);

        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        const tex_offset: [*c]c_uint = (3 * @sizeOf(f32));
        c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), tex_offset);
        c.glEnableVertexAttribArray(1);

        return .{
            .vbo = vbo,
            .vao = vao,
            .vertices = vertices_amount,
        };
    }

    pub fn draw(self: *Mesh) void{
        self.vao.bind();
        c.glDrawArrays(c.GL_TRIANGLES, 0, @intCast(self.vertices));
    }

    pub fn deinit(self: *Mesh) void{
        self.vbo.deinit();
        self.vao.deinit();
    }
};
