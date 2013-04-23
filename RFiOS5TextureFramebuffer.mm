#import "RFiOS5TextureFramebuffer.h"
#import <OpenGLES/EAGL.h>

CVPixelBufferRef __renderTarget;

RFiOS5TextureFramebuffer::RFiOS5TextureFramebuffer(GLsizei _width, GLsizei _height)
{
    _renderTexture = 0;
    width = _width;
    height = _height;
    
    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &_videoTextureCache);
    if (error)  {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", error);
        return;
    }
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                      1,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs,
                         kCVPixelBufferIOSurfacePropertiesKey,
                         empty);
    
    CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                        kCVPixelFormatType_32BGRA,
                        attrs,
                        &_renderTarget);

    __renderTarget = _renderTarget;
    
    glGenFramebuffers(1, &_id);

    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    // first create a texture from our renderTarget
    // textureCache will be what you previously made with CVOpenGLESTextureCacheCreate
    glActiveTexture(GL_TEXTURE2);
    CVReturn err =
    CVOpenGLESTextureCacheCreateTextureFromImage (
                                                  kCFAllocatorDefault,
                                                  _videoTextureCache,
                                                  _renderTarget,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA, // opengl format
                                                  width,
                                                  height,
                                                  GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &_renderTexture);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d (RFiOS5TextureFramebuffer)", err);
    }
    
    // set the texture up like any other texture
    glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _id);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);
}

RFiOS5TextureFramebuffer::~RFiOS5TextureFramebuffer() {
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = 0;
    }
    if (_renderTarget) {
        CVPixelBufferRelease(_renderTarget);
        _renderTarget = 0;
    }
    if (_renderTexture) {
        CFRelease(_renderTexture);
        _renderTexture = 0;
    }
}