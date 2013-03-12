#import <string>
using namespace std;

string get_ios_file_path(string file_name);
void get_file_contents(string const& filePath, char*& buffer);

class RFShader {
protected:
    GLuint _id;
    GLenum type;
    string path;
    
    void compile();
    void check_compilation_status(GLuint _id);
public:
    RFShader(GLenum type, string path);
    GLuint get_id();
    GLuint get_type();
    virtual ~RFShader();
};

