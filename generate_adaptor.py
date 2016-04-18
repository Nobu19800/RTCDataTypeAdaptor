import os, sys, optparse, traceback
import shutil
import RTCDataTypeAdaptor
from RTCDataTypeAdaptor import project_generator


if __name__ == '__main__':
    project_generator.main(sys.argv)
