#import "MyRenderer.h"
#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"

#define PREVIEW_WIDTH 360
#define PREVIEW_HEIGHT 480

MyRenderer::MyRenderer(UIView* superview):RFRenderer(superview)
{
    RFFramebuffer *view_fb    = new RFViewFramebuffer(this->view);
    RFFramebuffer *texture_fb = new RFTextureFramebuffer(PREVIEW_WIDTH, PREVIEW_HEIGHT);
    
    RFNode *blur     = (new RFBlurPreviewNode(PREVIEW_WIDTH, PREVIEW_HEIGHT))->setup();
    RFNode *toon     = (new RFToonPreviewNode(view_fb->get_width(), view_fb->get_height()))->setup();

    node_framebuffer_list.push_back(make_pair(blur, texture_fb));
    node_framebuffer_list.push_back(make_pair(toon, view_fb));
}

void MyRenderer::render()
{
    static int j = 0;
    for (auto i = node_framebuffer_list.begin(); i != node_framebuffer_list.end(); ++i) {
        if (j) { glActiveTexture(GL_TEXTURE1); } j = 1 - j;
        
        (*i).second->use();
        clear_display();
        (*i).first->draw();
    }
    RFRenderer::render();
}

MyRenderer::~MyRenderer()
{
    for (auto i = node_framebuffer_list.begin(); i != node_framebuffer_list.end(); ++i)
    {
        
    }
}