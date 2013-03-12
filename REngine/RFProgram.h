#import "RFShader.h"
#import <iostream>
using namespace std;

class RFProgram {
protected:
    GLuint _id, v_shader_id, f_shader_id;
    
    void link();
    void check_link_status(GLuint _id);
public:
    
    RFProgram(string v_shader_name, string f_shader_name);
    RFProgram(GLuint v_shader_id, GLuint f_shader_id);
    
    virtual void set_uniforms() = 0;
    virtual void draw() = 0;
    
    GLuint get_id();
    virtual void use();
    virtual ~RFProgram();
};