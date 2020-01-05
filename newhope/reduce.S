#include "macros.i"

.syntax unified
.cpu cortex-m4
.thumb

.macro doublebarrett_newhope a, tmp, tmp2, q, barrettconst
  smulbb \tmp, \a, \barrettconst
  smultb \tmp2, \a, \barrettconst
  asr \tmp, \tmp, #28
  asr \tmp2, \tmp2, #28
  smulbb \tmp, \tmp, \q
  smulbb \tmp2, \tmp2, \q
  pkhbt \tmp, \tmp, \tmp2, lsl#16
  usub16 \a, \a, \tmp
.endm

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
#elif (NEWHOPE_N == 1024)
  .equ loopcount, 64
#endif

  movw q, #12289
  movw barrettconst, #21844

  movw loop, #loopcount
  1:

    ldm poly, {poly0-poly7}

    doublebarrett_newhope poly0, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly1, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly2, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly3, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly4, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly5, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly6, tmp, tmp2, q, barrettconst
    doublebarrett_newhope poly7, tmp, tmp2, q, barrettconst

    stm poly!, {poly0-poly7}

    subs.w loop, #1
  bne.w 1b

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
#elif (NEWHOPE_N == 1024)
  .equ loopcount, 64
#endif

  movw q, #12289
  movt qinv, #12287
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
