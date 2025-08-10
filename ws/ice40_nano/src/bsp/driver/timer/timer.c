#include "timer.h"
#include <stddef.h>
#include <stdint.h>

static volatile struct timer_dev *dev = NULL;
static void (*func_timer0)(void);
static void (*func_timer1)(void);
static void (*func_timer2)(void);
static void (*func_timer3)(void);

void timer_isr(void *ctx)
{
	
	if(dev == NULL){
		return;
	}

	if(dev->inta==0){
		return;
	}

	if((dev->int0 != 0) && (func_timer0 != NULL)){
		func_timer0();
	}
	if((dev->int1 != 0) && (func_timer1 != NULL)){
		func_timer1();
	}
	if((dev->int2 != 0) && (func_timer2 != NULL)){
		func_timer2();
	}
	if((dev->int3 != 0) && (func_timer3 != NULL)){
		func_timer3();
	}
}

unsigned char timer_init(
		unsigned int base_addr,
		unsigned int prescale
)
{
	
	func_timer0 = NULL;
	func_timer1 = NULL;
	func_timer2 = NULL;
	func_timer3 = NULL;
	if(base_addr < 0x21000){
		return 1;
	}
	dev = (volatile struct timer_dev *) base_addr;
	dev->prescale = prescale;
	return 0;
}
void timer_register(unsigned char src, void (*func)())
{
	if(src==0){
		func_timer0 = func;
	}
	else if(src==1){
		func_timer1 = func;
	}
	else if(src==2){
		func_timer2 = func;
	}
	else if(src==3){
		func_timer3 = func;
	}
}
void timer_set(unsigned char src, uint32_t period, uint32_t repeat)
{
	if(dev == NULL){
		return;
	}
	if(src==0){
		dev->set0 = period;
		dev->repeat0_en = repeat;
	}
	else if(src==1){
		dev->set1 = period;
		dev->repeat1_en = repeat;
	}
	else if(src==2){
		dev->set2 = period;
		dev->repeat2_en = repeat;
	}
	else if(src==3){
		dev->set3 = period;
		dev->repeat3_en = repeat;
	}
}
void timer_disable(unsigned char src)
{
	if(dev == NULL){
		return;
	}
	if(src==0){
		dev->en0 = 0;
		dev->repeat0_en = 0;
	}
	else if(src==1){
		dev->en1 = 0;
		dev->repeat1_en = 0;
	}
	else if(src==2){
		dev->en2 = 0;
		dev->repeat2_en = 0;
	}
	else if(src==3){
		dev->en3 = 0;
		dev->repeat3_en = 0;
	}
}

void usleep(unsigned int val)
{
	if(dev == NULL){
		for (volatile unsigned int i = 0; i < val; i++) {
			asm volatile("nop");
		}
	}
	else{
		dev->set0 = val;
		while(dev->int0 == 0);
	}
}

