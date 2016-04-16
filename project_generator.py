import os, sys, optparse, traceback
import shutil

from jinja2 import Environment, FileSystemLoader


idlparser = None
#import idl_parser

from idl_parser.parser import IDLParser

include_dirs = []

def parse_args(argv):
    optparser = optparse.OptionParser()
    optparser.add_option("-I", "--include", help="Include Directory", action="append", dest="include_dirs", default=[])
    options, args = optparser.parse_args(argv)

    include_dirs = options.include_dirs
    return args, include_dirs

def update_include_dirs(dirs):
    ret = []
    for d in dirs:
        ret.append(os.path.expandvars(d).replace('\\', '/').replace('//', '/'))
    return ret


def parse_global_module(gm, idl_identifier, description='', version='1.0.0', vendor='VENDOR_NAME', author='AUTHOR_NAME', author_short='AUTHOR', base_dir=None):
    cwd = os.getcwd()
    if base_dir is None:
        base_dir = cwd

    idl_filepath = os.path.join(base_dir, idl_identifier + '.idl')
    datatypes = parse_module(gm, idl_filepath)

    idls = [ {'filename' : idl_identifier + '.idl' } ]
    includes = idlparser.includes(idl_filepath)
    include_idls = [ {'filename' : os.path.basename(f)} for f in includes ]

    os.chdir(os.path.join('template'))
    for root, dirs, files in os.walk('.'):
        env = Environment(loader=FileSystemLoader(root, encoding='utf8'))
        for f in files:
            if not f.endswith('.tpl'):
                continue

            project_dir = os.path.join(base_dir, idl_identifier, root)
            if not os.path.isdir(project_dir):
                os.mkdir(project_dir)
            filename = f[:-4]

            file_tpl = env.get_template(filename + '.tpl')

            project = { 'name': idl_identifier,
                        'version': version,
                        'description': description,
                        'vendor': vendor,
                        'author': author,
                        'author_short': author_short }


            if filename.find('DATATYPE') < 0:
                #if root.find('include') > 0:
                    #print root, datatypes
                output_txt = file_tpl.render({'project': project,
                                              'idls' : idls,
                                              'include_idls' : include_idls,
                                              'datatypes' : datatypes })

                open(os.path.join(project_dir, filename), 'w').write(output_txt)
            else:
                for d in datatypes:
                    if d:
                        output_txt = file_tpl.render({'project': project,
                                                      'idls' : idls,
                                                      'datatype' : d })
                        outputfilename = filename.replace('DATATYPE', d['name'])
                        open(os.path.join(project_dir, outputfilename), 'w').write(output_txt)
                    
    os.chdir(cwd)

type_dict = {
    'boolean' : 'int32_t', 
    'octet': 'uint8_t',
    'char' : 'int8_t',
    'wchar' : 'int16_t',
    'short' : 'int16_t',
    'unsigned short' : 'uint16_t',
    'long' : 'int32_t',
    'unsigned long' : 'uint32_t',
    'long long' : 'int64_t',
    'unsigned long long' : 'uint64_t',
    'double' : 'double',
    'float' : 'float',
    }
             
    
def primitive_to_c(idltype):
    if idltype == 'string' or idltype == 'wstring':
        return 'error'
    return type_dict[idltype]


def parse_struct_member(member, context):
    ret = []
    if member.is_struct:
        for m in member.members:
            ret = ret + parse_member(m, context=context)
        return ret
            
def parse_member(m, context = '', verbose=False):
    global idlparser
    if idlparser.is_primitive(m.type.name, except_string=True):
        t = primitive_to_c(m.type.name)
        ret = { 'type' : t,
                'name' : context + '.' +  m.name if len(context) > 0 else m.name, }
        return [ret]
    elif m.type.name == 'string':
        return [{ 'type' : 'sequence<char>',
                  'name' : m.name,
                  'inner_type' : 'char' }]
    elif m.type.name == 'wstring':
        return [{ 'type' : 'sequence<uint16_t>',
                  'name' : m.name,
                  'inner_type' : 'uint16_t' }]
    elif m.type.is_struct:
        return parse_struct_member(m.type, m.name)
    elif m.type.is_sequence:
        if idlparser.is_primitive(m.type.inner_type.name, except_string=True):
            typename = 'sequence<%s>' % (primitive_to_c(m.type.inner_type.name))
            return [{ 'type' : typename,
                      'name' : m.name,
                      'primitive_sequence' : 'True',
                      'inner_type' : primitive_to_c(m.type.inner_type.name)} ]
        elif m.type.inner_type.name == 'string':
            sys.stdout.write('Error : parsing type %s\n' % m.type)
            return [{ 'type' : 'sequence<sequence<char> >',
                      'primitive_sequence' : 'False',
                      'name' : m.name,
                      'inner_type' : 'sequence<char>'}]
        elif m.type.inner_type.name == 'wstring':
            sys.stdout.write('Error : parsing type %s\n' % m.type)
            return [{ 'type' : 'sequence<sequence<uint16_t> >',
                      'primitive_sequence' : 'False',
                      'name' : m.name,
                      'inner_type' : 'sequence<uint16_t>' }]
        else:
            sys.stdout.write('Error : parsing type %s\n' % m.type)
            return [{ 'type' : 'error',
                      'name' : m.name }]
            
    else:
        sys.stdout.write('Error : parsing type %s\n' % m.type)
        return [{ 'type' : 'error',
                 'name' : m.name }]

    
def parse_struct(s, filename):
    args = []
    for m_ in s.members:
        if s.name == 'TimedLong':
            print m_.type
            print idlparser.is_primitive(m_.type.name)
        args = args + parse_member(m_)
    if s.name == 'TimeLong':
        print args
    return { 'name' : s.name,
             'full_path' : s.full_path.replace('::', '_'),
             'arguments' : args,
    }
    


def parse_module(m, filename):
    ms = m.modules + [m]
    datatypes = []
    for m_ in m.modules + [m]:
        def filter_func(s):
            if s.filepath is None:
                return False
            fn = os.path.basename(filename)
            return s.filepath.find(fn) >= 0

        def parse_struct_local(s):
            return parse_struct(s, filename=filename)
        datatypes = datatypes + m_.for_each_struct(parse_struct_local, filter=filter_func)
    return datatypes


def generate_directory(idl_identifier, idlpath):
    project_name = idl_identifier
    project_name_lower = project_name.lower()

    # make project dir
    base_dir = '.'
    project_dir = os.path.join(base_dir, project_name)
    os.mkdir(project_dir)

    idl_dir = os.path.join(project_dir, 'idl')
    if not os.path.isdir(idl_dir):
        os.mkdir(idl_dir)
    shutil.copy(idlpath, os.path.join(project_dir, 'idl', idlpath))

    includes = idlparser.includes(idlpath)
    for i in includes:
        shutil.copy(idlpath, os.path.join(project_dir, 'idl', i))        

    
def main(argv):
    args, include_dirs = parse_args(argv)
    include_dirs = update_include_dirs(include_dirs)

    for arg in args[1:]:
        global idlparser
        idlparser = IDLParser(idl_dirs=include_dirs)
        with open(arg, 'r') as f:
            project_name = arg[:-4]
            generate_directory(project_name, arg)

            global_module = idlparser.load(f.read(), filepath=arg)
            parse_global_module(global_module, project_name)


if __name__ == '__main__':
    main(sys.argv)
