#import <vector>
#import <OpenGLES/ES2/gl.h>
#import "RFNode.h"

static unsigned char vintage_lookup_table [] = {0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 15, 15, 15, 16, 16, 17, 17, 18, 19, 19, 20, 20, 21, 22, 23, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 38, 39, 40, 42, 43, 45, 46, 48, 49, 51, 53, 54, 56, 58, 60, 61, 63, 65, 67, 69, 71, 73, 76, 78, 80, 82, 84, 86, 89, 91, 93, 96, 98, 100, 103, 105, 107, 110, 112, 114, 117, 119, 121, 124, 126, 129, 131, 133, 136, 138, 140, 142, 145, 147, 149, 151, 153, 156, 158, 160, 162, 164, 166, 168, 170, 172, 174, 176, 177, 179, 181, 183, 185, 186, 188, 189, 191, 193, 194, 196, 197, 199, 200, 201, 203, 204, 205, 207, 208, 209, 210, 211, 212, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 223, 224, 225, 226, 227, 228, 228, 229, 230, 231, 231, 232, 233, 234, 234, 235, 236, 236, 237, 238, 238, 239, 239, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 248, 248, 249, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 55, 56, 57, 58, 59, 60, 61, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 76, 77, 78, 79, 81, 82, 83, 84, 86, 87, 88, 89, 91, 92, 93, 95, 96, 97, 98, 100, 101, 102, 104, 105, 106, 108, 109, 110, 112, 113, 114, 116, 117, 118, 120, 121, 122, 124, 125, 126, 128, 129, 130, 132, 133, 134, 136, 137, 138, 139, 141, 142, 143, 145, 146, 147, 149, 150, 151, 152, 154, 155, 156, 157, 159, 160, 161, 162, 164, 165, 166, 167, 168, 170, 171, 172, 173, 174, 175, 177, 178, 179, 180, 181, 182, 183, 184, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 207, 208, 209, 210, 211, 212, 213, 214, 214, 215, 216, 217, 218, 218, 219, 220, 221, 222, 222, 223, 224, 225, 225, 226, 227, 227, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 235, 236, 237, 237, 238, 239, 239, 240, 240, 241, 241, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 255, 53, 53, 53, 54, 54, 55, 55, 55, 56, 56, 57, 57, 57, 58, 58, 59, 59, 59, 60, 60, 61, 61, 62, 62, 62, 63, 63, 64, 64, 65, 65, 65, 66, 66, 67, 67, 68, 68, 69, 69, 70, 70, 71, 71, 72, 72, 73, 73, 74, 74, 75, 75, 76, 76, 77, 77, 78, 78, 79, 79, 80, 81, 81, 82, 82, 83, 83, 84, 85, 85, 86, 86, 87, 88, 88, 89, 89, 90, 91, 91, 92, 93, 93, 94, 95, 95, 96, 97, 97, 98, 99, 99, 100, 101, 101, 102, 103, 103, 104, 105, 105, 106, 107, 108, 108, 109, 110, 110, 111, 112, 113, 113, 114, 115, 116, 116, 117, 118, 118, 119, 120, 121, 121, 122, 123, 124, 124, 125, 126, 127, 127, 128, 129, 130, 130, 131, 132, 133, 133, 134, 135, 135, 136, 137, 138, 138, 139, 140, 141, 141, 142, 143, 143, 144, 145, 146, 146, 147, 148, 148, 149, 150, 150, 151, 152, 152, 153, 154, 154, 155, 156, 156, 157, 158, 158, 159, 160, 160, 161, 162, 162, 163, 163, 164, 165, 165, 166, 166, 167, 168, 168, 169, 169, 170, 170, 171, 172, 172, 173, 173, 174, 174, 175, 175, 176, 176, 177, 177, 178, 178, 179, 179, 180, 180, 181, 181, 182, 182, 183, 183, 184, 184, 185, 185, 186, 186, 186, 187, 187, 188, 188, 189, 189, 189, 190, 190, 191, 191, 192, 192, 192, 193, 193, 194, 194, 194, 195, 195, 196, 196, 196, 197, 197, 198, 198, 199};

