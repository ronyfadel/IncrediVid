#import <vector>
#import "RFFilter.h"

class RFFilterCollection {
protected:
    vector<pair<RFFilter*, RFFramebuffer*> > filter_list;
    string name;
public:
    RFFilterCollection(string _name);
    string getName();
    void add_filter_framebuffer_pair(RFFilter* filter, RFFramebuffer* framebuffer);
    void draw();
};





