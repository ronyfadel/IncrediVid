#import "MyViewController.h"
#import "MyRenderer.h"
#import "RFAnnotationView.h"
#import "RFFilterScrollView.h"
#import "RFRecordButton.h"

@interface MyViewController () {
}
@property RFAnnotationView* annotationBubble;
@property UIButton* chooseFilterButton;
@property UIButton* videoButton;
@property UILabel* logoLabel;

- (void) setup;
@end

@implementation MyViewController
@synthesize annotationBubble;
@synthesize chooseFilterButton, videoButton;
@synthesize logoLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Backed
    renderer = new MyRenderer(self.view);
    captureSessionManager = [[AVCaptureSessionManager alloc] initWithRenderer:(renderer)];

    // UI
    self.view.backgroundColor = [UIColor colorWithRed:0.1f green:0.09f blue:0.11f alpha:1.f]; // dribbble gray/black
    logoLabel.font = [UIFont fontWithName:@"Lato-Black" size:34.0];
    // re-showing record button covered by GL View
    [self.view bringSubviewToFront:videoButton];
    
    self.annotationBubble = [[[RFAnnotationView alloc] initWithFrame:CGRectMake(-5, 265, 330, 110)] autorelease];
    self.annotationBubble.layer.opacity = 0;
    
    
    NSString* file = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
    NSArray* filtersInfo = [NSArray arrayWithContentsOfFile:file];
        
    RFFilterScrollView *scrollView = [[[RFFilterScrollView alloc] initWithFrame:CGRectMake(8, 10, 315, 70)
                                                                 filtersInfo:filtersInfo] autorelease];
    [self.annotationBubble addSubview:scrollView];
    [self.view addSubview:self.annotationBubble];
    [self.view bringSubviewToFront:self.annotationBubble];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFilterChosen:) name:@"New Filter Chosen" object:nil];

//    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
//    displayLink.frameInterval = 2;
//    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (IBAction)wandPushed:(id)sender
{
    self.chooseFilterButton.enabled = NO;
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.annotationBubble.layer.opacity = 1.0 - self.annotationBubble.layer.opacity;
                     }
                     completion:^(BOOL finished){
                         self.chooseFilterButton.enabled = YES;
                     }];
}

- (void)newFilterChosen:(NSNotification*)theNotification
{
    NSNumber* buttonTag = (NSNumber*)theNotification.object;
    renderer->useFilterNumber([buttonTag integerValue]);
}

- (IBAction)recordVideo:(id)sender
{
//    UIButton* theVideoButton = (UIButton*)obj;
//    if ([theVideoButton.titleLabel.text isEqualToString:@"Record"]) {
//        [captureSessionManager startRecording];
//        [theVideoButton setTitle:@"Stop" forState:UIControlStateNormal];
//    } else {
//        [captureSessionManager stopRecording];
//        [theVideoButton setTitle:@"Record" forState:UIControlStateNormal];
//    }
}

- (void)recordingWillStart{ NSLog(@"recordingWillStart"); }
- (void)recordingDidStart{ NSLog(@"recordingDidStart"); }
- (void)recordingWillStop{ NSLog(@"recordingWillStop"); }
- (void)recordingDidStop{ NSLog(@"recordingDidStop"); }

- (void)update
{
    renderer->render();
}

@end
