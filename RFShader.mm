#import "RFShader.h"

#import <string>
#import <fstream>
#import <iostream>
using namespace std;

string get_ios_file_path(string file_name)
{
    NSString* ns_file_name = [NSString stringWithCString:file_name.c_str() encoding:NSASCIIStringEncoding];
    NSString* name = [[ns_file_name lastPathComponent] stringByDeletingPathExtension];
    NSString* extension = [ns_file_name pathExtension];
    
    string str([[[NSBundle mainBundle] pathForResource:name ofType:extension] cStringUsingEncoding:NSASCIIStringEncoding]);
    return str;
}

string get_file_contents(string const& file_path)
{
    string source;
    ifstream file(file_path.c_str());
    if (!file.is_open()) {
        throw std::runtime_error("could not open file!");
    }
    file.seekg(0, std::ios::end);
    source.reserve(file.tellg());
    file.seekg(0, std::ios::beg);
    source.assign((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
    
    return source;
}

RFShader::RFShader(string name, GLenum type)
{
    this->_id = glCreateShader(type);
    this->type = type;
    this->name = name;
    
    this->compile(get_file_contents(get_ios_file_path(name)).c_str());
    
    this->check_compilation_status(_id);
}

void RFShader::compile(string shader_source)
{
    const char* shader_source_c_str = shader_source.c_str();
    glShaderSource(_id, 1, &shader_source_c_str, NULL);
    glCompileShader(_id);
    check_compilation_status(_id);
}

void RFShader::check_compilation_status(GLuint _id)
{
    GLint status;
    glGetShaderiv(_id, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE)
    {
        GLint infoLogLength;
        glGetShaderiv(_id, GL_INFO_LOG_LENGTH, &infoLogLength);
        
        GLchar *strInfoLog = new GLchar[infoLogLength + 1];
        glGetShaderInfoLog(_id, infoLogLength, NULL, strInfoLog);
        
        const char *strtype = NULL;
        switch(type)
        {
            case GL_VERTEX_SHADER:
                strtype = "vertex";
                break;
            case GL_FRAGMENT_SHADER:
                strtype = "fragment";
                break;
        }
        
        fprintf(stderr, "Failed to compile %s shader, Log:\n%s\n", strtype, strInfoLog);
        delete[] strInfoLog;
    }
}

GLuint RFShader::get_id()
{
    return this->_id;
}

GLuint RFShader::get_type()
{
    return this->type;
}

RFShader::~RFShader()
{
    glDeleteShader(this->_id);
}