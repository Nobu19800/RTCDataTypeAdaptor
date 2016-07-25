import os, sys, optparse, traceback
import shutil
import RTCDataTypeAdaptor
from RTCDataTypeAdaptor import project_generator


if __name__ == '__main__':
    args = ["test.py", "idl/BasicDataType.idl", "-bc", "-v", "-o", "test_out_c"]
    project_generator.main(args)

    args = ["test.py", "idl/BasicDataType.idl", "-bcs", "-v", "-o", "test_out_cs"]
    project_generator.main(args)
