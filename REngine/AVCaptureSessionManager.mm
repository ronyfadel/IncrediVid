#import "AVCaptureSessionManager.h"
#import "MyRenderer.h"

@interface AVCaptureSessionManager(){
@private
    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVOpenGLESTextureRef _lumaTexture;
//    CVOpenGLESTextureRef _chromaTexture;
}
- (void)setupSession;
- (void)cleanUpTextures;
@end

@implementation AVCaptureSessionManager

- (id)init
{
    if((self = [super init]))
    {
        [self setupSession];
    }
    return self;
}

- (void)setupSession 
{
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &_videoTextureCache);
    if (err) 
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return;
    }
    
    // allocating the session
    captureSession = [[AVCaptureSession alloc] init];
    
    // starting configuration
    [captureSession beginConfiguration];
    
#warning check session preset for other devices
// setting the session preset (other option: captureSession.sessionPreset = AVCaptureSessionPresetMedium)
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    // config input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [captureSession addInput:input];
    if (!input) { NSLog(@"bad input %d %s", __LINE__, __FUNCTION__); exit(1); }
    
    // config output
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    output.alwaysDiscardsLateVideoFrames = YES;
    [captureSession addOutput:output];

#warning check the dispatch queue
    // queue to process samples
// option 1
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
//    [output setSampleBufferDelegate:self queue:queue];
//    dispatch_release(queue);
    
// option 2
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
#warning changed (BGRA => Luminance)
    // pixel format
    output.videoSettings =  [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//    output.videoSettings =  [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
//                                                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];

    
    // configuring connection
    AVCaptureConnection* connection = (AVCaptureConnection*)[output.connections objectAtIndex:0];

    // setting capture rate at 30 FPS (kCMTimeZero for maximum FPS)
    connection.videoMinFrameDuration = CMTimeMake(1, 30);
    if([connection isVideoOrientationSupported])
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    // committing configuration
    [captureSession commitConfiguration];
    
    // starts session
    [captureSession startRunning];
}

/*
 delegate routine for processing samples
 to use sample buffer outside this scope, have
 to CFRetain then CFRelease it
 Autorelease pool necessary, sampleBuffer is added to
 autorelease pool, if its processing was not fast enough
 pool cleaned up every once in a while
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
    CVReturn err;
    
    if (!_videoTextureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }
        
    [self cleanUpTextures];
    
    // CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
    // optimally from CVImageBufferRef.
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    GLsizei _textureWidth = CVPixelBufferGetWidth(imageBuffer),
            _textureHeight = CVPixelBufferGetHeight(imageBuffer);
    
    glActiveTexture(GL_TEXTURE0);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
                                                       _videoTextureCache,
                                                       imageBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       _textureWidth,
                                                       _textureHeight,
                                                       GL_RGBA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_lumaTexture);
    if (err) 
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }   

    glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);


////#######################################################################################################
//    // Y-plane
//    glActiveTexture(GL_TEXTURE0);
//    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
//                                                       _videoTextureCache,
//                                                       imageBuffer,
//                                                       NULL,
//                                                       GL_TEXTURE_2D,
//                                                       GL_RED_EXT,
//                                                       _textureWidth,
//                                                       _textureHeight,
//                                                       GL_RED_EXT,
//                                                       GL_UNSIGNED_BYTE,
//                                                       0,
//                                                       &_lumaTexture);
//    if (err) 
//    {
//        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
//    }   
//    
//    glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
////#######################################################################################################
//    
//    // UV-plane
//    glActiveTexture(GL_TEXTURE1);
//    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
//                                                       _videoTextureCache,
//                                                       imageBuffer,
//                                                       NULL,
//                                                       GL_TEXTURE_2D,
//                                                       GL_RG_EXT,
//                                                       _textureWidth/2,
//                                                       _textureHeight/2,
//                                                       GL_RG_EXT,
//                                                       GL_UNSIGNED_BYTE,
//                                                       1,
//                                                       &_chromaTexture);
//    if (err) 
//    {
//        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
//    }
//    
//    glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
}

- (void)cleanUpTextures
{    
    if (_lumaTexture)
    {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;        
    }
    
//    if (_chromaTexture)
//    {
//        CFRelease(_chromaTexture);
//        _chromaTexture = NULL;
//    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)dealloc
{
    [captureSession stopRunning], [captureSession release];
    [super dealloc];
}

@end
