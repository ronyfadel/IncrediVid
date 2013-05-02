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
@property UIButton *chooseFilterButton, *openGalleryButton;
@property RFRecordButton *recordButton;
@property UILabel *logoLabel, *elapsedTimeLabel;

@property(retain) NSTimer *elapsedTimeTimer;
@property float elapsedTime;

@end

@implementation MainViewController
@synthesize annotationBubble;
@synthesize chooseFilterButton, openGalleryButton, recordButton;
@synthesize logoLabel, elapsedTimeLabel;

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
#if ! TARGET_IPHONE_SIMULATOR
    // Backend
    renderer = new MyRenderer(self.view);
    captureSessionManager = [[AVCaptureSessionManager alloc] initWithRenderer:(renderer)];
#endif

    // UI
    UIFont *latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    logoLabel.font = latoBlack;
    UIFont *latoBlackSmall = [UIFont fontWithName:@"Lato-Black" size:20.0];
    elapsedTimeLabel.font = latoBlackSmall;
	elapsedTimeLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.45];
    elapsedTimeLabel.layer.cornerRadius = 4;
    elapsedTimeLabel.layer.opacity = 0;
    [self.view bringSubviewToFront:elapsedTimeLabel];
    
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

    SharingViewController* sharingViewController = [[SharingViewController alloc] initWithNibName:@"SharingViewController" bundle:[NSBundle mainBundle]];
    [self.view addSubview:sharingViewController.view];
    [self.view bringSubviewToFront:sharingViewController.view];
    NSLogRect(sharingViewController.view.frame);
    
//    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
//    displayLink.frameInterval = 2;
//    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
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
    GalleryViewController* galleryViewController = [[GalleryViewController alloc] init];
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
