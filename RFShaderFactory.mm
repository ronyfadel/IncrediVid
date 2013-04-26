#import "RFShaderFactory.h"

RFShaderFactory* RFShaderFactory::_instance = NULL;

RFShaderFactory* RFShaderFactory::shared_instance()
{
    if (_instance == NULL) {
        _instance = new RFShaderFactory();
    }
    return _instance;
}

// will try to retrieve shaders
// if it doesn't exist in the map (might not exist at all)
GLuint RFShaderFactory::retain_shader(string shader_name, GLenum shader_type)
{
    pair<string, GLenum> name_type_pair = make_pair(shader_name, shader_type);
    try {
        shaders.at(name_type_pair).second += 1;
        return shaders.at(name_type_pair).first->get_id();
    }
    catch (std::out_of_range) {
        RFShader* new_shader = new RFShader(shader_name, shader_type);
        shaders[name_type_pair] = make_pair(new_shader, 1);
        return new_shader->get_id();
    }
}

// throws std::out_of_range if shader does not exist
void RFShaderFactory::release_shader(string shader_name, GLenum shader_type)
{
    pair<string, GLenum> name_type_pair = make_pair(shader_name, shader_type);
    pair<RFShader*, int> shader_retcount_pair = shaders.at(name_type_pair);
    shader_retcount_pair.second -= 1;
    if (shader_retcount_pair.second == 0) {
        delete shader_retcount_pair.first;
        shaders.erase(name_type_pair);
    }
}

void RFShaderFactory::destroy_shared_instance()
{
    delete _instance; _instance = NULL;
}