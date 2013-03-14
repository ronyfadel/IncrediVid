#import <fstream>
#import <iostream>
#import <string>
using namespace std;

#import "RFProgram.h"
#import "RFShaderFactory.h"

RFProgram::RFProgram(string v_shader_name, string f_shader_name)
{
    RFShaderFactory* shared_instance = RFShaderFactory::shared_instance();
    this->v_shader_id = shared_instance->retain_shader(v_shader_name, GL_VERTEX_SHADER);
    this->f_shader_id = shared_instance->retain_shader(f_shader_name, GL_FRAGMENT_SHADER);
    this->v_shader_name = v_shader_name;
    this->f_shader_name = f_shader_name;
    
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

string RFProgram::get_v_shader_name()
{
    return v_shader_name;
}

string RFProgram::get_f_shader_name()
{
    return f_shader_name;
}

void RFProgram::use()
{
    glUseProgram(this->_id);
}

void RFProgram::stop_using()
{
    glUseProgram(0);
}

GLuint RFProgram::get_id()
{
    return this->_id;
}

RFProgram::~RFProgram()
{
    RFShaderFactory* shared_instance = RFShaderFactory::shared_instance();
    shared_instance->release_shader(v_shader_name, GL_VERTEX_SHADER);
    shared_instance->release_shader(f_shader_name, GL_FRAGMENT_SHADER);
    glDeleteProgram(_id);
}
