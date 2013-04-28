#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"
#import "RFiOS5TextureFramebuffer.h"
#import "TKAlertCenter.h"

#import "MyRenderer.h"

#define TARGET_TEXTURE_WIDTH 480
#define TARGET_TEXTURE_HEIGHT 480

#define CAPTURED_FRAME_TEXTURE 0
#define OUTPUT_TEXTURE_1 1
#define OUTPUT_TEXTURE_2 2
#define iOS5_FRAMEBUFFER_TEXTURE 3
#define LOOKUP_TEXTURE 4

MyRenderer::MyRenderer(UIView* superview):RFRenderer(superview)
{
    current_filter_index = 0;
    
    RFFramebuffer *view_fb            = new RFViewFramebuffer(this->view),
                  *iOS5_texture_fb    = new RFiOS5TextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, iOS5_FRAMEBUFFER_TEXTURE),
                  *texture_fb_1       = new RFTextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, OUTPUT_TEXTURE_1),
                  *texture_fb_2       = new RFTextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, OUTPUT_TEXTURE_2);
    
    vector<RFFilterCollection*> fc;

    // Cartoon Filter
    RFFilterCollection* cartoon = new RFFilterCollection("Cartoon");
    
    RFFilter *crop = new RFFilter("copy.vsh", "crop.fsh", true);
    crop->bind_uniform_to_int_value("input_texture", CAPTURED_FRAME_TEXTURE);
    crop->setup();
    cartoon->add_filter_framebuffer_pair(crop, texture_fb_1);

    RFFilter *blur = new RFFilter("preview.vsh", "blur.fsh");
    blur->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    blur->bind_uniform_to_float_value("texel_width",  1.f / TARGET_TEXTURE_WIDTH);
    blur->bind_uniform_to_float_value("texel_height", 1.f / TARGET_TEXTURE_HEIGHT);
    blur->setup();
    cartoon->add_filter_framebuffer_pair(blur, texture_fb_2);

    RFFilter *toon = new RFFilter("preview.vsh", "toon.fsh");
    toon->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    toon->bind_uniform_to_int_value("blurred_texture", OUTPUT_TEXTURE_2);
    toon->bind_uniform_to_float_value("texel_width",  1.f / TARGET_TEXTURE_WIDTH);
    toon->bind_uniform_to_float_value("texel_height", 1.f / TARGET_TEXTURE_HEIGHT);
    toon->bind_uniform_to_float_value("coefficient", 1.0f);
    toon->setup();
    cartoon->add_filter_framebuffer_pair(toon, iOS5_texture_fb);
    
    RFFilter *copy = new RFFilter("copy.vsh", "copy.fsh");
    copy->bind_uniform_to_int_value("input_texture", iOS5_FRAMEBUFFER_TEXTURE);
    copy->setup();
    cartoon->add_filter_framebuffer_pair(copy, view_fb);

    filters.push_back(cartoon);
    
    // Amatorka Filter
    RFFilterCollection* amatorka = new RFFilterCollection("Amatorka");
    amatorka->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_amatorka = new RFLookupFilter("lookup_amatorka.png");
    lookup_amatorka->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_amatorka->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_amatorka->setup();
    amatorka->add_filter_framebuffer_pair(lookup_amatorka, iOS5_texture_fb);
    amatorka->add_filter_framebuffer_pair(copy, view_fb);
    filters.push_back(amatorka);
    
    // Miss Etikate Filter
    RFFilterCollection* miss_etikate = new RFFilterCollection("Miss Etikate");
    miss_etikate->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_miss_etikate = new RFLookupFilter("lookup_miss_etikate.png");
    lookup_miss_etikate->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_miss_etikate->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_miss_etikate->setup();
    miss_etikate->add_filter_framebuffer_pair(lookup_miss_etikate, iOS5_texture_fb);
    miss_etikate->add_filter_framebuffer_pair(copy, view_fb);
    filters.push_back(miss_etikate);

//    RFFilter *crop = new RFFilter("copy.vsh", "crop.fsh", true);
//    crop->bind_uniform_to_int_value("input_texture", CAPTURED_FRAME_TEXTURE);
//    crop->setup();
//    cartoon->add_filter_framebuffer_pair((RFFilter*)crop, iOS5_texture_fb);
//        
//    RFFilter *copy = new RFFilter("copy.vsh", "copy.fsh");
//    copy->bind_uniform_to_int_value("input_texture", iOS5_FRAMEBUFFER_TEXTURE);
//    crop->setup();
//    cartoon->add_filter_framebuffer_pair((RFFilter*)copy, view_fb);
//
//    filters.push_back(cartoon);


//    RFFilter *crop = ( RFFilter* )(new RFCropFilter())->setup(),
//             *copy = ( RFFilter* )(new RFCopyFilter())->setup(),
//             *blur = ( RFFilter* )(new RFBlurFilter(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT))->setup(),
//             *toon = ( RFFilter* )(new RFToonFilter(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT))->setup(),
//             *etikate = ( RFFilter* )(new RFLookupFilter("lookup_miss_etikate.png"))->setup(),
//             *amatorka = ( RFFilter* )(new RFLookupFilter("lookup_amatorka.png"))->setup();
//        
//    RFFilterCollection* filter_collections[1];
//    filter_collections[0] = new RFFilterCollection("Cartoon");
//    filter_collections[0]->add_filter_framebuffer_pair(crop, texture_fb);
//    filter_collections[0]->add_filter_framebuffer_pair(blur, texture_fb);
//    filter_collections[0]->add_filter_framebuffer_pair(toon, iOS5_texture_fb);
//    filter_collections[0]->add_filter_framebuffer_pair(copy, view_fb);
    
//    filter_collections[1] = new RFFilterCollection("Miss Etikate");
////    filter_collections[1]->add_filter_framebuffer_pair(blur, texture_fb);
////    filter_collections[1]->add_filter_framebuffer_pair(etikate, iOS5_texture_fb);
////    filter_collections[1]->add_filter_framebuffer_pair(copy, view_fb);
//    filter_collections[1]->add_filter_framebuffer_pair(etikate, view_fb);
//    
//    filter_collections[2] = new RFFilterCollection("Amatorka");
//    filter_collections[2]->add_filter_framebuffer_pair(blur, texture_fb);
//    filter_collections[2]->add_filter_framebuffer_pair(amatorka, iOS5_texture_fb);
//    filter_collections[2]->add_filter_framebuffer_pair(copy, view_fb);
    
//    for (int i = 0; i < sizeof(filter_collections) / sizeof(RFFilterCollection*); ++i) {
//        filters.push_back(filter_collections[i]);
//    }
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
