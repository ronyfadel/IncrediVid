#import <map>
#import <OpenGLES/ES2/gl.h>
#import "RFShader.h"

class RFShaderFactory {
    map<pair<string, GLenum>, pair<RFShader*, int> > shaders;
    static RFShaderFactory* _instance;
    
    RFShaderFactory(){}
    RFShaderFactory(RFShaderFactory const&);
    void operator=(RFShaderFactory const&);
public:
    static RFShaderFactory* shared_instance();
    static void destroy_shared_instance();
    
    GLuint retain_shader(string shader_name, GLenum shader_type);
    void release_shader(string shader_name, GLenum shader_type);
};