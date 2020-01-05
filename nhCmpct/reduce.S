#include "macros.i"

.syntax unified
.cpu cortex-m4
.thumb

.global asm_barrett_reduce
.type asm_barrett_reduce,%function
.align 2
asm_barrett_reduce:
  push    {r4-r11, r14}

  poly         .req r0
  poly0        .req r1
  poly1        .req r2
  poly2        .req r3
  poly3        .req r4
  poly4        .req r5
  poly5        .req r6
  poly6        .req r7
  poly7        .req r8
  loop         .req r9
  barrettconst .req r10
  q            .req r11
  tmp          .req r12
  tmp2         .req r14

#if (NEWHOPE_N == 512)
  .equ loopcount, 32
  movw q, #3329
  movw barrettconst, #20159
#elif (NEWHOPE_N == 768)
  .equ loopcount, 48
  movw q, #3457
  movw barrettconst, #19412
#elif (NEWHOPE_N == 1024)
  .equ loopcount, 64
  movw q, #3329
  movw barrettconst, #20159
#endif

#ifdef USE_REPT
  .rept loopcount
#else
  movw loop, #loopcount
  1:
#endif

    ldm poly, {poly0-poly7}

    doublebarrett poly0, tmp, tmp2, q, barrettconst
    doublebarrett poly1, tmp, tmp2, q, barrettconst
    doublebarrett poly2, tmp, tmp2, q, barrettconst
    doublebarrett poly3, tmp, tmp2, q, barrettconst
    doublebarrett poly4, tmp, tmp2, q, barrettconst
    doublebarrett poly5, tmp, tmp2, q, barrettconst
    doublebarrett poly6, tmp, tmp2, q, barrettconst
    doublebarrett poly7, tmp, tmp2, q, barrettconst

    stm poly!, {poly0-poly7}

#ifdef USE_REPT
  .endr
#else
    subs.w loop, #1
  bne.w 1b
#endif

  pop     {r4-r11, pc}


.macro divide_mont q, qinv, a, c, tmp, tmp2
  smulbb \tmp, \a, \c
  montgomery \q, \qinv, \tmp, \tmp2
  smultb \a, \a, \c
  montgomery \q, \qinv, \a, \tmp
  pkhtb \a, \tmp, \tmp2, asr#16
.endm

.global asm_div_montconstant
.type asm_div_montconstant,%function
.align 2
asm_div_montconstant:
  push    {r4-r11, r14}
  poly        .req r0
  poly0       .req r1
  poly1       .req r2
  poly2       .req r3
  poly3       .req r4
  poly4       .req r5
  poly5       .req r6
  poly6       .req r7
  poly7       .req r8
  loop        .req r9
  constant    .req r10
  q           .req r11
  qinv        .req r11
  tmp         .req r12
  tmp2        .req r14

#if (NEWHOPE_N == 512)
  .equ loopcount, 32
  movw q, #3329
  movt qinv, #3327
#elif (NEWHOPE_N == 768)
  .equ loopcount, 48
  movw q, #3457
  movt qinv, #52607
#elif (NEWHOPE_N == 1024)
  .equ loopcount, 64
  movw q, #3329
  movt qinv, #3327
#endif

  movw constant, #1

  movw loop, #loopcount
  1:
    ldm poly, {poly0-poly7}

    divide_mont q, qinv, poly0, constant, tmp, tmp2
    divide_mont q, qinv, poly1, constant, tmp, tmp2
    divide_mont q, qinv, poly2, constant, tmp, tmp2
    divide_mont q, qinv, poly3, constant, tmp, tmp2
    divide_mont q, qinv, poly4, constant, tmp, tmp2
    divide_mont q, qinv, poly5, constant, tmp, tmp2
    divide_mont q, qinv, poly6, constant, tmp, tmp2
    divide_mont q, qinv, poly7, constant, tmp, tmp2

    stm poly!, {poly0-poly7}

    subs.w loop, #1
  bne.w 1b

  pop     {r4-r11, pc}
