#import "RFFrameBuffer.h"

void RFFramebuffer::test_for_completeness()
{
    glBindFramebuffer(GL_FRAMEBUFFER, _id);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
    }
}

void RFFramebuffer::use()
{
    glBindFramebuffer(GL_FRAMEBUFFER, _id);
    glViewport(0, 0, width, height);
}

GLsizei RFFramebuffer::get_width()
{
    printf("width: %u\n", width);
    return width;
}

GLsizei RFFramebuffer::get_height()
{
    printf("height: %u\n", height);
    return height;
}

    
RFFramebuffer::~RFFramebuffer()
{
}