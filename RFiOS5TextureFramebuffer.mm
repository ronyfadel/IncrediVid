#import "RFiOS5TextureFramebuffer.h"
#import <OpenGLES/EAGL.h>
#import <string.h>
#import <iostream>

CVPixelBufferRef __renderTarget;

RFiOS5TextureFramebuffer::RFiOS5TextureFramebuffer(GLsizei _width, GLsizei _height)
{
    width = _width;
    height = _height;
    current_renderTarget_index = 0;

    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &_videoTextureCache);
    if (error)  {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", error);
        return;
    }
    
    for (int i = 0; i < PIXEL_BUFFER_COUNT; ++i) {
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
                            &_renderPixelBuffer[i]);
        glGenFramebuffers(PIXEL_BUFFER_COUNT, _ids);
        
        CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
        
        // first create a texture from our renderTarget
        // textureCache will be what you previously made with CVOpenGLESTextureCacheCreate
        glActiveTexture(GL_TEXTURE2);
        CVReturn err =
        CVOpenGLESTextureCacheCreateTextureFromImage (
                                                      kCFAllocatorDefault,
                                                      _videoTextureCache,
                                                      _renderPixelBuffer[i],
                                                      NULL, // texture attributes
                                                      GL_TEXTURE_2D,
                                                      GL_RGBA, // opengl format
                                                      width,
                                                      height,
                                                      GL_BGRA, // native iOS format
                                                      GL_UNSIGNED_BYTE,
                                                      0,
                                                      &_renderTexture[i]);
        if (err)
        {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d (RFiOS5TextureFramebuffer)", err);
        }
        
        // set the texture up like any other texture
        glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture[i]), CVOpenGLESTextureGetName(_renderTexture[i]));
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _ids[current_renderTarget_index]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                               GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture[i]), 0);
        
    }
#warning to change right away
    __renderTarget = _renderPixelBuffer[0];
    _id = _ids[0];
}

void RFiOS5TextureFramebuffer::use()
{
//    m.lock();
//    __renderTarget = _renderPixelBuffer[current_renderTarget_index];
//    m.unlock();
    
//    current_renderTarget_index = (current_renderTarget_index + 1) % PIXEL_BUFFER_COUNT;
//    _id = _ids[current_renderTarget_index];
    
    RFFramebuffer::use();
}

RFiOS5TextureFramebuffer::~RFiOS5TextureFramebuffer() {
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = 0;
    }
    
    for (int i = 0; i < PIXEL_BUFFER_COUNT; ++i) {
        if (_renderPixelBuffer[i]) {
            CVPixelBufferRelease(_renderPixelBuffer[i]);
            _renderPixelBuffer[i] = 0;
        }
        if (_renderTexture[i]) {
            CFRelease(_renderTexture[i]);
            _renderTexture[i] = 0;
        }
    }
}