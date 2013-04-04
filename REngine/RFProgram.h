#import "RFShader.h"
#import <iostream>
using namespace std;

class RFProgram {
protected:
    GLuint _id, v_shader_id, f_shader_id;
    string v_shader_name, f_shader_name;
    
    void link();
    void check_link_status(GLuint _id);
public:
    
    RFProgram(string v_shader_name, string f_shader_name);
        
    GLuint get_id();
    string get_v_shader_name();
    string get_f_shader_name();
    virtual void use();
    virtual void stop_using();
    virtual ~RFProgram();
};