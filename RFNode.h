#import <OpenGLES/ES2/gl.h>
#import <map>
#import "RFProgram.h"
#import "RFFramebuffer.h"

enum {
    ARRAY_BUFFER,
    INDEX_BUFFER,
    NUM_BUFFERS
};

enum uniform_type {
    INTEGER_UNIFORM,
    FLOAT_UNIFORM,
    UNIFORM_TYPE_NUM
};

union uniform_value {
    int i;
    float f;
};

class RFNode {
private:
    virtual void bind_uniform_to_value(string uniform_name, uniform_value value, uniform_type type);
    
protected:
    GLuint vbo[NUM_BUFFERS], vao;
    GLsizei index_count;
    RFProgram* program;
    map <string, pair<uniform_value, uniform_type> > uniforms;
public:
    RFNode(string v_shader_name, string f_shader_name);
    void fill_data(void* array_buffer, GLsizeiptr array_buffer_size, void* index_buffer, GLsizeiptr index_buffer_size);
    virtual void drawToFramebuffer(RFFramebuffer* framebuffer);
    virtual RFNode* setup();
    virtual void set_attribs()  = 0;
    virtual void set_uniforms();
    virtual void bind_uniform_to_int_value(string uniform_name, int value);
    virtual void bind_uniform_to_float_value(string uniform_name, float value);
    virtual ~RFNode();
};