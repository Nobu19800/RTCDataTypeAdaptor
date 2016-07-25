import os

from setuptools import setup, find_packages
import sys

long_description = open('README.rst', 'r').read()

packages = []
data_files = []
package_dir = 'RTCDataTypeAdaptor'

def fullsplit(path, result=None):
    """
    Split a pathname into components (the opposite of os.path.join) in a
    platform-neutral way.
    """
    if result is None:
        result = []
    head, tail = os.path.split(path)
    if head == '':
        return [tail] + result
    if head == path:
        return result
    return fullsplit(head, [tail] + result)

scripts = ['RTCDataTypeAdaptor/bin/generate_adaptor.py']

for dirpath, dirnames, filenames in os.walk(package_dir):
    # Ignore dirnames that start with '.'
    #for i, dirname in enumerate(dirnames):
    #    if dirname.startswith('.'): del dirnames[i]
    if '__init__.py' in filenames:
        packages.append('.'.join(fullsplit(dirpath)))
    elif filenames:
        data_files.append((dirpath.replace('\\', '/'), [os.path.join(dirpath, f).replace('\\', '/') for f in filenames]))


setup(name='RTCDataTypeAdaptor',
      version='0.1.1',
      url = 'http://www.sugarsweetrobotics.com/',
      author = 'ysuga',
      author_email = 'ysuga@ysuga.net',
      description = 'DataTypeAdaptor codes and solution generator',
      long_description = long_description,
      download_url = 'https://github.com/sugarsweetrobotics/RTCDataTypeAdaptor',
      packages = packages,
      data_files = data_files,
      scripts = scripts,
      #py_modules = ["pepper_kinematics"],
      license = 'GPLv3',
      install_requires = ['idl_parser'],
      classifiers = [
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Scientific/Engineering',
        ],
      #test_suite = "tests.module_test.suite",
      #package_dir = {'': 'src'}
    )
