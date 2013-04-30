#import <vector>
#import "RFRenderer.h"
#import "RFFramebuffer.h"
#import "RFFilterCollection.h"
using namespace std;

class MyRenderer : public RFRenderer {
protected:
    vector<RFFilterCollection*> filters;
    vector<RFFramebuffer*>framebuffers;
    int current_filter_index;
public:
    MyRenderer(UIView* superview);
    void render();
    void useFilterNumber(int number);
    virtual ~MyRenderer();
};
