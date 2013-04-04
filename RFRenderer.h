#import "RFGLView.h"

class RFRenderer {
protected:
    RFGLView* view;
public:
    RFRenderer(UIView* superview);
    void set_culling(bool enabled);
    void clear_display(GLbitfield mask = (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
    virtual void setup();
    virtual void render();
    RFGLView* get_view(){return view;}
};