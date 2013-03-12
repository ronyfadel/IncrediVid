class RFTexture {
public:
    GLuint _id;
    RFTexture(GLsizei width, GLsizei height);
    void activate(GLuint texture_num);
    GLuint get_id();
    virtual ~RFTexture();
};