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
    renderer = new MyRenderer(self.view);
    [self.view bringSubviewToFront:nextButton];
    [self.view bringSubviewToFront:prevButton];
    [self.view bringSubviewToFront:videoButton];
    
//    captureSessionManager = [[AVCaptureSessionManager alloc] initWithRenderer:(RFRenderer*)renderer];
    captureSessionManager = [[AVCaptureSessionManager alloc] init];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 2;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode]; 
    
//    UISlider* slider = [[UISlider alloc] init];
//    [self.view addSubview:slider];
//    [slider addTarget:self action:@selector(updatedSlider:) forControlEvents:UIControlEventValueChanged];
//    slider.frame = CGRectMake(5, self.view.frame.size.height - 30, self.view.frame.size.width - 40, slider.bounds.size.height);
}

- (IBAction)changeFilter:(id)obj
{
    UIButton* target = (UIButton*)obj;
    if ([target.titleLabel.text isEqualToString:@"Next"]) {
        ((MyRenderer*)renderer)->use_next_filter();
    } else {
        ((MyRenderer*)renderer)->use_previous_filter();
    }
}

- (IBAction)recordVideo:(id)obj
{
    UIButton* theVideoButton = (UIButton*)obj;
    if ([theVideoButton.titleLabel.text isEqualToString:@"Record"]) {
        
        [theVideoButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [theVideoButton setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (void)updatedSlider:(id)obj
{
//    cout<<"slider updated!!"<<endl;
//    UISlider* slider = (UISlider*) obj;
//    GLint program;
//    glGetIntegerv(GL_CURRENT_PROGRAM, (&program));
//    coefficient = slider.value * 2.f;
//    glUniform1f(glGetUniformLocation(program, "coefficient"), slider.value * 2.0);
}

- (void)update
{
    renderer->render();
}

@end
