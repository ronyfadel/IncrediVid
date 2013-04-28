#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "RFFramebuffer.h"
#import "RFTexture.h"

// we should have many render targets, to solve
// concurrency issues of rendering to texture
// while reading from the preceding texture's attached
// pixel buffer before it to save video frame
#define PIXEL_BUFFER_COUNT 1

class RFiOS5TextureFramebuffer : public RFFramebuffer {
protected:
    GLuint texture_num;
    CVOpenGLESTextureRef _renderTexture[PIXEL_BUFFER_COUNT];
    CVPixelBufferRef _renderPixelBuffer[PIXEL_BUFFER_COUNT];
    int current_renderTarget_index;
    GLuint _ids[PIXEL_BUFFER_COUNT];
    CVOpenGLESTextureCacheRef _videoTextureCache;
public:
    RFiOS5TextureFramebuffer(GLsizei _width, GLsizei _height, GLuint _texture_num);
    void use();
    CVPixelBufferRef get_pixel_buffer_ref();
    virtual ~RFiOS5TextureFramebuffer();
};