#ifndef _I2C_CONTROLLER_H_
#define _I2C_CONTROLLER_H_
#include "gpio.h"


int i2c_write(unsigned char slave, unsigned short offset, unsigned int count, unsigned char *val) ;
int i2c_read(unsigned char slave, unsigned short offset, unsigned int count, unsigned char *val) ;
int i2c_byte_write(unsigned char slave, unsigned short offset, unsigned char val);
int i2c_byte_read(unsigned char slave, unsigned short offset, unsigned char *val);


#endif

