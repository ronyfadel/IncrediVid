#import <vector>
#import "RFRenderer.h"
#import "RFFramebuffer.h"
#import "RFFilter.h"
using namespace std;

class MyRenderer : public RFRenderer {
protected:
    vector<RFFilterCollection*> filters;
    int current_filter_index;
public:
    MyRenderer(UIView* superview);
    void render();
    void use_next_filter();
    void use_previous_filter();
    virtual ~MyRenderer();
};
