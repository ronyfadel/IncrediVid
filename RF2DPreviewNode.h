#import "RFNode.h"

static const GLfloat vertices_flipped_tex_coords[] = {
    -1.f, -1.f, 0.f, 1.f,
    1.f, -1.f, 1.f, 1.f,
    1.f,  1.f, 1.f, 0.f,
    -1.f,  1.f, 0.f, 0.f
};

static const GLfloat vertices_straight_tex_coords[] = {
    -1.f, -1.f, 0.f, 0.f,
    1.f, -1.f, 1.f, 0.f,
    1.f,  1.f, 1.f, 1.f,
    -1.f,  1.f, 0.f, 1.f
};

static const GLushort indexes[] = {
    0,1,2,
    2,3,0
};

class RF2DPreviewNode : public RFNode {
protected:
    GLsizei width, height;
public:
    RF2DPreviewNode(string v_shader_name,
                    string f_shader_name,
                    GLsizei _width,
                    GLsizei _height):
    RFNode(v_shader_name, f_shader_name),
    width(_width),
    height(_height)
    {
    }
    
    void set_uniforms()
    {
        GLuint program_id = program->get_id();
        glUniform1i(glGetUniformLocation(program_id, "input_texture"), 0);
        glUniform1f(glGetUniformLocation(program_id, "texel_width"), 1.f / width);
        glUniform1f(glGetUniformLocation(program_id, "texel_height"), 1.f / height);
    }
    
    void set_attribs_impl()
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

class RFBlurPreviewNode : public RF2DPreviewNode {
    RFBlurPreviewNode(GLsizei _width, GLsizei _height):
    RF2DPreviewNode("preview.vsh", "blur.fsh", _width, _height)
    {
        fill_data((void*)vertices_flipped_tex_coords,
                  sizeof(vertices_flipped_tex_coords),
                  (void*)indexes,
                  sizeof(indexes));
    }
};

class RFToonPreviewNode : public RF2DPreviewNode {
    RFToonPreviewNode(GLsizei _width, GLsizei _height):
    RF2DPreviewNode("preview.vsh", "blur.fsh", _width, _height)
    {
        fill_data((void*)vertices_straight_tex_coords,
                  sizeof(vertices_straight_tex_coords),
                  (void*)indexes,
                  sizeof(indexes));
    }
    
    void set_uniforms()
    {
        RF2DPreviewNode::set_uniforms();
        GLuint program_id = program->get_id();
        glUniform1i(glGetUniformLocation(program_id, "blurred_texture"), 1);
    }
};