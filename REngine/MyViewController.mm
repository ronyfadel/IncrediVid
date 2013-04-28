#import "MyViewController.h"
#import "MyRenderer.h"

@interface MyViewController ()
- (void) setup;
@end

@implementation MyViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:0.23f green:0.23f blue:0.22f alpha:1.f]; // Vine gray
    self.view.backgroundColor = [UIColor colorWithRed:0.1f green:0.09f blue:0.11f alpha:1.f]; // dribbble gray/black
    
    // dribble blue             31.0	77.0	95.0
    // dribble lighter blue     32.0	81.0	75.0
    // dribbe orange            98.0	44.0	19.0
    
    renderer = new MyRenderer(self.view);
    [self.view bringSubviewToFront:nextButton];
    [self.view bringSubviewToFront:prevButton];
    [self.view bringSubviewToFront:videoButton];
    
    captureSessionManager = [[AVCaptureSessionManager alloc] initWithRenderer:(renderer)];
    [captureSessionManager setVideoProcessorDelegate:self];
    
//    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
//    displayLink.frameInterval = 2;
//    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (IBAction)changeFilter:(id)obj
{
    UIButton* target = (UIButton*)obj;
    if ([target.titleLabel.text isEqualToString:@"Next"]) {
        ((MyRenderer*)renderer)->use_next_filter();
    } else {
        NSLog(@"PREVvvvVVVV");
        ((MyRenderer*)renderer)->use_previous_filter();
    }
}

- (IBAction)recordVideo:(id)obj
{
    UIButton* theVideoButton = (UIButton*)obj;
    if ([theVideoButton.titleLabel.text isEqualToString:@"Record"]) {
        [captureSessionManager startRecording];
        [theVideoButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [captureSessionManager stopRecording];
        [theVideoButton setTitle:@"Record" forState:UIControlStateNormal];
    }
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
