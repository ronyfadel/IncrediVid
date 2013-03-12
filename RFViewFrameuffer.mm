#import "RFViewFramebuffer.h"

RFViewFramebuffer::RFViewFramebuffer(RFGLView* view, bool has_depth_attachement)
{
    EAGLContext* context = view->eaglContext;
    
    glGenRenderbuffers(1, &color_render_buffer);
    glBindRenderbuffer(GL_RENDERBUFFER, color_render_buffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)view.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    GLuint depth_render_buffer;
    
    if (has_depth_attachement) {
        glGenRenderbuffers(1, &depth_render_buffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depth_render_buffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
        glEnable(GL_DEPTH_TEST);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, color_render_buffer);
    glGenFramebuffers(1, &_id);
    glBindFramebuffer(GL_FRAMEBUFFER, _id);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, color_render_buffer);
    if (has_depth_attachement) {
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depth_render_buffer);
    }
    
    this->test_for_completeness();
}
