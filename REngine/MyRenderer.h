#import <vector>
#import "RFRenderer.h"
#import "RFFramebuffer.h"
#import "RFFilterCollection.h"
using namespace std;

// dont forget to cleanup all filters

class MyRenderer : public RFRenderer {
protected:
    vector<RFFilterCollection*> filters;
    vector<RFFramebuffer*>framebuffers;
    int current_filter_index;
public:
    MyRenderer(RFGLView* previewView);
    void render();
    void useFilterNumber(int number);
    virtual ~MyRenderer();
};
