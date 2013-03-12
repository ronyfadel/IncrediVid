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

void get_file_contents(string const& filePath, char*& buffer)
{
    ifstream file(filePath.c_str(), ios::in | ios::binary | ios::ate);
    
    if (file.is_open())
    {
        long long size = file.tellg();
        buffer = new char[size + 1];
        file.seekg(ios::beg);
        file.read(buffer, size);
        buffer[size] = '\0';
    }
    else
    {
        cerr<<"Unable to open "<<filePath<<endl;
    }
}


RFShader::RFShader(GLenum type, string name)
{
    this->_id = glCreateShader(type);
    this->type = type;
    this->path = get_ios_file_path(name);
    
    this->compile();
    this->check_compilation_status(_id);
}

void RFShader::compile()
{
    char* shader_source = NULL;
    get_file_contents(path, shader_source);
    
    if (!shader_source) {
        throw "Could not find shader";
    }
    
    glShaderSource(_id, 1, (const char**)&shader_source, NULL);
    
    delete[] shader_source;
    
    glCompileShader(_id);
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