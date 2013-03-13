#import <map>
#import <OpenGLES/ES2/gl.h>
#import "RFShader.h"

class RFShaderFactory {
    map<pair<string, GLenum>, pair<RFShader*, int> > shaders;
    RFShaderFactory();
    static RFShaderFactory* _instance;
public:
    static RFShaderFactory* shared_instance();
    static void destroy_shared_instance();
    
    GLuint retain_shader(string shader_name, GLenum shader_type);
    void release_shader(string shader_name, GLenum shader_type);
};

static RFShaderFactory* _instance = NULL;