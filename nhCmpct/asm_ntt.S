#include "macros.i"
#include "macros_ntt.i"
#include "params.h"

.syntax unified
.cpu cortex-m4
.thumb

#if (NEWHOPE_N == 768)
.macro doublebutterfly_first_stage a0, a1, twiddle, tmp, tmp2, q, qinv
  smulbb \tmp, \a1, \twiddle
  smultb \tmp2, \a1, \twiddle
#ifdef OPTIMIZE_STACK
  montgomery \q, \qinv, \tmp, \twiddle
  montgomery \q, \qinv, \tmp2, \tmp
  pkhtb \tmp2, \tmp, \twiddle, asr#16
#else
  pkhbt \tmp2, \tmp, \tmp2, lsl#16
#endif
  uadd16 \a1, \a0, \a1
  usub16 \a1, \a1, \tmp2
  uadd16 \a0, \a0, \tmp2
.endm
#endif

.global asm_ntt
.type asm_ntt,%function
.align 2
asm_ntt:
  push    {r4-r11, r14}

  poly         .req r0
  twiddle_ptr  .req r1
  poly0        .req r2
  poly1        .req r3
  poly2        .req r4
  poly3        .req r5
  poly4        .req r6
  poly5        .req r7
  poly6        .req r8
  poly7        .req r9
  twiddle      .req r10
  montconst    .req r10
  barrettconst .req r10
  qinv         .req r11
  q            .req r11
  tmp          .req r12
  tmp2         .req r14

#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
  movw q, #3329
  movt qinv, #3327  // gp command: Mod(-3329^-1, 2^16)
  .equ montgomery_constant, 2285
  .equ barrett_constant, 20159
#elif (NEWHOPE_N == 768)
  movw q, #3457
  movt qinv, #52607 // gp command: Mod(-3457^-1, 2^16)
  .equ montgomery_constant, 3310
  .equ barrett_constant, 19412
#endif

  .equ distance, 128

  /* stages 1 & 2 & 3 */
#ifdef USE_REPT
  .rept 8
#else
  movw tmp, #8
  1:
    push {tmp}
#endif

    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    // Stage 1
    ldrh twiddle, [twiddle_ptr]
#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
#ifdef OPTIMIZE_STACK
    two_doublebutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv
#else
    two_doublebutterfly_no_montgomery poly0, poly4, poly1, poly5, twiddle, tmp, tmp2
    two_doublebutterfly_no_montgomery poly2, poly6, poly3, poly7, twiddle, tmp, tmp2
#endif
#elif (NEWHOPE_N == 768)
    doublebutterfly_first_stage poly0, poly4, twiddle, tmp, tmp2, q, qinv
    ldrh twiddle, [twiddle_ptr]
    doublebutterfly_first_stage poly1, poly5, twiddle, tmp, tmp2, q, qinv
    ldrh twiddle, [twiddle_ptr]
    doublebutterfly_first_stage poly2, poly6, twiddle, tmp, tmp2, q, qinv
    ldrh twiddle, [twiddle_ptr]
    doublebutterfly_first_stage poly3, poly7, twiddle, tmp, tmp2, q, qinv
#endif

    // Stage 2
    ldr.w twiddle, [twiddle_ptr, #2]
    two_doublebutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 3
    ldr.w twiddle, [twiddle_ptr, #6]
    two_doublebutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr, #10]
    two_doublebutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    store poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4
    str.w poly1, [poly, #distance/4]
    str.w poly2, [poly, #2*distance/4]
    str.w poly3, [poly, #3*distance/4]
    str.w poly0, [poly], #4

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 1b
#endif

  sub poly, #32
  add twiddle_ptr, #14

  .equ distance, distance/8

  /* stage 4 & 5 & 6 & 7 */
#ifdef USE_REPT
  .rept 8
#else
  movw tmp, #8
  2:
    push {tmp}
#endif

    // ldm poly, {poly0-poly7} // This line is slower than below by 8 cycles.
    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    // Stage 4
    ldrh twiddle, [twiddle_ptr], #2
    two_doublebutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 5
    ldr.w twiddle, [twiddle_ptr], #4
    two_doublebutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 6
    ldr.w twiddle, [twiddle_ptr], #4
    two_doublebutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    two_doublebutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 7
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly0, poly1, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly4, poly5, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly6, poly7, twiddle, tmp, tmp2, q, qinv

    movw barrettconst, #barrett_constant
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
    pop {tmp}
    subs.w tmp, #1
  bne.w 2b
#endif

  pop     {r4-r11, pc}
