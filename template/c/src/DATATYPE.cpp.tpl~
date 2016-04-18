#include <vector>
#include <memory>
#include <rtm/idl/BasicDataTypeSkel.h>
#include <rtm/Manager.h>
#include <rtm/DataInPort.h>
#include <rtm/DataOutPort.h>

#include "ports/timeddoubleseq.h"

static std::vector<std::shared_ptr<RTC::TimedDoubleSeq> > _data;
static std::vector<std::shared_ptr<RTC::PortBase> >* __ports;

#define CHECK_PORT_ID(port) do {if(port<0 || port>=__ports->size()){return RESULT_INVALID_PORT;} }while(false)


Result_t TimedDoubleSeq_registerDataType(void* portBuffer) {
  __ports = static_cast<std::vector<std::shared_ptr<RTC::PortBase> >* >(portBuffer);
  return RESULT_OK;
}

DataType_t TimedDoubleSeq_create() {
  _data.push_back(std::shared_ptr<RTC::TimedDoubleSeq>(new RTC::TimedDoubleSeq()));
  return _data.size() -1;
}

Result_t TimedDoubleSeq_set(DataType_t d, uint32_t sec, uint32_t nsec, double* data, uint32_t size) {
	if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }

  _data[d]->tm.sec = sec;
  _data[d]->tm.nsec = nsec;
  _data[d]->data.length(size);
  for (uint32_t i = 0;i < size;i++) {
    _data[d]->data[i] = data[i];
  }
}

Result_t TimedDoubleSeq_data_Length(DataType_t d, uint32_t* size) {
	if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }

	*size = _data[d]->data.length();
}

Result_t TimedDoubleSeq_get(DataType_t d, uint32_t* sec, uint32_t* nsec, double* data, uint32_t* size) {
	if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  *sec = _data[d]->tm.sec;
  *nsec = _data[d]->tm.nsec;

  uint32_t max_size = *size;

  for(uint32_t i = 0;i < max_size && i < _data[d]->data.length();i++) {
    data[i] = _data[d]->data[i];
	*size = i;
  }
}

Port_t InPort_TimedDoubleSeq_create(char* name, DataType_t d) {
	if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  __ports->push_back(std::shared_ptr<RTC::PortBase>(new RTC::InPort<RTC::TimedDoubleSeq>(name, *(_data[d]))));
  return __ports->size() - 1;
}

Port_t OutPort_TimedDoubleSeq_create(char* name, DataType_t d) {
	if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  __ports->push_back(std::shared_ptr<RTC::PortBase>(new RTC::OutPort<RTC::TimedDoubleSeq>(name, *(_data[d]))));
  return __ports->size() - 1;
}


Result_t InPort_TimedDoubleSeq_isNew(Port_t port, int32_t* flag) {
  CHECK_PORT_ID(port);
  std::shared_ptr<RTC::InPort<RTC::TimedDoubleSeq> > inport = std::dynamic_pointer_cast<RTC::InPort<RTC::TimedDoubleSeq> >((*__ports)[port]);
  if (inport == nullptr) { return RESULT_INVALID_PORT; }

  *flag = inport->isNew() ? 1 : 0;
  return RESULT_OK;
}