//static unsigned char vintage_lookup_table [] = {34, 34, 34, 34, 35, 35, 36, 36, 36, 37, 37, 38, 38, 38, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 42, 42, 42, 43, 43, 43, 44, 44, 44, 45, 45, 45, 46, 46, 47, 47, 47, 47, 47, 48, 48, 49, 50, 50, 51, 51, 52, 53, 53, 53, 54, 55, 56, 57, 58, 59, 60, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 73, 73, 75, 76, 78, 79, 80, 82, 84, 86, 86, 88, 90, 92, 93, 95, 97, 99, 101, 103, 105, 106, 108, 111, 112, 114, 117, 118, 120, 123, 125, 126, 129, 131, 132, 135, 137, 138, 141, 143, 145, 147, 149, 151, 153, 155, 157, 159, 161, 163, 164, 166, 169, 170, 172, 174, 176, 177, 179, 181, 183, 184, 186, 187, 189, 190, 192, 194, 195, 196, 197, 199, 201, 202, 203, 204, 206, 207, 208, 209, 210, 211, 213, 214, 215, 216, 216, 217, 219, 220, 221, 222, 222, 223, 224, 225, 226, 227, 227, 228, 229, 229, 230, 231, 231, 232, 233, 234, 234, 235, 235, 236, 236, 237, 238, 238, 239, 240, 240, 241, 241, 242, 242, 242, 243, 243, 244, 244, 245, 245, 246, 246, 247, 248, 248, 248, 248, 249, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 56, 57, 58, 59, 60, 61, 62, 64, 65, 66, 67, 68, 69, 71, 72, 73, 74, 75, 77, 78, 79, 80, 82, 83, 84, 85, 87, 88, 89, 90, 92, 93, 94, 96, 97, 98, 99, 101, 102, 103, 105, 106, 107, 109, 110, 111, 113, 114, 114, 116, 117, 118, 120, 121, 122, 124, 125, 126, 128, 129, 130, 132, 133, 134, 136, 137, 138, 139, 141, 142, 143, 145, 146, 147, 149, 150, 151, 152, 154, 155, 156, 157, 159, 160, 161, 162, 164, 165, 166, 167, 168, 170, 171, 172, 173, 174, 175, 177, 178, 179, 180, 181, 182, 183, 184, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 207, 208, 209, 210, 211, 212, 213, 214, 214, 215, 216, 217, 218, 218, 219, 220, 221, 222, 222, 223, 224, 225, 225, 226, 227, 227, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 235, 236, 237, 237, 238, 239, 239, 240, 240, 241, 241, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 255, 73, 73, 73, 73, 73, 74, 74, 74, 75, 75, 76, 76, 76, 77, 77, 78, 78, 78, 79, 79, 80, 80, 81, 81, 81, 82, 82, 82, 82, 83, 83, 83, 84, 84, 85, 85, 86, 86, 87, 87, 88, 88, 89, 89, 90, 90, 91, 91, 91, 91, 92, 92, 93, 93, 94, 94, 95, 95, 96, 96, 97, 98, 98, 99, 99, 100, 100, 100, 101, 101, 102, 102, 103, 104, 104, 105, 105, 106, 107, 107, 108, 109, 109, 110, 110, 110, 111, 112, 112, 113, 114, 114, 115, 116, 116, 117, 118, 118, 119, 119, 119, 120, 121, 122, 122, 123, 124, 124, 125, 126, 127, 127, 128, 128, 129, 129, 130, 131, 131, 132, 133, 134, 134, 135, 136, 137, 137, 137, 138, 139, 139, 140, 141, 142, 142, 143, 144, 145, 145, 146, 146, 146, 147, 148, 149, 149, 150, 151, 152, 152, 153, 154, 154, 155, 155, 156, 156, 157, 158, 158, 159, 160, 160, 161, 162, 162, 163, 164, 164, 164, 165, 165, 166, 167, 167, 168, 169, 169, 170, 171, 171, 172, 172, 173, 173, 173, 174, 174, 175, 176, 176, 177, 177, 178, 178, 179, 180, 180, 181, 181, 182, 182, 182, 182, 183, 183, 184, 184, 185, 185, 186, 186, 187, 187, 188, 188, 189, 189, 190, 190, 191, 191, 191, 191, 192, 192, 192, 193, 193, 194, 194, 195, 195, 195, 196, 196, 197, 197, 198, 198, 198, 199, 199, 200, 200, 200, 200, 200, 201, 201, 201, 202, 202, 203, 203, 204};

//static unsigned char vintage_lookup_table [256 * 3] = {0};

enum BUFFER_DATA {
    STRAIGHT,
    FLIPPED,
    FLIPPED_CROPPED
};

