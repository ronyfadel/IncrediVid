#import "MyRenderer.h"
#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"

#define PREVIEW_WIDTH 360
#define PREVIEW_HEIGHT 480

MyRenderer::MyRenderer(UIView* superview):RFRenderer(superview)
{
    current_filter_index = 0;
    
    RFFramebuffer *view_fb    = new RFViewFramebuffer(this->view);
    RFFramebuffer *texture_fb = new RFTextureFramebuffer(PREVIEW_WIDTH, PREVIEW_HEIGHT);
    
    RFNode *blur = (new RFBlurPreviewNode(PREVIEW_WIDTH, PREVIEW_HEIGHT))->setup();
    RFNode *toon = (new RFToonPreviewNode(view_fb->get_width(), view_fb->get_height()))->setup();
    RFNode *toon2 = (new RFToonPreviewNode2(view_fb->get_width(), view_fb->get_height()))->setup();
    RFNode *toon3 = (new RFToonPreviewNode3(view_fb->get_width(), view_fb->get_height()))->setup();
    RFNode *toon4 = (new RFToonPreviewNode4(view_fb->get_width(), view_fb->get_height()))->setup();
    
    vector<pair<RFNode*, RFFramebuffer*>> first_filter;
    first_filter.push_back(make_pair(blur, texture_fb));
    first_filter.push_back(make_pair(toon, view_fb));
    
    vector<pair<RFNode*, RFFramebuffer*>> second_filter;
    second_filter.push_back(make_pair(toon2, view_fb));

    vector<pair<RFNode*, RFFramebuffer*>> third_filter;
    third_filter.push_back(make_pair(blur, texture_fb));
    third_filter.push_back(make_pair(toon3, view_fb));
    
    vector<pair<RFNode*, RFFramebuffer*>> fourth_filter;
    fourth_filter.push_back(make_pair(toon4, view_fb));
    
    filter_list.push_back(first_filter);
    filter_list.push_back(second_filter);
    filter_list.push_back(third_filter);
    filter_list.push_back(fourth_filter);
}

void MyRenderer::render()
{
    vector<pair<RFNode*, RFFramebuffer*>> current_filter = filter_list.at(current_filter_index);
    
    for (auto i = current_filter.begin(); i != current_filter.end(); ++i) {
        (*i).second->use();
        clear_display();
        (*i).first->draw();
    }
    RFRenderer::render();
}

void MyRenderer::use_next_filter()
{
    current_filter_index = (current_filter_index + 1) % filter_list.size();
}

void MyRenderer::use_previous_filter()
{
    current_filter_index = (current_filter_index - 1) % filter_list.size();
}

MyRenderer::~MyRenderer()
{
    /* TODO */
}
