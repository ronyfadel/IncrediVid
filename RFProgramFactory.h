#import <map>
#import <OpenGLES/ES2/gl.h>
#import "RFProgram.h"

class RFProgramFactory {
    map<pair<string, string>, pair<RFProgram*, int> > programs;
    RFProgramFactory();
    static RFProgramFactory* _instance;
public:
    static RFProgramFactory* shared_instance();
    static void destroy_shared_instance();
    
    RFProgram* retain_program(string v_shader_name, string f_shader_name);
    void release_program(string v_shader_name, string f_shader_name);
};

static RFProgramFactory* _instance = NULL;