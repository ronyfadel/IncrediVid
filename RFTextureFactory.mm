#import <string>
using namespace std;
#import "RFTextureFactory.h"
#import "RFShader.h"

RFTextureFactory* RFTextureFactory::_instance = NULL;

RFTextureFactory* RFTextureFactory::shared_instance()
{
    if (_instance == NULL) {
        _instance = new RFTextureFactory();
    }
    return _instance;
}

void RFTextureFactory::destroy_shared_instance()
{
    delete _instance; _instance = NULL;
}

// will try to retrieve shaders
// if it doesn't exist in the map (might not exist at all) -> throws out of range
GLuint RFTextureFactory::retain_texture(string texture_name, RFTEXTURE_TYPE texture_type, unsigned char *texture_data, int width, int height)
{
    try {
        textures.at(texture_name).second += 1;
        return textures.at(texture_name).first;
    } catch (std::out_of_range) {
        GLuint texture_id;
        switch (texture_type) {
            case PNG_FILE:
            {
                string texture_path = get_ios_file_path(texture_name);
                UIImage* texture = [UIImage imageWithContentsOfFile:[NSString stringWithCString:texture_path.c_str() encoding:NSASCIIStringEncoding]];
                
                // First get the image into your data buffer
                CGImageRef imageRef = [texture CGImage];
                NSUInteger width = CGImageGetWidth(imageRef);
                NSUInteger height = CGImageGetHeight(imageRef);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
                NSUInteger bytesPerPixel = 4;
                NSUInteger bytesPerRow = bytesPerPixel * width;
                NSUInteger bitsPerComponent = 8;
                CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                             bitsPerComponent, bytesPerRow, colorSpace,
                                                             kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
                CGColorSpaceRelease(colorSpace);
                
                CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
                CGContextRelease(context);
                
                glGenTextures(1, &texture_id);
                glActiveTexture(GL_TEXTURE4);
                glBindTexture(GL_TEXTURE_2D, texture_id);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawData);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                free(rawData);
                break;
            }
            case LUMINANCE_MEMORY:
            {
                glGenTextures(1, &texture_id);
                glActiveTexture(GL_TEXTURE4);
                glBindTexture(GL_TEXTURE_2D, texture_id);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, texture_data);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                break;
            }
            default:
                break;
        }
        textures[texture_name] = make_pair(texture_id, 1);
        return texture_id;
    }
}

// throws std::out_of_range if shader does not exist
void RFTextureFactory::release_texture(string texture_name)
{
    pair<GLuint, int> texture_refcount_pair = textures.at(texture_name);
    texture_refcount_pair.second -= 1;
    if (texture_refcount_pair.second == 0) {
        glDeleteTextures(1, &texture_refcount_pair.first);
        textures.erase(texture_name);
    }
}
