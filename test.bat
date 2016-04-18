rem rmdir /S /Q BasicDataType ExtendedDataTypes InterfaceDataTypes
rem python project_generator.py BasicDataType.idl
rem python project_generator.py ExtendedDataTypes.idl -I.
rem python project_generator.py InterfaceDataTypes.idl -I.
python project_generator.py CarSimulator.idl -I.

