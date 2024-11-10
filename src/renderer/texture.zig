const c     = @import("../c.zig").c;
const Image = @import("../assets/image.zig").Image;

pub const Texture = struct{
    texture: c.GLuint,

    pub fn init(image: *Image) Texture{
        if (image.data == null){
            @panic("Texture image data is null");
        }

        var texture: c.GLuint = undefined;    

        c.glCreateTextures(c.GL_TEXTURE_2D, 1, &texture);
        c.glBindTexture(c.GL_TEXTURE_2D, texture);
        // c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);	
        // c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
        // c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR_MIPMAP_LINEAR);
        // c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

        c.glTexParameteri( c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST );
        c.glTexParameteri( c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST );
        c.glTexParameteri( c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT );
        c.glTexParameteri( c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT );
        c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, image.width, image.height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, image.data);
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
        
        return Texture{
            .texture = texture
        };
    }

    pub fn bind(self: *Texture) void{
        c.glBindTexture(c.GL_TEXTURE_2D, self.texture);
    }

    pub fn deinit(self: *Texture) void{
        c.glDeleteTextures(1, &self.texture);
    }
};
