#import "RFFramebuffer.h"
#import "RFGLView.h"

class RFViewFramebuffer : public RFFramebuffer {
protected:
    GLuint color_render_buffer;
public:
    RFViewFramebuffer(RFGLView* view, bool has_depth_attachement = false);
};
