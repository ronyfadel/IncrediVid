#import <string>
using namespace std;

string get_ios_file_path(string file_name);
string get_file_contents(string const& file_path);

class RFShader {
protected:
    GLuint _id;
    GLenum type;
    string name;
    
    void compile(string shader_source);
    void check_compilation_status(GLuint _id);
public:
    RFShader(string name, GLenum type);
    GLuint get_id();
    GLuint get_type();
    virtual ~RFShader();
};

