
#include "gpio.h"
#include "timer.h"


#define SDA_PIN GPIO0
#define SCL_PIN GPIO1

#define gpio_set_output(pin)	gpio_set_direction(&gpio_inst, pin, GPIO_OUTPUT)
#define gpio_set_input(pin)	gpio_set_direction(&gpio_inst, pin, GPIO_INPUT)
#define gpio_write(pin, val)	gpio_output_write(&gpio_inst, pin, val)
#define gpio_read(pin, val)		gpio_input_get(&gpio_inst, pin, val)
#define i2c_delay(n)            usleep(n)

extern struct gpio_instance gpio_inst;

static void i2c_start() {
    gpio_set_input(SCL_PIN);
    gpio_set_input(SDA_PIN);
    gpio_write(SDA_PIN, 0);
    gpio_write(SCL_PIN, 0);
    i2c_delay(10);
    gpio_set_output(SDA_PIN);
    i2c_delay(10);
    gpio_set_output(SCL_PIN);
}

static void i2c_stop() {
    gpio_set_output(SDA_PIN);
    gpio_set_input(SCL_PIN);
    i2c_delay(10);
    gpio_set_input(SDA_PIN);
    i2c_delay(10);
}

static void i2c_write_bit(int bit) {
    if(bit!=0){
        gpio_set_input(SDA_PIN);
    }
    else{
        gpio_set_output(SDA_PIN);
    }
    i2c_delay(10);
    gpio_set_input(SCL_PIN);
    i2c_delay(10);
    gpio_set_output(SCL_PIN);
}

static int i2c_read_bit() {
    uint16_t bit;
    gpio_set_input(SDA_PIN);
    i2c_delay(10);
    gpio_set_input(SCL_PIN);
    gpio_read(SDA_PIN, &bit);
    i2c_delay(10);
    gpio_set_output(SCL_PIN);
    gpio_set_output(SDA_PIN);
    return bit;
}

static int i2c_write_byte(uint8_t byte) {
    for (int i = 0; i < 8; i++) {
        i2c_write_bit((byte >> (7 - i)) & 1);
    }
    return i2c_read_bit(); // ACK
}

static uint8_t i2c_read_byte(int ack) {
    uint8_t byte = 0;
    for (int i = 0; i < 8; i++) {
        byte = (byte << 1) | i2c_read_bit();
    }
    i2c_write_bit(!ack); // ACK = 0, NACK = 1
    return byte;
}


int i2c_write(unsigned char slave, unsigned short offset, unsigned int count, unsigned char *val) {

	unsigned char tmp;
    i2c_start();

    // 7bits slave address + write bit (0)
    if (i2c_write_byte((slave << 1) | 0) != 0) {
        i2c_stop();
        return -1; // NACK
    }

    // write 2bytes offset
    tmp = (unsigned char)((offset >> 8) & 0xff);
    if (i2c_write_byte(tmp) != 0) {
        i2c_stop();
        return -2;
    }
    tmp = (unsigned char)(offset & 0xff);
    if (i2c_write_byte(tmp) != 0) {
        i2c_stop();
        return -2;
    }

    // output data
    for (unsigned int i = 0; i < count; i++) {
        if (i2c_write_byte(val[i]) != 0) {
            i2c_stop();
            return -3;
        }
    }

    i2c_stop();
    return 0;
}

int i2c_read(unsigned char slave, unsigned short offset, unsigned int count, unsigned char *val) {

	unsigned char tmp;
    i2c_start();

    // 7bits slave address + write bit (0)
    if (i2c_write_byte((slave << 1) | 0) != 0) {
        i2c_stop();
        return -1;
    }

    // write 2bytes offset
    tmp = (unsigned char)((offset >> 8) & 0xff);
    if (i2c_write_byte(tmp) != 0) {
        i2c_stop();
        return -2;
    }
    tmp = (unsigned char)(offset & 0xff);
    if (i2c_write_byte(tmp) != 0) {
        i2c_stop();
        return -2;
    }

    // restart
    i2c_start();

    // 7bits slave address + write bit (1)
    if (i2c_write_byte((slave << 1) | 1) != 0) {
        i2c_stop();
        return -3;
    }

    // input data
    for (unsigned int i = 0; i < count; i++) {
        val[i] = i2c_read_byte(i < (count - 1)); // NACK at last byte
    }

    i2c_stop();
    return 0;
}


int i2c_byte_write(unsigned char slave, unsigned short offset, unsigned char val)
{
	return i2c_write(slave, offset, 1, &val);
}
int i2c_byte_read(unsigned char slave, unsigned short offset, unsigned char *val)
{
	return i2c_read(slave, offset, 1, val) ;
}

