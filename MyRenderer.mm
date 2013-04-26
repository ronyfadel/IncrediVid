#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"
#import "RFiOS5TextureFramebuffer.h"
#import "TKAlertCenter.h"

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
             *copy = ( RFFilter* )(new RFCopyFilter(view_fb->get_width(), view_fb->get_height()))->setup(),
             *etikate = ( RFFilter* )(new RFLookupFilter("lookup_miss_etikate.png"))->setup(),
             *amatorka = ( RFFilter* )(new RFLookupFilter("lookup_amatorka.png"))->setup();
    
    RFFilterCollection* filter_collections[3];
    filter_collections[0] = new RFFilterCollection();
    filter_collections[0]->add_filter_framebuffer_pair(blur, texture_fb);
    filter_collections[0]->add_filter_framebuffer_pair(toon, iOS5_texture_fb);
    filter_collections[0]->add_filter_framebuffer_pair(copy, view_fb);
    
    filter_collections[1] = new RFFilterCollection();
    filter_collections[1]->add_filter_framebuffer_pair(blur, texture_fb);
    filter_collections[1]->add_filter_framebuffer_pair(etikate, iOS5_texture_fb);
    filter_collections[1]->add_filter_framebuffer_pair(copy, view_fb);
    
    filter_collections[2] = new RFFilterCollection();
    filter_collections[2]->add_filter_framebuffer_pair(blur, texture_fb);
    filter_collections[2]->add_filter_framebuffer_pair(amatorka, iOS5_texture_fb);
    filter_collections[2]->add_filter_framebuffer_pair(copy, view_fb);
    
    
    filter_collections[0]->setName("Cartoon");
    filter_collections[1]->setName("Miss Etikate");
    filter_collections[2]->setName("Amatorka");
    
    for (int i = 0; i < sizeof(filter_collections) / sizeof(RFFilterCollection*); ++i) {
        filters.push_back(filter_collections[i]);
    }
}

void MyRenderer::render()
{
    filters.at(current_filter_index)->draw();
    RFRenderer::render();
}

void MyRenderer::use_next_filter()
{
    current_filter_index = (current_filter_index + 1) % filters.size();
    [[TKAlertCenter defaultCenter] postAlertWithMessage:[NSString stringWithCString:filters.at(current_filter_index)->getName().c_str() encoding:NSASCIIStringEncoding]];
}

void MyRenderer::use_previous_filter()
{
    current_filter_index = (current_filter_index + filters.size() - 1) % filters.size();
    [[TKAlertCenter defaultCenter] postAlertWithMessage:[NSString stringWithCString:filters.at(current_filter_index)->getName().c_str() encoding:NSASCIIStringEncoding]];
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
