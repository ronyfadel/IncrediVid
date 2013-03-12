#import "RFProgram.h"

#import <fstream>
#import <iostream>
#import <string>
using namespace std;

RFProgram::RFProgram(string v_shader_name, string f_shader_name):
RFProgram((new RFShader(GL_VERTEX_SHADER, get_ios_file_path(v_shader_name)))->get_id(),
          (new RFShader(GL_FRAGMENT_SHADER, get_ios_file_path(f_shader_name)))->get_id())
{
    
}

RFProgram::RFProgram(GLuint v_shader_id, GLuint f_shader_id)
{
    this->v_shader_id = v_shader_id;
    this->f_shader_id = f_shader_id;
    
    this->_id = glCreateProgram();
    this->link();
    this->check_link_status(_id);
}

void RFProgram::link()
{
    glAttachShader(_id, v_shader_id);
    glAttachShader(_id, f_shader_id);
    glLinkProgram(_id);
}

void RFProgram::check_link_status(GLuint _id)
{
    GLint status;
    glGetProgramiv (_id, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
    {
        GLint infoLogLength;
        glGetProgramiv(_id, GL_INFO_LOG_LENGTH, &infoLogLength);
        
        GLchar *strInfoLog = new GLchar[infoLogLength + 1];
        glGetProgramInfoLog(_id, infoLogLength, NULL, strInfoLog);
        fprintf(stderr, "Program Linking failed, Log: %s\n", strInfoLog);
        delete[] strInfoLog;
    }
}

void RFProgram::use() {
    glUseProgram(this->_id);
}

GLuint RFProgram::get_id() {
    return this->_id;
}

RFProgram::~RFProgram() {
    glDeleteProgram(_id);
}
