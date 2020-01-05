#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef HAL_H
#define HAL_H

enum clock_mode {
    CLOCK_FAST,
    CLOCK_BENCHMARK
};

void hal_setup(const enum clock_mode clock);
void hal_send_str(const char* in);
void hal_send_rstr(const char* in);
void printbytes(unsigned char* v, unsigned int len);
uint64_t hal_get_time(void);

#endif
