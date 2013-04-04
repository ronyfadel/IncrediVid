#import "RFFramebuffer.h"
#import "RFTexture.h"

class RFTextureFramebuffer : public RFFramebuffer {
    RFTexture* texture;
public:
    RFTextureFramebuffer(GLsizei _width, GLsizei _height, bool has_depth_attachement = false);
    virtual void use();
    virtual ~RFTextureFramebuffer();
};