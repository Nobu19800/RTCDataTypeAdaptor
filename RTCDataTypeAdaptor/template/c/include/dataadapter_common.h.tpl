#ifndef DATA_ADAPTER_COMMON_INCLUDED
#define DATA_ADAPTER_COMMON_INCLUDED

#include <stdint.h>

#ifdef WIN32
#ifdef {{ idls[0].filename[:-4] }}_EXPORTS
#define DATAADAPTER_API __declspec(dllexport)
#else
#define DATAADAPTER_API __declspec(dllimport)
#endif

#else
#define DATAADAPTER_API
#endif



#ifdef __cplusplus
extern "C" { 
#endif





#ifdef __cplusplus
}
#endif




#endif