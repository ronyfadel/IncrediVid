#import <vector>
#import <OpenGLES/ES2/gl.h>
#import "RFNode.h"
#import "RFTextureFactory.h"

enum BUFFER_DATA {
    STRAIGHT,
    FLIPPED,
    FLIPPED_CROPPED
};

static float i4_to_shave_off = 0.055f;
#if HD
    static float i5_to_shave_off = 0.f;
#else
    static float i5_to_shave_off = 0.11f;
#endif

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
    -1.f, -1.f, i5_to_shave_off, 1,
    1.f, -1.f, 1.f - i5_to_shave_off, 1,
    1.f,  1.f, 1.f - i5_to_shave_off, 0,
    -1.f,  1.f, i5_to_shave_off, 0
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

class RFTextureFilter : public RFFilter {
protected:
    GLuint texture_id;
    string texture_name;
public:
    
    void drawToFramebuffer(RFFramebuffer* framebuffer)
    {
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texture_id);
        RFFilter::drawToFramebuffer(framebuffer);
    }
    
    RFTextureFilter(string v_shader_name,
                    string f_shader_name,
                    string texture_name,
                   BUFFER_DATA mode = STRAIGHT):RFFilter(v_shader_name, f_shader_name, mode)
    {
        this->texture_name = texture_name;
        texture_id = RFTextureFactory::shared_instance()->retain_texture(texture_name, PNG_FILE);
    }
    
    RFTextureFilter(string v_shader_name,
                    string f_shader_name,
                    string texture_name,
                    unsigned char *texture_data,
                    NSUInteger width,
                    NSUInteger height,
                    BUFFER_DATA mode = STRAIGHT):RFFilter(v_shader_name, f_shader_name, mode)
    {
        this->texture_name = texture_name;
        texture_id = RFTextureFactory::shared_instance()->retain_texture(texture_name, LUMINANCE_MEMORY, texture_data, width, height);
    }
    
    ~RFTextureFilter()
    {
        RFTextureFactory::shared_instance()->release_texture(texture_name);
    }
};

