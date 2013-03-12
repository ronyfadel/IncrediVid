#import "RRenderer.h"

void RRenderer::set_culling(bool enabled)
{
    enabled ? glEnable(GL_CULL_FACE) : glDisable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
}

void RRenderer::clear_display(GLbitfield mask = (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
{
    glClear(mask);
}