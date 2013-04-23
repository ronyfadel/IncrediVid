#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "RFFramebuffer.h"
#import "RFTexture.h"

class RFiOS5TextureFramebuffer : public RFFramebuffer {
protected:
    CVOpenGLESTextureRef renderTexture;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureCacheRef _videoTextureCache;
public:
    RFiOS5TextureFramebuffer(GLsizei _width, GLsizei _height);
    virtual void use();
    CVPixelBufferRef get_pixel_buffer_ref();
    virtual ~RFiOS5TextureFramebuffer();
};