#import <OpenGLES/ES2/gl.h>
#import "RFProgram.h"

enum {
    VBO,
    VAO,
    NUM_BUFFERS
};

class RFNode {
protected:
    GLuint buffers[NUM_BUFFERS];
    RFProgram* program;
    
public:
    RFNode(string v_shader_name, string f_shader_name);
};

