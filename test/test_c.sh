

# rem rmdir /S /Q BasicDataType ExtendedDataTypes InterfaceDataTypes
# python RTCDataTypeAdaptor/bin/generate_adaptor.py test/BasicDataType.idl -bcs -v
python RTCDataTypeAdaptor/bin/generate_adaptor.py test/BasicDataType.idl -bc -v -o test_out_c
# python project_generator.py ExtendedDataTypes.idl -I.
# python project_generator.py InterfaceDataTypes.idl -I.
# python project_generator.py CarSimulator.idl -I.

