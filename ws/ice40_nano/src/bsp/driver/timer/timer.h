#ifndef _TIMER_H_
#define _TIMER_H_
#include <stdint.h>
// timer0 is used for delay function

#define TMER0_INT	0x001
#define TMER1_INT	0x002
#define TMER2_INT	0x004
#define TMER3_INT	0x008

#define TMER0_SRC	0x00
#define TMER1_SRC	0x01
#define TMER2_SRC	0x02
#define TMER3_SRC	0x03

#define TIMER_REPEAT 0x01
#define TIMER_ONESHOT 0x00


struct timer_dev {
	volatile unsigned inta       ;// Alarm all (readonly)
	volatile unsigned clocks     ;//  Clocks
	volatile unsigned ticks      ;//  Ticks
	volatile unsigned prescale   ;//  Prescale
	volatile unsigned int0       ;// Alarm0 / interrupts
	volatile unsigned int1       ;// Alarm1 / interrupts
	volatile unsigned int2       ;// Alarm2 / interrupts
	volatile unsigned int3       ;// Alarm3 / interrupts
	volatile unsigned repeat0_en ;//  Alarm0 repeat enable
	volatile unsigned repeat1_en ;//  Alarm1 repeat enable
	volatile unsigned repeat2_en ;//  Alarm2 repeat enable
	volatile unsigned repeat3_en ;//  Alarm3 repeat enable
	volatile unsigned set0       ;// Alarm0 set & enable
	volatile unsigned set1       ;// Alarm1 set & enable
	volatile unsigned set2       ;// Alarm2 set & enable
	volatile unsigned set3       ;// Alarm3 set & enable
	volatile unsigned end0       ;// Alarm0 end time
	volatile unsigned end1       ;// Alarm1 end time
	volatile unsigned end2       ;// Alarm2 end time
	volatile unsigned end3       ;// Alarm3 end time
	volatile unsigned en0        ;// Alarm0 enable/disable
	volatile unsigned en1        ;// Alarm1 enable/disable
	volatile unsigned en2        ;// Alarm2 enable/disable
	volatile unsigned en3        ;// Alarm3 enable/disable
};

void timer_isr(void *ctx);
unsigned char timer_init(
		unsigned int base_addr,
		unsigned int prescale);
void timer_register(unsigned char src, void (*func)());
void timer_set(unsigned char src, uint32_t period, uint32_t repeat);
void timer_disable(unsigned char src);
void usleep(unsigned int val);

#endif
