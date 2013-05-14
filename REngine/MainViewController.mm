#import "MainViewController.h"
#import "MyRenderer.h"
#import "RFAnnotationView.h"
#import "RFFilterScrollView.h"
#import "RFRecordButton.h"

#import "GalleryViewController.h"
#import "SharingViewController.h"

static void NSLogRect(CGRect rect)
{
    NSLog(@"Origin: (%f, %f) - Size: (%f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

@interface MainViewController () {
    
}
@property RFAnnotationView* annotationBubble;
@property IBOutlet UIButton *chooseFilterButton, *openGalleryButton, *upgradeToProButton;
@property RFRecordButton *recordButton;
@property UILabel *logoLabel, *elapsedTimeLabel;

@property(retain) NSTimer *elapsedTimeTimer;
@property float elapsedTime;

@end

@implementation MainViewController
@synthesize annotationBubble;
@synthesize chooseFilterButton, openGalleryButton, recordButton;
@synthesize logoLabel, elapsedTimeLabel;
@synthesize captureSessionManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingWillStart) name:@"Recording Will Start" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingDidStart) name:@"Recording Did Start" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingWillStop) name:@"Recording Will Stop" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingDidStop) name:@"Recording Did Stop" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFilterChosen:) name:@"New Filter Chosen" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    renderer = new MyRenderer(self.view);
#if ! TARGET_IPHONE_SIMULATOR
    captureSessionManager = [[AVCaptureSessionManager alloc] initWithRenderer:(renderer)];
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
#endif

    // UI
    UIFont *latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    logoLabel.font = latoBlack;
    UIFont *latoBlackSmall = [UIFont fontWithName:@"Lato-Black" size:20.0];
    elapsedTimeLabel.font = latoBlackSmall;
	elapsedTimeLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.35];
    elapsedTimeLabel.layer.cornerRadius = 4;
    elapsedTimeLabel.layer.opacity = 0;
    [self.view bringSubviewToFront:elapsedTimeLabel];

    self.upgradeToProButton.layer.cornerRadius = 4;
    
    
    // re-showing record button covered by GL View
    [self.view bringSubviewToFront:recordButton];
    
    self.annotationBubble = [[[RFAnnotationView alloc] initWithFrame:CGRectMake(-5, 265, 330, 110)] autorelease];
    self.annotationBubble.layer.opacity = 0;
    
    NSString* file = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
    NSArray* filtersInfo = [NSArray arrayWithContentsOfFile:file];
        
    RFFilterScrollView *scrollView = [[[RFFilterScrollView alloc] initWithFrame:CGRectMake(8, 10, 315, 70)
                                                                 filtersInfo:filtersInfo] autorelease];
    [self.annotationBubble addSubview:scrollView];
    [self.view addSubview:self.annotationBubble];
    [self.view bringSubviewToFront:self.annotationBubble];

#if TARGET_IPHONE_SIMULATOR
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 30;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#endif
}

- (void)update
{
    self->renderer->render();
}

- (IBAction)alternateFilterPicker:(id)sender
{
    
    self.annotationBubble.layer.opacity == 1.0 ? [self dismissFilterPicker] : [self presentFilterPicker];
}

- (void)setFilterPickerToOpacity:(float)opacity
{
    self.chooseFilterButton.enabled = NO;
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.annotationBubble.layer.opacity = opacity;
                     }
                     completion:^(BOOL finished){
                         self.chooseFilterButton.enabled = YES;
                     }];
}


- (void)presentFilterPicker
{
    [self setFilterPickerToOpacity:1.0];
}

- (void)dismissFilterPicker
{
    [self setFilterPickerToOpacity:0.0];
}

- (void)hideButtons
{
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.chooseFilterButton.frame = CGRectMake(self.chooseFilterButton.frame.origin.x + 100,
                                                                    self.chooseFilterButton.frame.origin.y,
                                                                    self.chooseFilterButton.frame.size.width,
                                                                    self.chooseFilterButton.frame.size.height);
                         self.openGalleryButton.frame = CGRectMake(self.openGalleryButton.frame.origin.x - 100,
                                                              self.openGalleryButton.frame.origin.y,
                                                              self.openGalleryButton.frame.size.width,
                                                              self.openGalleryButton.frame.size.height);
                         self.elapsedTimeLabel.layer.opacity = 1.0 - self.elapsedTimeLabel.layer.opacity;

                     }
                     completion:^(BOOL finished){}];
}

- (void)showButtons
{
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.chooseFilterButton.frame = CGRectMake(self.chooseFilterButton.frame.origin.x - 100,
                                                                    self.chooseFilterButton.frame.origin.y,
                                                                    self.chooseFilterButton.frame.size.width,
                                                                    self.chooseFilterButton.frame.size.height);
                         self.openGalleryButton.frame = CGRectMake(self.openGalleryButton.frame.origin.x + 100,
                                                              self.openGalleryButton.frame.origin.y,
                                                              self.openGalleryButton.frame.size.width,
                                                              self.openGalleryButton.frame.size.height);
                         self.elapsedTimeLabel.layer.opacity = 1.0 - self.elapsedTimeLabel.layer.opacity;
                         
                     }
                     completion:^(BOOL finished){}];
}

- (void)newFilterChosen:(NSNotification*)theNotification
{    
    NSNumber* buttonTag = (NSNumber*)theNotification.object;
    renderer->useFilterNumber([buttonTag integerValue]);
}

- (IBAction)recordVideo:(id)sender
{
    captureSessionManager.videoProcessor.recording ? [captureSessionManager stopRecording] : [captureSessionManager startRecording];    
}

- (void)recordingWillStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordButton.layer addSublayer:recordButton.haloLayer];
        [self dismissFilterPicker];
        self.chooseFilterButton.enabled = NO;
        self.openGalleryButton.enabled = NO;
        [self hideButtons];
        
        self.elapsedTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateElapsedTime) userInfo:nil repeats:YES];
        self.elapsedTime = 0.0;
        self.elapsedTimeLabel.text = @"00:00";
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
        [self.elapsedTimeTimer invalidate];
        self.elapsedTime = 0.0;
        
        [self.recordButton.haloLayer removeFromSuperlayer];
        self.chooseFilterButton.enabled = YES;
        self.openGalleryButton.enabled = YES;
        [self showButtons];
        NSLog(@"recordingWillStop");
    });
}

- (void)recordingDidStop
{
    NSLog(@"recordingDidStop");
}

- (IBAction)openGallery:(id)sender
{
    GalleryViewController* galleryViewController = [[[GalleryViewController alloc] init] autorelease];
    [self presentViewController:galleryViewController animated:YES completion:^(void){}];
}

- (void)updateElapsedTime
{
    self.elapsedTime += [self.elapsedTimeTimer timeInterval];
    int minutes = (int)self.elapsedTime / 60;
    int seconds = (int)self.elapsedTime - minutes * 60;
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];    
}

@end
