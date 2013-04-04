#import <vector>
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
    0, 1, 2,
    0, 2, 3
};

class RFFilter : public RFNode {
protected:
    GLsizei width, height;
    RFFramebuffer* framebuffer;
public:
    RFFilter(string v_shader_name, string f_shader_name, RFFramebuffer* _framebuffer):
        RFNode(v_shader_name, f_shader_name)
    {
        framebuffer = _framebuffer;
        width = framebuffer->get_width();
        height = framebuffer->get_height();
    }
    
    virtual void draw()
    {
        framebuffer->use();
        RFNode::draw();
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
    
    virtual void set_uniforms()
    {
        GLuint program_id = program->get_id();
        glUniform1i(glGetUniformLocation(program_id, "input_texture"), 0);
        glUniform1f(glGetUniformLocation(program_id, "texel_width"), 1.f / width);
        glUniform1f(glGetUniformLocation(program_id, "texel_height"), 1.f / height);
    }
};

class RFBlurFilter : public RFFilter {
public:
    RFBlurFilter(RFFramebuffer* _framebuffer):
    RFFilter("preview.vsh", "blur.fsh", _framebuffer)
    {
        fill_data((void*)vertices_straight_tex_coords, sizeof(vertices_straight_tex_coords), (void*)indexes, sizeof(indexes));
    }
};

class RFToonFilter : public RFFilter {
public:
    RFToonFilter(RFFramebuffer* _framebuffer):
    RFFilter("preview.vsh", "toon.fsh", _framebuffer)
    {
        fill_data((void*)vertices_flipped_tex_coords, sizeof(vertices_flipped_tex_coords), (void*)indexes, sizeof(indexes));
    }
    
    virtual void set_uniforms()
    {
        RFFilter::set_uniforms();
        GLuint program_id = program->get_id();
        glUniform1i(glGetUniformLocation(program_id, "blurred_texture"), 1);
        glUniform1f(glGetUniformLocation(program_id, "coefficient"), 1.f);
    }
};


class RFFilterCollection {
protected:
    vector<RFFilter*> filter_list;
public:
    void add_filter(RFFilter* filter){ filter_list.push_back(filter); }
    void draw() { for (auto i = filter_list.begin(); i != filter_list.end(); ++i) (*i)->draw(); }
};





