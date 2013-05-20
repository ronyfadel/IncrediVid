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
    
    framebuffers.push_back(view_fb);
    framebuffers.push_back(iOS5_texture_fb);
    framebuffers.push_back(texture_fb_1);
    framebuffers.push_back(texture_fb_2);
    
    // some oft used filters
#if TARGET_IPHONE_SIMULATOR
    RFFilter *crop = new RFFilter("copy.vsh", "crop_simulator.fsh", FLIPPED_CROPPED);
#else
    RFFilter *crop = new RFFilter("copy.vsh", "crop.fsh", FLIPPED_CROPPED);
#endif
    crop->bind_uniform_to_int_value("input_texture", CAPTURED_FRAME_TEXTURE);
    crop->setup();
    
    RFFilter *copy = new RFFilter("copy.vsh", "copy.fsh", FLIPPED);
    copy->bind_uniform_to_int_value("input_texture", iOS5_FRAMEBUFFER_TEXTURE);
    copy->setup();
    
    // Miss Etikate Filter
    RFFilterCollection* miss_etikate = new RFFilterCollection("Miss Etikate");
    miss_etikate->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_miss_etikate = new RFLookupFilter("lookup_miss_etikate.png", FLIPPED);
    lookup_miss_etikate->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_miss_etikate->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_miss_etikate->setup();
    miss_etikate->add_filter_framebuffer_pair(lookup_miss_etikate, iOS5_texture_fb);
    miss_etikate->add_filter_framebuffer_pair(copy, view_fb);
    filters.push_back(miss_etikate);
    
    // Amatorka Filter
    RFFilterCollection* amatorka = new RFFilterCollection("Amatorka");
    amatorka->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_amatorka = new RFLookupFilter("lookup_amatorka.png", FLIPPED);
    lookup_amatorka->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_amatorka->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_amatorka->setup();
    amatorka->add_filter_framebuffer_pair(lookup_amatorka, iOS5_texture_fb);
    amatorka->add_filter_framebuffer_pair(copy, view_fb);
    filters.push_back(amatorka);
    
    // Cartoon Filter
    RFFilterCollection* cartoon = new RFFilterCollection("Cartoon");
    cartoon->add_filter_framebuffer_pair(crop, texture_fb_1);
    
    RFFilter *blur = new RFFilter("preview.vsh", "blur.fsh");
    blur->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    blur->bind_uniform_to_float_value("texel_width",  1.f / TARGET_TEXTURE_WIDTH);
    blur->bind_uniform_to_float_value("texel_height", 1.f / TARGET_TEXTURE_HEIGHT);
    blur->setup();
    cartoon->add_filter_framebuffer_pair(blur, texture_fb_2);

    RFFilter *toon = new RFFilter("preview.vsh", "toon.fsh", FLIPPED);
    toon->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    toon->bind_uniform_to_int_value("blurred_texture", OUTPUT_TEXTURE_2);
    toon->bind_uniform_to_float_value("texel_width",  1.f / TARGET_TEXTURE_WIDTH);
    toon->bind_uniform_to_float_value("texel_height", 1.f / TARGET_TEXTURE_HEIGHT);
    toon->bind_uniform_to_float_value("coefficient", 1.0f);
    toon->setup();
    cartoon->add_filter_framebuffer_pair(toon, iOS5_texture_fb);
    
    cartoon->add_filter_framebuffer_pair(copy, view_fb);

    filters.push_back(cartoon);    
}

void MyRenderer::render()
{
    filters.at(current_filter_index)->draw();
    RFRenderer::render();
}

void MyRenderer::useFilterNumber(int number)
{
    current_filter_index = number;
}

MyRenderer::~MyRenderer()
{
}