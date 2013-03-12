#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RFGLView : UIView {
@public
    EAGLContext* eaglContext;
}
- (void)update;
@end
