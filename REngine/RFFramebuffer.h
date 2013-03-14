#import <OpenGLES/ES2/gl.h>

class RFFramebuffer {
protected:
    GLuint _id;
    GLsizei width, height;
    
    void test_for_completeness();
    
public:
    virtual void use();
    GLsizei get_width();
    GLsizei get_height();
    virtual ~RFFramebuffer();
};