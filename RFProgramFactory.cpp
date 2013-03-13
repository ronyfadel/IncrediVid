#import "RFProgramFactory.h"

RFProgramFactory* RFProgramFactory::shared_instance()
{
    if (_instance == NULL) {
        _instance = new RFProgramFactory();
    }
    return _instance;
}

// will try to retrieve shaders
// if it doesn't exist in the map (might not exist at all)
RFProgram* RFProgramFactory::retain_program(string v_shader_name, string f_shader_name)
{
    pair<string, string> shader_name_pair = make_pair(v_shader_name, f_shader_name);
    try {
        programs.at(shader_name_pair).second += 1;
        return programs.at(shader_name_pair).first;
    }
    catch (std::out_of_range) {
        RFProgram* new_program = new RFProgram(v_shader_name, f_shader_name);
        programs[shader_name_pair] = make_pair(new_program, 1);
        return new_program;
    }
}

// throws std::out_of_range if shader does not exist
void RFProgramFactory::release_program(string v_shader_name, string f_shader_name)
{
    pair<string, string> shader_name_pair = make_pair(v_shader_name, f_shader_name);
    pair<RFProgram*, int> program_retcount_pair = programs.at(shader_name_pair);
    program_retcount_pair.second -= 1;
    if (program_retcount_pair.second == 0) {
        delete program_retcount_pair.first;
        programs.erase(shader_name_pair);
    }
}

void RFProgramFactory::destroy_shared_instance()
{
    delete _instance; _instance = NULL;
}