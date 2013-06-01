#import <map>
#import <OpenGLES/ES2/gl.h>

using namespace std;

enum RFTEXTURE_TYPE {
    PNG_FILE,
    LUMINANCE_MEMORY
    };

class RFTextureFactory {
    map <string, pair<GLuint, int>> textures;
    static RFTextureFactory* _instance;
    RFTextureFactory(){}
    RFTextureFactory(RFTextureFactory const&);
    void operator=(RFTextureFactory const&);
public:
    static RFTextureFactory* shared_instance();
    static void destroy_shared_instance();

    GLuint retain_texture(string texture_name, RFTEXTURE_TYPE texture_type, unsigned char* texture_data = NULL, int width = 0, int height = 0);
    void release_texture(string texture_name);
};