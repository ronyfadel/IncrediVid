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
    
    glBindVertexArrayOES(vao);
    index_count = index_buffer_size / sizeof(unsigned short);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[INDEX_BUFFER]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_buffer_size, index_buffer, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
}

void RFNode::set_attribs()
{
    glBindVertexArrayOES(vao);
    this->set_attribs_impl();
    glBindVertexArrayOES(0);
}

void RFNode::draw()
{
    program->use();
    glBindVertexArrayOES(vao);
    glDrawElements(GL_TRIANGLES, index_count, GL_UNSIGNED_SHORT, 0);
    glBindVertexArrayOES(0);
}

RFNode::~RFNode()
{
    RFProgramFactory::shared_instance()->release_program(program->get_v_shader_name(),
                                                         program->get_f_shader_name());
    glDeleteBuffers(2, vbo);
}