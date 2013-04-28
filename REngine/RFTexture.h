class RFTexture {
public:
    GLuint _id, texture_num;
    RFTexture(GLsizei width, GLsizei height, GLuint _texture_num);
    void activate();
    GLuint get_id();
    virtual ~RFTexture();
};
