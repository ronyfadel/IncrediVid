#include "RFFilterCollection.h"


RFFilterCollection::RFFilterCollection(string _name):name(_name)
{
}

string RFFilterCollection::getName()
{
    return name;
}

void RFFilterCollection::add_filter_framebuffer_pair(RFFilter* filter, RFFramebuffer* framebuffer)
{
    filter_list.push_back(make_pair(filter, framebuffer));
}

void RFFilterCollection::draw()
{
    for (auto i = filter_list.begin(); i != filter_list.end(); ++i) {
        i->first->drawToFramebuffer(i->second);
    }
}
