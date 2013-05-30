#import "MainViewController.h"
#import "MyRenderer.h"
#import "RFAnnotationView.h"
#import "RFFilterScrollView.h"
#import "RFGLView.h"
#import "GalleryViewController.h"
#import "SharingViewController.h"
#import "TKAlertCenter.h"
#import "CALayer+Utilities.h"

static void NSLogRect(CGRect rect)
{
    NSLog(@"Origin: (%f, %f) - Size: (%f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

@interface MainViewController () {
#if TARGET_IPHONE_SIMULATOR
    CADisplayLink* displayLink;
#endif
    BOOL didOpenGallery;
}

@property(retain) RFAnnotationView* annotationBubble;
@property(retain) IBOutlet UIButton *chooseFilterButton, *openGalleryButton, *recordButton;
@property(retain) IBOutletCollection(UIButton) NSArray *buttons;

@property UILabel *logoLabel,
                  *elapsedTimeLabel;

@property(retain) NSTimer *elapsedTimeTimer;
@property float elapsedTime;

@property (retain)SharingViewController *sharingViewController;
@property (retain) IBOutlet RFGLView *previewView;

@property (retain)CALayer* haloLayer;


@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recordingWillStart)
                                                     name:@"Recording Will Start"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recordingDidStart)
                                                     name:@"Recording Did Start"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recordingWillStop)
                                                     name:@"Recording Will Stop"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recordingDidStop)
                                                     name:@"Recording Did Stop"
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newFilterChosen:)
                                                     name:@"New Filter Chosen"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(thumbnailReady:)
                                                     name:@"Thumbnail Ready"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    renderer = new MyRenderer(self.previewView);
    [self setupSubviews];
#if ! TARGET_IPHONE_SIMULATOR
    self.captureSessionManager = [[[AVCaptureSessionManager alloc] initWithRenderer:(renderer)] autorelease];
#else
    // Texture 0 is pre-defined image
    string texture_name = "lux.jpg";
    string texture_path = get_ios_file_path(texture_name);
    cout<<texture_path<<endl;
    UIImage* texture = [UIImage imageWithContentsOfFile:[NSString stringWithCString:texture_path.c_str() encoding:NSASCIIStringEncoding]];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [texture CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    GLuint new_tex;
    glGenTextures(1, &new_tex);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, new_tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawData);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 30;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#endif
}

- (void)update
{
    self->renderer->render();
}

- (void)setupSubviews
{
    // halo layer
    self.haloLayer = [CALayer haloLayerWithBounds:self.recordButton.bounds
                                animationDuration:2.0
                               delayBetweenCycles:0.5
                                            radii:@[@80]
                                        fromValue:@1.12
                                          toValue:@1.17];
    // UI
    UIFont *latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    UIFont *latoBlackSmall = [UIFont fontWithName:@"Lato-Black" size:20.0];

    self.logoLabel.font = latoBlack;
    self.elapsedTimeLabel.font = latoBlackSmall;
	self.elapsedTimeLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.35];
    self.elapsedTimeLabel.layer.cornerRadius = 4;
    self.elapsedTimeLabel.layer.opacity = 0;
    
    NSLogRect(self.previewView.frame);
    
    BOOL isScreenSize4Inch = [[UIScreen mainScreen] bounds].size.height == 568;
    if (isScreenSize4Inch) {
        self.previewView.frame = CGRectMake(0, 0, 320, 548);
        
        CGRect currentFrame;
        currentFrame = self.openGalleryButton.frame;
        self.openGalleryButton.frame = CGRectMake(currentFrame.origin.x,
                                                  481 - 20,
                                                  currentFrame.size.width,
                                                  currentFrame.size.height);
        currentFrame = self.chooseFilterButton.frame;
        self.chooseFilterButton.frame = CGRectMake(currentFrame.origin.x,
                                                  481 - 20,
                                                  currentFrame.size.width,
                                                  currentFrame.size.height);
        currentFrame = self.recordButton.frame;
        self.recordButton.frame = CGRectMake(currentFrame.origin.x,
                                             462 - 20,
                                             currentFrame.size.width,
                                             currentFrame.size.height);
    }
    
    // rounding up the 2 bottom buttons
    // masking email button
    UIBezierPath *maskPathTopRight = [UIBezierPath bezierPathWithRoundedRect:self.openGalleryButton.bounds
                                                           byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                                 cornerRadii:CGSizeMake(16.0, 16.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.openGalleryButton.bounds;
    maskLayer.path = maskPathTopRight.CGPath;
    self.openGalleryButton.layer.mask = maskLayer;
    
    UIBezierPath *maskPathTopLeft = [UIBezierPath bezierPathWithRoundedRect:self.chooseFilterButton.bounds
                                                          byRoundingCorners:UIRectCornerTopLeft |UIRectCornerBottomLeft
                                                                cornerRadii:CGSizeMake(16.0, 16.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.chooseFilterButton.bounds;
    maskLayer.path = maskPathTopLeft.CGPath;
    self.chooseFilterButton.layer.mask = maskLayer;
}

- (IBAction)alternateFilterPicker:(id)sender
{
    if (!self.annotationBubble) {
        self.annotationBubble = [[[RFAnnotationView alloc] initWithFrame:CGRectMake(-5,
                                                                                    self.chooseFilterButton.frame.origin.y - 110,
                                                                                    330,
                                                                                    110)] autorelease];
        self.annotationBubble.layer.opacity = 0;
        NSString* file = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
        NSArray* filtersInfo = [NSArray arrayWithContentsOfFile:file];
        
        
        
        RFFilterScrollView *scrollView = [[[RFFilterScrollView alloc] initWithFrame:CGRectMake(8, 10, 315, 70)
                                                                        filtersInfo:filtersInfo] autorelease];
        [self.annotationBubble addSubview:scrollView];
    }
    
    if (self.annotationBubble.layer.opacity == 0) {
        [self.view addSubview:self.annotationBubble];
    }
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.annotationBubble.layer.opacity = 1 - self.annotationBubble.layer.opacity;
                     }
                     completion:^(BOOL finished){
                         if (self.annotationBubble.layer.opacity == 0) {
                             [self.annotationBubble removeFromSuperview];
                         }
                     }];
}

- (void)setUpViewIsRecording:(BOOL)recording
{
    for (UIButton* button in self.buttons) {
        button.enabled = !recording;
    }

    if (recording) {
        if (self.annotationBubble.layer.opacity) {
            [self alternateFilterPicker:nil];
        }
        [self setButtonHaloLayerVisible:YES];
        self.elapsedTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                 target:self
                                                               selector:@selector(updateElapsedTime)
                                                               userInfo:nil
                                                                repeats:YES];
        self.elapsedTime = 0;
        self.elapsedTimeLabel.text = @"00:00";
    } else {
        [self.elapsedTimeTimer invalidate];
        self.elapsedTime = 0;
        [self setButtonHaloLayerVisible:NO];
    }
    
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (UIButton* button in self.buttons) {
                             button.layer.opacity = 1.0 - button.layer.opacity;
                         }
                         self.elapsedTimeLabel.layer.opacity = 1.0 - self.elapsedTimeLabel.layer.opacity;

                     }
                     completion:^(BOOL finished){}];
}

