#import <vector>
#import "RFRenderer.h"
#import "RFFramebuffer.h"
#import "RF2DPreviewNode.h"

class RFFilterCollection : public RFRenderer {
protected:
    vector<vector<pair<RFNode*, RFFramebuffer*> > > filter_list;
    int current_filter_index;
public:
    RFFilterCollection(UIView* superview);
    void render();
    void use_next_filter();
    void use_previous_filter();
    virtual ~RFFilterCollection();
};