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
void RFNode::fill_data(void* array_buffer, GLsizeiptr array_buffer_size, void* index_buffer, GLsizeiptr index_buffer_size)
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

void RFNode::bind_uniform_to_vec4_value(string uniform_name, float value[4])
{
    uniform_value tmp;
    memcpy(tmp.v, value, 4 * sizeof(float));
    bind_uniform_to_value(uniform_name, tmp, VEC4_UNIFORM);
}

void RFNode::bind_uniform_to_int_value(string uniform_name, int value)
{
    uniform_value tmp;
    tmp.i = value;
    bind_uniform_to_value(uniform_name, tmp, INTEGER_UNIFORM);
}

void RFNode::bind_uniform_to_float_value(string uniform_name, float value)
{
    uniform_value tmp;
    tmp.f = value;
    bind_uniform_to_value(uniform_name, tmp, FLOAT_UNIFORM);
}

void RFNode::bind_uniform_to_value(string uniform_name, uniform_value value, uniform_type type)
{
    uniforms[uniform_name] = make_pair(value, type);
}

void RFNode::set_uniforms()
{
    for (auto i = uniforms.begin(); i != uniforms.end(); ++i) {
        GLuint uniform_id = glGetUniformLocation(program->get_id(), i->first.c_str());
        
        switch (i->second.second) {
            case INTEGER_UNIFORM:
                glUniform1i(uniform_id, i->second.first.i);
                break;
            case FLOAT_UNIFORM:
                glUniform1f(uniform_id, i->second.first.f);
                break;
            case VEC4_UNIFORM:
                glUniform4fv(uniform_id, 1, i->second.first.v);
                break;
            default:
                break;
        }
    }
}

void RFNode::drawToFramebuffer(RFFramebuffer* framebuffer)
{
    framebuffer->use();
    program->use();
    set_uniforms();
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo[ARRAY_BUFFER]);
    glDrawElements(GL_TRIANGLES, index_count, GL_UNSIGNED_SHORT, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    program->stop_using();
}

RFNode::~RFNode()
{
    RFProgramFactory::shared_instance()->release_program(program->get_v_shader_name(), program->get_f_shader_name());
    glDeleteBuffers(2, vbo);
    glDeleteVertexArraysOES(1, &vao);
}
