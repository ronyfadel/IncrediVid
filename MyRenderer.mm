#import "MyRenderer.h"

#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"
#import "RFBlurProgram.h"
#import "RFToonProgram.h"

MyRenderer::MyRenderer(UIView* superview):RFRenderer(superview)
{
//    // Creating View framebuffer, setting Viewport and binding framebuffer
//    framebuffers[VIEW_FRAMEBUFFER] = new RFViewFramebuffer(this->view);
//    
//    // Creating Blur texture framebuffer
////    framebuffers[BLUR_FRAMEBUFFER] = new RFTextureFramebuffer(framebuffers[VIEW_FRAMEBUFFER]->get_width(),
////                                                             framebuffers[VIEW_FRAMEBUFFER]->get_height());
//    framebuffers[BLUR_FRAMEBUFFER] = new RFTextureFramebuffer(360, 480);
//
//    
//    framebuffers[VIEW_FRAMEBUFFER]->use();
//    
//    programs[BLUR_PROGRAM] = new RFBlurProgram(framebuffers[BLUR_FRAMEBUFFER], true);
//    programs[BLUR_PROGRAM]->set_uniforms();
//    programs[TOON_PROGRAM] = new RFToonProgram(framebuffers[VIEW_FRAMEBUFFER], false);
//    programs[TOON_PROGRAM]->set_uniforms();
}

void MyRenderer::render()
{
//    clear_display();
//    
//    glActiveTexture(GL_TEXTURE1);
//    framebuffers[BLUR_PROGRAM]->use();
//    programs[BLUR_PROGRAM]->use();
//    programs[BLUR_PROGRAM]->draw();
//    
//    framebuffers[VIEW_FRAMEBUFFER]->use();
//    programs[TOON_PROGRAM]->use();
//    programs[TOON_PROGRAM]->draw();
//    
//    RFRenderer::render();
}

RFProgram** MyRenderer::get_programs()
{
    return programs;
}