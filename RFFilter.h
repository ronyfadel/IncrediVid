#import <vector>
#import <OpenGLES/ES2/gl.h>
#import "RFNode.h"

static const GLushort indexes[] = {
    0, 1, 2,
    0, 2, 3
};

static const GLfloat vertices_flipped_cropped_tex_coords[] = {
    -1.f, -1.f, 0.f, 0.875f,
    1.f, -1.f, 1.f, 0.875f,
    1.f,  1.f, 1.f, 0.125f,
    -1.f,  1.f, 0.f, 0.125f
};

static const GLfloat vertices_straight_tex_coords[] = {
    -1.f, -1.f, 0.f, 0.f,
    1.f, -1.f, 1.f, 0.f,
    1.f,  1.f, 1.f, 1.f,
    -1.f,  1.f, 0.f, 1.f
};

class RFFilter : public RFNode {
public:
    RFFilter(string v_shader_name, string f_shader_name, bool cropped = false):RFNode(v_shader_name, f_shader_name)
    {
        if (cropped) {
            fill_data((void*)vertices_flipped_cropped_tex_coords, sizeof(vertices_flipped_cropped_tex_coords),
                      (void*)indexes, sizeof(indexes));
        } else {
            fill_data((void*)vertices_straight_tex_coords, sizeof(vertices_straight_tex_coords),
                      (void*)indexes, sizeof(indexes));
        }
//        cropped ? 
//        fill_data((void*)vertices_flipped_cropped_tex_coords, sizeof(vertices_flipped_cropped_tex_coords),
//                  (void*)indexes, sizeof(indexes))
//        :
//        fill_data((void*)vertices_straight_tex_coords, sizeof(vertices_straight_tex_coords),
//                  (void*)indexes, sizeof(indexes));
    }

    virtual void set_attribs()
    {
        GLuint program_id = program->get_id();
        int attrib = glGetAttribLocation(program_id, "position");
        glEnableVertexAttribArray(attrib);
        glVertexAttribPointer(attrib, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
        attrib = glGetAttribLocation(program_id, "tex_coord_in");
        glEnableVertexAttribArray(attrib);
        glVertexAttribPointer(attrib, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (void*) (2 * sizeof(GLfloat)));
    }
};

//class RFLookupFilter : public RFFilter {
//protected:
//    GLuint texture_id;
//public:
//    
//    void drawToFramebuffer(RFFramebuffer* framebuffer)
//    {
//        glActiveTexture(GL_TEXTURE3);
//        glBindTexture(GL_TEXTURE_2D, texture_id);
//        RFFilter::drawToFramebuffer(framebuffer);
//    }
//    
//    RFLookupFilter(string texture_name):RFFilter("copy.vsh", "lookup.fsh")
//    {
//        load_texture(texture_name);
//    }
//    
//    virtual void load_texture(string texture_name)
//    {
//        cout<<texture_name<<endl;
//        string texture_path = get_ios_file_path(texture_name);
//        cout<<texture_path<<endl;
//        
//        UIImage* texture = [UIImage imageWithContentsOfFile:[NSString stringWithCString:texture_path.c_str() encoding:NSASCIIStringEncoding]];
//        
//        // First get the image into your data buffer
//        CGImageRef imageRef = [texture CGImage];
//        NSUInteger width = CGImageGetWidth(imageRef);
//        NSUInteger height = CGImageGetHeight(imageRef);
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
//        NSUInteger bytesPerPixel = 4;
//        NSUInteger bytesPerRow = bytesPerPixel * width;
//        NSUInteger bitsPerComponent = 8;
//        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//                                                     bitsPerComponent, bytesPerRow, colorSpace,
//                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//        CGColorSpaceRelease(colorSpace);
//        
//        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//        CGContextRelease(context);
//        
//        glGenTextures(1, &texture_id);
//        glActiveTexture(GL_TEXTURE3);
//        glBindTexture(GL_TEXTURE_2D, texture_id);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawData);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        
//        free(rawData);
//    }
//    
////    virtual void set_uniforms()
////    {
////        GLuint program_id = program->get_id();
////        glUniform1i(glGetUniformLocation(program_id, "input_texture"), CAPTURED_FRAME_TEXURE);
////        glUniform1i(glGetUniformLocation(program_id, "lookup_texture"), 3);
////    }
//    
//    ~RFLookupFilter(){ glDeleteTextures(1, &texture_id); }
//};
