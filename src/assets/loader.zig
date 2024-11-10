const c = @import("../c.zig").c;

pub fn load_image(file_name: [*c]const u8, width: *i32, height: *i32, channels: *i32) ![*c]c.stbi_uc{
    const image = c.stbi_load(file_name, width, height, channels, c.STBI_rgb_alpha);
    if (image == null){
        return error.FailedToLoad;
    }
    return image;
}

pub fn free_image(image: *anyopaque) void{
    c.stbi_image_free(image);
}
