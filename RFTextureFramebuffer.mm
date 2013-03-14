#import "RFTextureFramebuffer.h"

void RFTextureFramebuffer::use()
{
    glActiveTexture(GL_TEXTURE1);
    RFFramebuffer::use();
}

RFTextureFramebuffer::RFTextureFramebuffer(GLsizei _width, GLsizei _height, bool has_depth_attachement)
{
    width = _width;
    height = _height;

    glActiveTexture(GL_TEXTURE1);
    texture = new RFTexture(width, height);
    glGenFramebuffers(1, &_id);
    glBindFramebuffer(GL_FRAMEBUFFER, _id);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture->get_id(), 0);

    if (has_depth_attachement) {
        GLuint depth_render_buffer;
        glGenRenderbuffers(1, &depth_render_buffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depth_render_buffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, width);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depth_render_buffer);
        glEnable(GL_DEPTH_TEST);
    }
    this->test_for_completeness();
}

RFTextureFramebuffer::~RFTextureFramebuffer() {
    delete texture;
}