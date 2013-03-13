#import <OpenGLES/ES2/glext.h>
#import "RFNode.h"
#import "RFProgramFactory.h"

RFNode::RFNode(string v_shader_name, string f_shader_name)
{
    RFProgramFactory* shared_instance = RFProgramFactory::shared_instance();
    program = shared_instance->retain_program(v_shader_name, f_shader_name);
    glGenBuffers(2, vbo);
    glGenVertexArraysOES(1, &vao);
    
    set_attribs();
    set_uniforms();
}

// indexes are to be unsigned shorts
void RFNode::fill_data(void* array_buffer, GLsizeiptr array_buffer_size,
                       void* index_buffer, GLsizeiptr index_buffer_size)
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo[ARRAY_BUFFER]);
    glBufferData(GL_ARRAY_BUFFER, array_buffer_size, array_buffer, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    index_count = index_buffer_size / sizeof(unsigned short);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[INDEX_BUFFER]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_buffer_size, index_buffer, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void RFNode::draw()
{
    program->use();
    glBindVertexArrayOES(vao);
    glDrawElements(GL_TRIANGLES, index_count, GL_UNSIGNED_SHORT, 0);
    glBindVertexArrayOES(0);
}

//#import "RFProgram.h"
//#import "RFFramebuffer.h"
//#import "Vertices.h"
//
//class RFFilterProgram : public RFProgram {
//protected:
//    GLuint attribs[NUM_ATTRIBUTES], vbo;
//    RFFramebuffer* framebuffer;
//public:
//    RFFilterProgram(string v_shader_name,
//                    string f_shader_name,
//                    RFFramebuffer* framebuffer,
//                    bool flipped);
//    void use();
//    void draw();
//    ~RFFilterProgram();
//};
//
//#import "RFFilterProgram.h"
//
//
//RFFilterProgram::RFFilterProgram(string v_shader_name,
//                                 string f_shader_name,
//                                 RFFramebuffer* framebuffer,
//                                 bool flipped):
//RFProgram(v_shader_name, f_shader_name)
//{
//    this->framebuffer = framebuffer;
//
//    RFProgram::use();
//
//    glGenBuffers(1, &vbo);
//    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//
//    if (flipped) {
//        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_flipped_tex_coords), vertices_flipped_tex_coords, GL_STATIC_DRAW);
//    } else {
//        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_straight_tex_coords), vertices_straight_tex_coords, GL_STATIC_DRAW);
//    }
//
//    attribs[ATTRIB_VERTEX] = glGetAttribLocation(get_id(), "position");
//    attribs[ATTRIB_TEXCOORD] = glGetAttribLocation(get_id(), "tex_coord_in");
//    glEnableVertexAttribArray(attribs[ATTRIB_VERTEX]);
//    glEnableVertexAttribArray(attribs[ATTRIB_TEXCOORD]);
//    glVertexAttribPointer(attribs[ATTRIB_VERTEX], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
//    glVertexAttribPointer(attribs[ATTRIB_TEXCOORD], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (void*) (2 * sizeof(GLfloat)));
//}
//
//void RFFilterProgram::use()
//{
//    RFProgram::use();
//    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//    glEnableVertexAttribArray(attribs[ATTRIB_VERTEX]);
//    glEnableVertexAttribArray(attribs[ATTRIB_TEXCOORD]);
//    glVertexAttribPointer(attribs[ATTRIB_VERTEX], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
//    glVertexAttribPointer(attribs[ATTRIB_TEXCOORD], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (void*) (2 * sizeof(GLfloat)));
//}
//
//void RFFilterProgram::draw()
//{
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//}
//
//RFFilterProgram::~RFFilterProgram()
//{
//    glDeleteBuffers(1, &vbo);
//}
//
