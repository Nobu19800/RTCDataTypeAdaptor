rem rmdir /S /Q BasicDataType ExtendedDataTypes InterfaceDataTypes
rem python project_generator.py BasicDataType.idl
rem python project_generator.py ExtendedDataTypes.idl -I.
rem python project_generator.py InterfaceDataTypes.idl -I.
rem python project_generator.py CarSimulator.idl -I.

python ../generate_adaptor.py BasicDataType.idl -bc
