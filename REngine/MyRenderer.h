#import "RFRenderer.h"
#import "RFProgram.h"
#import "RFFramebuffer.h"

enum {
    BLUR_PROGRAM,
    TOON_PROGRAM,
    NUM_PROGRAMS
};

enum {
    BLUR_FRAMEBUFFER,
    VIEW_FRAMEBUFFER,
    NUM_FRAMEBUFFERS
};

class MyRenderer : public RFRenderer {
protected:
    RFProgram* programs[NUM_PROGRAMS];
    RFFramebuffer* framebuffers[NUM_FRAMEBUFFERS];
public:
    MyRenderer(UIView* superview);
    void render();
    RFProgram** get_programs();
};

