const std = @import("std");
const c   = @import("../c.zig").c;

pub const Image = struct{
    width:     i32,
    height:    i32,
    channels:  i32,
    data:      [*c]u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, file_name: [*c]const u8) !*Image{
        var image = try allocator.create(Image);

        image.data = c.stbi_load(file_name, &image.width, &image.height, &image.channels, c.STBI_rgb_alpha);

        if (image.data == null){
            return error.FailedToLoad;
        }

        image.allocator = allocator;

        return image;
    }

    pub fn deinit(self: *Image) void{
        c.stbi_image_free(self.data);
        self.allocator.destroy(self);
    }
};
