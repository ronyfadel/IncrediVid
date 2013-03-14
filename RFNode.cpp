#import <OpenGLES/ES2/glext.h>
#import "RFNode.h"
#import "RFProgramFactory.h"

RFNode::RFNode(string v_shader_name, string f_shader_name)
{
    RFProgramFactory* shared_instance = RFProgramFactory::shared_instance();
    program = shared_instance->retain_program(v_shader_name, f_shader_name);
    glGenBuffers(2, vbo);
    glGenVertexArraysOES(1, &vao);
}

// indexes are to be unsigned shorts
void RFNode::fill_data(void* array_buffer, GLsizeiptr array_buffer_size,
                       void* index_buffer, GLsizeiptr index_buffer_size)
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo[ARRAY_BUFFER]);
    glBufferData(GL_ARRAY_BUFFER, array_buffer_size, array_buffer, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    index_count = index_buffer_size / sizeof(GLushort);
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[INDEX_BUFFER]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_buffer_size, index_buffer, GL_STATIC_DRAW);
    glBindVertexArrayOES(0);
}

RFNode* RFNode::setup()
{
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo[ARRAY_BUFFER]);
    this->set_attribs();
    program->use();
    this->set_uniforms();
    program->stop_using();
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    return this;
}

void RFNode::draw()
{
    program->use();
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo[ARRAY_BUFFER]);
    glDrawElements(GL_TRIANGLES, index_count, GL_UNSIGNED_SHORT, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    program->stop_using();
}

RFNode::~RFNode()
{
    RFProgramFactory::shared_instance()->release_program(program->get_v_shader_name(),
                                                         program->get_f_shader_name());
    glDeleteBuffers(2, vbo);
    glDeleteVertexArraysOES(1, &vao);
}