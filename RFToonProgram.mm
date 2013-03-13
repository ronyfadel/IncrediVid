//#import "RFToonProgram.h"
//
//RFToonProgram::RFToonProgram(RFFramebuffer* framebuffer, bool flipped):
//    RFFilterProgram("preview.vsh", "toon.fsh", framebuffer, flipped)
//{
//    
//}
//
//void RFToonProgram::set_uniforms() {
//    glUniform1i(glGetUniformLocation(get_id(), "original_texture"), 0);
//    glUniform1i(glGetUniformLocation(get_id(), "blurred_texture"), 1);
//    glUniform1f(glGetUniformLocation(get_id(), "texel_width"), 1.f / framebuffer->get_width());
//    glUniform1f(glGetUniformLocation(get_id(), "texel_height"), 1.f / framebuffer->get_height());
//}