- (void)setButtonHaloLayerVisible:(BOOL)visible
{
    visible ? [self.recordButton.layer addSublayer:self.haloLayer] : [self.haloLayer removeFromSuperlayer];
}

- (void)newFilterChosen:(NSNotification*)theNotification
{    
    NSNumber* buttonTag = (NSNumber*)theNotification.object;
    renderer->useFilterNumber([buttonTag integerValue]);
}

- (IBAction)recordVideo:(id)sender
{
    AVCaptureSessionManager *captureSessionManager = self.captureSessionManager;
    captureSessionManager.videoProcessor.recording ? [captureSessionManager stopRecording]
                                                   : [captureSessionManager startRecording];
}

- (void)recordingWillStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUpViewIsRecording:YES];
        NSLog(@"recordingWillStart");
    });
}

- (void)recordingDidStart
{
    NSLog(@"recordingDidStart");
}

- (void)recordingWillStop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUpViewIsRecording:NO];
//        if (! self.haloActivityView) {
//            self.haloActivityView = [[RFHaloActivityView alloc] initWithFrame:self.view.bounds];
//            [self.view addSubview:self.haloActivityView];
//        }
        NSLog(@"recordingWillStop");
    });
}

- (void)recordingDidStop
{
    NSLog(@"recordingDidStop");
}

- (IBAction)openGallery:(id)sender
{
    didOpenGallery = YES;
    GalleryViewController* galleryViewController = [[[GalleryViewController alloc] init] autorelease];
    [self presentViewController:galleryViewController animated:YES completion:^(void){
        [self.captureSessionManager pause];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (didOpenGallery) {
        didOpenGallery = NO;
        [self.captureSessionManager resume];
    }
}

- (void)updateElapsedTime
{
    self.elapsedTime += [self.elapsedTimeTimer timeInterval];
    int minutes = (int)self.elapsedTime / 60;
    int seconds = (int)self.elapsedTime - minutes * 60;
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (IBAction)showOverlayView:(id)sender
{
    [self.captureSessionManager pause];
    NSLog(@"here");
    self.sharingViewController = [[[SharingViewController alloc] initWithNibName:@"SharingViewController"
                                                                         bundle:[NSBundle mainBundle]
                                                                      videoInfo:nil] autorelease];
    self.sharingViewController.videoInfo = (NSDictionary*)sender;
    self.sharingViewController.delegate = self;
    [self.sharingViewController presentRFModalViewController:self.view];
}

- (IBAction)toggleCamera
{
    [self.captureSessionManager toggleCamera];
}

- (IBAction)toggleTorch
{
    [self.captureSessionManager toggleTorch];
}

- (void)thumbnailReady:(NSNotification*)notification
{
    NSDictionary *videoInfo = [notification userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOverlayView:videoInfo];
    });
}

- (void)modalViewControllerDismissed
{
    [self.captureSessionManager resume];
}

//- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
//{
//	CGFloat angle = 0.0;
//	
//	switch (orientation) {
//		case AVCaptureVideoOrientationPortrait:
//			angle = 0.0;
//			break;
//		case AVCaptureVideoOrientationPortraitUpsideDown:
//			angle = M_PI;
//			break;
//		case AVCaptureVideoOrientationLandscapeRight:
//			angle = -M_PI_2;
//			break;
//		case AVCaptureVideoOrientationLandscapeLeft:
//			angle = M_PI_2;
//			break;
//		default:
//			break;
//	}
//    
//	return angle;
//}
//
//- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
//{
//	CGAffineTransform transform = CGAffineTransformIdentity;
//    
//	// Calculate offsets from an arbitrary reference orientation (portrait)
//	CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
//	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
//	
//	// Find the difference in angle between the passed in orientation and the current video orientation
//	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
//	transform = CGAffineTransformMakeRotation(angleOffset);
//	
//	return transform;
//}

@end
