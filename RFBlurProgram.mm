//#import "RFBlurProgram.h"
//
//RFBlurProgram::RFBlurProgram(RFFramebuffer* framebuffer, bool flipped):
//    RFFilterProgram("preview.vsh", "blur.fsh", framebuffer, flipped)
//{
//    
//}
//
//void RFBlurProgram::set_uniforms() {
//    // Setting uniforms (texture) / texel width, height
//    glUniform1i(glGetUniformLocation(get_id(), "input_texture"), 0);
//    glUniform1f(glGetUniformLocation(get_id(), "texel_width"), 1.f / framebuffer->get_width());
//    glUniform1f(glGetUniformLocation(get_id(), "texel_height"), 1.f / framebuffer->get_height());
//}
//
