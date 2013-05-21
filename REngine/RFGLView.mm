#import "RFGLView.h"

#define PREVIEW_POINTS_WIDTH 320
#define PREVIEW_POINTS_HEIGHT 320

@interface RFGLView ()
- (void)setup;
@end

@implementation RFGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)awakeFromNib
{
    [self setup];
}


- (void)setup
{
//    self.frame = CGRectMake(0,
//                            0,
//                            PREVIEW_POINTS_WIDTH,
//                            PREVIEW_POINTS_HEIGHT);
    
    // For retina display
    if([[UIScreen mainScreen] respondsToSelector: NSSelectorFromString(@"scale")])
    {
        if([self respondsToSelector: NSSelectorFromString(@"contentScaleFactor")])
        {
            CGFloat scale = [[UIScreen mainScreen] scale];
            self.contentScaleFactor  = scale;
            self.layer.contentsScale = scale;
        }
    }
    
    // Setting up context
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    eaglContext = [[EAGLContext alloc] initWithAPI:api];
    [EAGLContext setCurrentContext:eaglContext];
    
    ( (CAEAGLLayer*) self.layer ).drawableProperties =
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat, nil]; 

    // Setting up layer
    self.layer.opaque = YES;
}

- (void)update
{
    [eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc
{
    [eaglContext release], eaglContext = nil;
    [super dealloc];
}

@end