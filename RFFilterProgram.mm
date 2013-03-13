//#import "RFFilterProgram.h"
//
//
//RFFilterProgram::RFFilterProgram(string v_shader_name,
//                                 string f_shader_name,
//                                 RFFramebuffer* framebuffer,
//                                 bool flipped):
//RFProgram(v_shader_name, f_shader_name)
//{
//    this->framebuffer = framebuffer;
//
//    RFProgram::use();
//
//    glGenBuffers(1, &vbo);
//    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//
//    if (flipped) {
//        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_flipped_tex_coords), vertices_flipped_tex_coords, GL_STATIC_DRAW);
//    } else {
//        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_straight_tex_coords), vertices_straight_tex_coords, GL_STATIC_DRAW);
//    }
//
//    attribs[ATTRIB_VERTEX] = glGetAttribLocation(get_id(), "position");
//    attribs[ATTRIB_TEXCOORD] = glGetAttribLocation(get_id(), "tex_coord_in");
//    glEnableVertexAttribArray(attribs[ATTRIB_VERTEX]);
//    glEnableVertexAttribArray(attribs[ATTRIB_TEXCOORD]);
//    glVertexAttribPointer(attribs[ATTRIB_VERTEX], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
//    glVertexAttribPointer(attribs[ATTRIB_TEXCOORD], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (void*) (2 * sizeof(GLfloat)));
//}
//
//void RFFilterProgram::use()
//{
//    RFProgram::use();
//    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//    glEnableVertexAttribArray(attribs[ATTRIB_VERTEX]);
//    glEnableVertexAttribArray(attribs[ATTRIB_TEXCOORD]);
//    glVertexAttribPointer(attribs[ATTRIB_VERTEX], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
//    glVertexAttribPointer(attribs[ATTRIB_TEXCOORD], 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (void*) (2 * sizeof(GLfloat)));
//}
//
//void RFFilterProgram::draw()
//{
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//}
//
//RFFilterProgram::~RFFilterProgram()
//{
//    glDeleteBuffers(1, &vbo);
//}
