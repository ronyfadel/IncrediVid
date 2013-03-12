#import "MyViewController.h"
#import "MyRenderer.h"

extern float coefficient;

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
    captureSessionManager = [[AVCaptureSessionManager alloc] init];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 2;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode]; 
        
    UISlider* slider = [[UISlider alloc] init];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(updatedSlider:) forControlEvents:UIControlEventValueChanged];
    slider.frame = CGRectMake(5, self.view.frame.size.height - 30, self.view.frame.size.width - 40, slider.bounds.size.height);
}

- (void)updatedSlider:(id)obj
{
    UISlider* slider = (UISlider*) obj;
    glUniform1f(glGetUniformLocation(((MyRenderer*)renderer)->get_programs()[TOON_PROGRAM]->get_id(), "coefficient"), slider.value );//* 2.0);
    
}

- (void)update
{
    renderer->render();
}

@end
