#import "RFRenderer.h"

RFRenderer::RFRenderer(UIView* superview)
{
    view = [[RFGLView alloc] initWithFrame:superview.frame];
    [superview addSubview:view];
    glClearColor(1.f, 0.f, 0.f, 1.f);
}

void RFRenderer::set_culling(bool enabled)
{
    enabled ? glEnable(GL_CULL_FACE) : glDisable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
}

void RFRenderer::clear_display(GLbitfield mask)
{
    glClear(mask);
}

void RFRenderer::setup()
{
}

void RFRenderer::render()
{
    [this->view update];
}