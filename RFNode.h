#import <OpenGLES/ES2/gl.h>
#import "RFProgram.h"

enum {
    ARRAY_BUFFER,
    INDEX_BUFFER,
    NUM_BUFFERS
};

class RFNode {
protected:
    GLuint vbo[NUM_BUFFERS], vao;
    GLsizei index_count;
    RFProgram* program;
    
public:
    RFNode(string v_shader_name, string f_shader_name);
    void fill_data(void* array_buffer, GLsizeiptr array_buffer_size,
                   void* index_buffer, GLsizeiptr index_buffer_size);
    virtual void draw();
    virtual RFNode* setup();
    virtual void set_attribs()  = 0;
    virtual void set_uniforms() = 0;
    virtual ~RFNode();
};