rmdir /S /Q BasicDataType ExtendedDataTypes
python project_generator.py BasicDataType.idl
python project_generator.py ExtendedDataTypes.idl -I.
