#import "RFTexture.h"

RFTexture::RFTexture(GLsizei width, GLsizei height, GLuint _texture_num)
{
    texture_num = _texture_num;
    glGenTextures(1, &_id);
    glActiveTexture(GL_TEXTURE0 + texture_num);
    glBindTexture(GL_TEXTURE_2D, _id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

void RFTexture::activate()
{
    glActiveTexture(GL_TEXTURE0 + texture_num);
    glBindTexture(GL_TEXTURE_2D, _id);
}

GLuint RFTexture::get_id()
{
    return _id;
}

RFTexture::~RFTexture()
{
    glDeleteTextures(1, &_id);
}
