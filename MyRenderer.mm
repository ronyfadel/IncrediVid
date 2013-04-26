#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"
#import "RFiOS5TextureFramebuffer.h"

#import "MyRenderer.h"

#define PREVIEW_WIDTH 480
#define PREVIEW_HEIGHT 640

MyRenderer::MyRenderer(UIView* superview):RFRenderer(superview)
{
    current_filter_index = 0;
    
    RFFramebuffer *view_fb    = new RFViewFramebuffer(this->view);
    RFFramebuffer *iOS5_texture_fb = new RFiOS5TextureFramebuffer(view_fb->get_width(), view_fb->get_height());
    RFFramebuffer *texture_fb = new RFTextureFramebuffer(PREVIEW_WIDTH, PREVIEW_HEIGHT);
        
    RFFilter *blur = ( RFFilter* )(new RFBlurFilter(texture_fb->get_width(), texture_fb->get_height()))->setup(),
             *toon = ( RFFilter* )(new RFToonFilter(iOS5_texture_fb->get_width(), iOS5_texture_fb->get_height()))->setup(),
             *copy = ( RFFilter* )(new RFCopyFilter(view_fb->get_width(), view_fb->get_height()))->setup();
    
    RFFilterCollection* first_collection = new RFFilterCollection();
    first_collection->add_filter_framebuffer_pair(blur, texture_fb);
    first_collection->add_filter_framebuffer_pair(toon, iOS5_texture_fb);
    first_collection->add_filter_framebuffer_pair(copy, view_fb);
    filters.push_back(first_collection);
}

void MyRenderer::render()
{
    NSLog(@"----->rendering");
    filters.at(current_filter_index)->draw();
    RFRenderer::render();
}

void MyRenderer::use_next_filter()
{
    current_filter_index = (current_filter_index + 1) % filters.size();
}

void MyRenderer::use_previous_filter()
{
    current_filter_index = (current_filter_index - 1) % filters.size();
}

MyRenderer::~MyRenderer()
{
    /* TODO */
}


//    RFNode *toon2 = (new RFToonPreviewNode2(view_fb->get_width(), view_fb->get_height()))->setup();
//    RFNode *toon3 = (new RFToonPreviewNode3(view_fb->get_width(), view_fb->get_height()))->setup();
//    RFNode *toon4 = (new RFToonPreviewNode4(view_fb->get_width(), view_fb->get_height()))->setup();
//    vector<pair<RFNode*, RFFramebuffer*>> second_filter;
//    second_filter.push_back(make_pair(toon2, view_fb));
//
//    vector<pair<RFNode*, RFFramebuffer*>> third_filter;
//    third_filter.push_back(make_pair(blur, texture_fb));
//    third_filter.push_back(make_pair(toon3, view_fb));
//
//    vector<pair<RFNode*, RFFramebuffer*>> fourth_filter;
//    fourth_filter.push_back(make_pair(toon4, view_fb));
//    filter_list.push_back(second_filter);
//    filter_list.push_back(third_filter);
//    filter_list.push_back(fourth_filter);
