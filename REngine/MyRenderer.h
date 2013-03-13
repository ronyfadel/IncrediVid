#import "RFRenderer.h"
#import "RFProgram.h"
#import "RFFramebuffer.h"
#import "RF2DPreviewNode.h"

enum {
    BLUR_PROGRAM,
    TOON_PROGRAM,
    NUM_PROGRAMS
};

enum {
    BLUR_FRAMEBUFFER,
    VIEW_FRAMEBUFFER,
    NUM_FRAMEBUFFERS
};

class MyRenderer : public RFRenderer {
protected:
    RFProgram* programs[NUM_PROGRAMS];
    RFFramebuffer* framebuffers[NUM_FRAMEBUFFERS];
public:
    MyRenderer(UIView* superview);
    void render();
    RFProgram** get_programs();
};

//class RFNode {
//protected:
//    GLuint vbo[NUM_BUFFERS], vao;
//    GLsizei index_count;
//    RFProgram* program;
//    
//public:
//    RFNode(string v_shader_name, string f_shader_name);
//    void fill_data(void* array_buffer, GLsizeiptr array_buffer_size,
//                   void* index_buffer, GLsizeiptr index_buffer_size);
//    void draw();
//    void set_attribs();
//    virtual void set_attribs_impl() = 0;
//    virtual void set_uniforms()     = 0;
//    
//    virtual ~RFNode();
//};



//#import "RFToonProgram.h"
//
//RFToonProgram::RFToonProgram(RFFramebuffer* framebuffer, bool flipped):
//    RFFilterProgram("preview.vsh", "toon.fsh", framebuffer, flipped)
//{
//
//}
//
//void RFToonProgram::set_uniforms() {
//    glUniform1i(glGetUniformLocation(get_id(), "original_texture"), 0);
//    glUniform1i(glGetUniformLocation(get_id(), "blurred_texture"), 1);
//    glUniform1f(glGetUniformLocation(get_id(), "texel_width"), 1.f / framebuffer->get_width());
//    glUniform1f(glGetUniformLocation(get_id(), "texel_height"), 1.f / framebuffer->get_height());
//}

//#import "RFBlurProgram.h"
//
//RFBlurProgram::RFBlurProgram(RFFramebuffer* framebuffer, bool flipped):
//    RFFilterProgram("preview.vsh", "blur.fsh", framebuffer, flipped)
//{
//
//}
//
//void RFBlurProgram::set_uniforms() {
//    // Setting uniforms (texture) / texel width, height
//    glUniform1i(glGetUniformLocation(get_id(), "input_texture"), 0);
//    glUniform1f(glGetUniformLocation(get_id(), "texel_width"), 1.f / framebuffer->get_width());
//    glUniform1f(glGetUniformLocation(get_id(), "texel_height"), 1.f / framebuffer->get_height());
//}
//
