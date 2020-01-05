#include "macros.i"
#include "macros_invntt.i"

.syntax unified
.cpu cortex-m4
.thumb

#if (NEWHOPE_N == 768)
.macro doubleinvbutterfly_last_stage a0, a1, twiddle, tmp, tmp2, q, qinv
  usub16 \tmp, \a0, \a1
  uadd16 \a0, \a0, \a1

  smulbb \a1, \tmp, \twiddle
  smultb \tmp, \tmp, \twiddle
  montgomery \q, \qinv, \a1, \tmp2
  montgomery \q, \qinv, \tmp, \a1
  pkhtb \a1, \a1, \tmp2, asr#16

  usub16 \a0, \a0, \a1
  smulbt \tmp, \a0, \twiddle
  smultt \tmp2, \a0, \twiddle
  montgomery \q, \qinv, \tmp, \a0
  montgomery \q, \qinv, \tmp2, \tmp
  pkhtb \a0, \tmp, \a0, asr#16
.endm

.macro two_doubleinvbutterfly_last_stage a0, a1, a2, a3, twiddle, tmp, tmp2, q, qinv
  doubleinvbutterfly_last_stage \a0, \a1, \twiddle, \tmp, \tmp2, \q, \qinv
  doubleinvbutterfly_last_stage \a2, \a3, \twiddle, \tmp, \tmp2, \q, \qinv
.endm
#endif

.global asm_invntt
.type asm_invntt,%function
.align 2
asm_invntt:
  push {r4-r11, r14}

  poly        .req r0
  twiddle_ptr .req r1
  poly0       .req r2
  poly1       .req r3
  poly2       .req r4
  poly3       .req r5
  poly4       .req r6
  poly5       .req r7
  poly6       .req r8
  poly7       .req r9
  twiddle     .req r10
  montconst   .req r10
  qinv        .req r11
  q           .req r11
  tmp         .req r12
  tmp2        .req r14

#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
  movw q, #3329
  movt qinv, #3327  // gp command: Mod(-3329^-1, 2^16)
  .equ montgomery_constant, 2285
#elif (NEWHOPE_N == 768)
  movw q, #3457
  movt qinv, #52607 // gp command: Mod(-3457^-1, 2^16)
  .equ montgomery_constant, 3310
#endif

  .equ distance, 16

  /* stage 7 & 6 & 5 & 4 */
#ifdef USE_REPT
  .rept 8
#else
  movw tmp, #8
  1:
    push {tmp}
#endif

    // ldm poly, {poly0-poly7} // This line is slower than below by 8 cycles.
    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    // Stage 7
    ldr.w twiddle, [twiddle_ptr], #4
    doubleinvbutterfly_first_stage poly0, poly1, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doubleinvbutterfly_first_stage poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doubleinvbutterfly_first_stage poly4, poly5, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doubleinvbutterfly_first_stage poly6, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 6
    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 5
    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    movw montconst, #montgomery_constant
    doublemontgomery poly0, tmp, tmp2, q, qinv, montconst
    doublemontgomery poly1, tmp, tmp2, q, qinv, montconst

    // Stage 4
    ldrh twiddle, [twiddle_ptr], #2
    two_doubleinvbutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    stm poly!, {poly0-poly7}

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 1b
#endif

  sub poly, #256

  .equ distance, 128

  /* stage 3 & 2 & 1 */
#ifdef USE_REPT
  .rept 4
#else
  movw tmp, #8
  2:
    push {tmp}
#endif

    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    // Stage 3
    ldr.w twiddle, [twiddle_ptr]
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr, #4]
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 2
    ldr.w twiddle, [twiddle_ptr, #8]
    two_doubleinvbutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

#ifndef USE_REPT
    pop {tmp}
    cmp tmp, #4
    blt nomontgomery

    push {tmp}
#endif

    movw montconst, #montgomery_constant
    doublemontgomery poly0, tmp, tmp2, q, qinv, montconst
    doublemontgomery poly1, tmp, tmp2, q, qinv, montconst

#ifndef USE_REPT
    b nomontgomery_skippush

  nomontgomery:
    push {tmp}

  nomontgomery_skippush:
#endif

    // Stage 1
    ldr.w twiddle, [twiddle_ptr, #12]
#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
    two_doubleinvbutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    fqmulprecomp poly0, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly1, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly2, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly3, twiddle, tmp, tmp2, q, qinv
#elif (NEWHOPE_N == 768)
    two_doubleinvbutterfly_last_stage poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly_last_stage poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    ldr.w twiddle, [twiddle_ptr, #14]
    fqmulprecomp poly4, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly5, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly6, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly7, twiddle, tmp, tmp2, q, qinv
#endif

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
  bne.w 2b
#endif

#ifdef USE_REPT
  .rept 4
    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    // Stage 3
    ldr.w twiddle, [twiddle_ptr]
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr, #4]
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 2
    ldr.w twiddle, [twiddle_ptr, #8]
    two_doubleinvbutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    // Stage 1
    ldr.w twiddle, [twiddle_ptr, #12]
#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
    two_doubleinvbutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    fqmulprecomp poly0, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly1, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly2, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly3, twiddle, tmp, tmp2, q, qinv
#elif (NEWHOPE_N == 768)
    two_doubleinvbutterfly_last_stage poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly_last_stage poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    ldr.w twiddle, [twiddle_ptr, #16]
    fqmulprecomp poly4, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly5, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly6, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly7, twiddle, tmp, tmp2, q, qinv
#endif

    store poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4
    str.w poly1, [poly, #distance/4]
    str.w poly2, [poly, #2*distance/4]
    str.w poly3, [poly, #3*distance/4]
    str.w poly0, [poly], #4
  .endr
#endif

  pop {r4-r11, pc}
