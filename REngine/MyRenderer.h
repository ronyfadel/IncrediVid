#import <vector>
#import "RFRenderer.h"
#import "RFFramebuffer.h"
#import "RF2DPreviewNode.h"

class MyRenderer : public RFRenderer {
protected:
    vector<pair<RFNode*, RFFramebuffer*> > node_framebuffer_list;
public:
    MyRenderer(UIView* superview);
    void render();
    virtual ~MyRenderer();
};
