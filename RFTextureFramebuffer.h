#import "RFFramebuffer.h"
#import "RFTexture.h"

class RFTextureFramebuffer : public RFFramebuffer {
public:
    RFTexture* texture;
    
    RFTextureFramebuffer(GLsizei _width, GLsizei _height, bool has_depth_attachement = false);
    virtual ~RFTextureFramebuffer();
};