static const GLushort indexes[] = {
    0, 1, 2,
    0, 2, 3
};

static const GLfloat vertices_straight_tex_coords[] = {
    -1.f, -1.f, 0.f, 0.f,
    1.f, -1.f, 1.f, 0.f,
    1.f,  1.f, 1.f, 1.f,
    -1.f,  1.f, 0.f, 1.f
};

static const GLfloat vertices_flipped_tex_coords[] = {
    -1.f, -1.f, 0.f, 1.f,
    1.f, -1.f, 1.f, 1.f,
    1.f,  1.f, 1.f, 0.f,
    -1.f,  1.f, 0.f, 0.f
};

static const GLfloat vertices_flipped_cropped_tex_coords[] = {
    -1.f, -1.f, 0.055f, 1,
    1.f, -1.f, 1.f - 0.055f, 1,
    1.f,  1.f, 1.f - 0.055f, 0,
    -1.f,  1.f, 0.055f, 0
};

class RFFilter : public RFNode {
public:
    RFFilter(string v_shader_name, string f_shader_name, BUFFER_DATA mode = STRAIGHT):RFNode(v_shader_name, f_shader_name)
    {
        switch (mode) {
            case STRAIGHT:
                fill_data((void*)vertices_straight_tex_coords, sizeof(vertices_straight_tex_coords),
                          (void*)indexes, sizeof(indexes));
                break;
            case FLIPPED:
                fill_data((void*)vertices_flipped_tex_coords, sizeof(vertices_flipped_tex_coords),
                          (void*)indexes, sizeof(indexes));
                break;
            case FLIPPED_CROPPED:
                fill_data((void*)vertices_flipped_cropped_tex_coords, sizeof(vertices_flipped_cropped_tex_coords),
                          (void*)indexes, sizeof(indexes));
                break;
            default:
                break;
        }
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

class RFLookupFilter : public RFFilter {
protected:
    GLuint texture_id;
public:
    
    void drawToFramebuffer(RFFramebuffer* framebuffer)
    {
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texture_id);
        RFFilter::drawToFramebuffer(framebuffer);
    }
    
    RFLookupFilter(string texture_name, BUFFER_DATA mode = STRAIGHT, string f_shader_name = "lookup.fsh"):RFFilter("copy.vsh", f_shader_name, mode)
    {
        load_texture(texture_name);
    }
    
    virtual void load_texture(string texture_name)
    {
        cout<<texture_name<<endl;
        string texture_path = get_ios_file_path(texture_name);
        cout<<texture_path<<endl;
        
        UIImage* texture = [UIImage imageWithContentsOfFile:[NSString stringWithCString:texture_path.c_str() encoding:NSASCIIStringEncoding]];
        
        // First get the image into your data buffer
        CGImageRef imageRef = [texture CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        
        glGenTextures(1, &texture_id);
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texture_id);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawData);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        free(rawData);
    }
    
//    virtual void set_uniforms()
//    {
//        GLuint program_id = program->get_id();
//        glUniform1i(glGetUniformLocation(program_id, "input_texture"), CAPTURED_FRAME_TEXURE);
//        glUniform1i(glGetUniformLocation(program_id, "lookup_texture"), 3);
//    }
    
    ~RFLookupFilter(){ glDeleteTextures(1, &texture_id); }
};


class RFLookupTableFilter : public RFFilter {
protected:
    GLuint texture_id;
public:
    
    void drawToFramebuffer(RFFramebuffer* framebuffer)
    {
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texture_id);
        RFFilter::drawToFramebuffer(framebuffer);
    }
    
    RFLookupTableFilter(BUFFER_DATA mode = STRAIGHT):RFFilter("copy.vsh", "lookup_table.fsh", mode)
    {
        load_texture();
    }
    
    virtual void load_texture()
    {
        
        NSUInteger width = 256;
        NSUInteger height = 3;

        glGenTextures(1, &texture_id);
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texture_id);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, vintage_lookup_table);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    //    virtual void set_uniforms()
    //    {
    //        GLuint program_id = program->get_id();
    //        glUniform1i(glGetUniformLocation(program_id, "input_texture"), CAPTURED_FRAME_TEXURE);
    //        glUniform1i(glGetUniformLocation(program_id, "lookup_texture"), 3);
    //    }
    
    ~RFLookupTableFilter(){ glDeleteTextures(1, &texture_id); }
};
