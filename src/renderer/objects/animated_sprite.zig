const std         = @import("std");
const c           = @import("../../c.zig").c;
const Image       = @import("../../assets/image.zig").Image;
const Renderer    = @import("../renderer.zig").Renderer;
const Buffer      = @import("../buffer.zig").Buffer;
const VertexArray = @import("../vertex_array.zig").VertexArray;
const Texture     = @import("../texture.zig").Texture;

// const vertices = [_]f32{
//     // Positions        // Texture Coords
//     -0.5, -0.5, 0.0,   0.0, 1.0,  // Triangle 1 - Bottom-left
//     0.5, -0.5, 0.0,   1.0, 1.0,  // Triangle 1 - Bottom-right
//     0.5,  0.5, 0.0,   1.0, 0.0,  // Triangle 1 - Top-right
//
//     -0.5,  0.5, 0.0,   0.0, 0.0,  // Triangle 2 - Top-left
//     0.5,  0.5, 0.0,   1.0, 0.0,  // Triangle 2 - Top-right
//     -0.5, -0.5, 0.0,   0.0, 1.0   // Triangle 2 - Bottom-left
// };

pub const Props = struct{
    frames: u32
};

pub const AnimatedSprite = struct{
    allocator:     std.mem.Allocator,
    image:         *Image,
    props:         Props,
    buffer:        Buffer,
    texture:       Texture,
    vertex_array:  VertexArray,
    current_frame: u32 = 1,

    pub fn init(allocator: std.mem.Allocator, image: *Image, props: Props) !AnimatedSprite{
        // var vertex_array_ref = VertexArray.init();
        // var vertex_array = try allocator.create(VertexArray);
        // vertex_array = &vertex_array_ref;
        // vertex_array.bind();
        //
        // c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), null);
        // c.glEnableVertexAttribArray(0);
        //
        // const tex_offset: [*c]c_uint = (3 * @sizeOf(f32));
        // c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), tex_offset);
        // c.glEnableVertexAttribArray(1);

        const buffer = Buffer.init();
        const texture = Texture.init(image);

        return AnimatedSprite{
            .image = image,
            .props = props,
            .buffer = buffer,
            .texture = texture,
            .vertex_array = VertexArray.init(),
            .allocator = allocator
        };
    }

    pub fn deinit(self: *AnimatedSprite) void{
        self.buffer.deinit();
    }

    pub fn update(self: *AnimatedSprite, renderer: *Renderer) void{
        self.vertex_array.deinit();
        self.vertex_array = VertexArray.init();
        self.buffer.deinit();
        self.buffer = Buffer.init();

        const f_curr_frame: f32 = @floatFromInt(self.current_frame);
        const f_frames: f32 = @floatFromInt(self.props.frames);
        const frame_width: f32 = 1/f_frames;

        const curr_width: f32 = frame_width*f_curr_frame+frame_width;
        const curr_pos: f32 = frame_width*f_curr_frame;

        const vertices = [_]f32{
            // Positions        // Texture Coords
            -0.5, -0.5, 0.0,   curr_pos, 1,  // Triangle 1 - Bottom-left
            0.5, -0.5, 0.0,   curr_width, 1,  // Triangle 1 - Bottom-right
            0.5,  0.5, 0.0,   curr_width, 0,  // Triangle 1 - Top-right

            -0.5,  0.5, 0.0,   curr_pos, 0,  // Triangle 2 - Top-left
            0.5,  0.5, 0.0,   curr_width, 0,  // Triangle 2 - Top-right
            -0.5, -0.5, 0.0,   curr_pos, 1   // Triangle 2 - Bottom-left
        };


        self.vertex_array.bind();
        self.buffer.buffer_data(@sizeOf(f32) * vertices.len, &vertices);

        renderer.shader.use();

        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        const tex_offset: [*c]c_uint = (3 * @sizeOf(f32));
        c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), tex_offset);
        c.glEnableVertexAttribArray(1);
        renderer.shader.set_int("texture1", 0);

        self.texture.bind();

        c.glDrawArrays(c.GL_TRIANGLES, 0, 6);
    }
};
