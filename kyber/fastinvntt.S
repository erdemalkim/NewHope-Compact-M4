#include "macros.i"
#include "macros_invntt.i"

.syntax unified
.cpu cortex-m4
.thumb

.macro fullmontgomery a0, a1, a2, a3, tmp, tmp2, q, qinv, montconst
  movw \montconst, #2285
  doublemontgomery \a0, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a1, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a2, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a3, \tmp, \tmp2, \q, \qinv, \montconst
.endm

.global invntt_fast
.type invntt_fast, %function
.align 2
invntt_fast:
  push {r4-r11, lr}

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

  movw q, #3329
  movt qinv, #3327

  ### LAYER 1 (skip layer 0)
#ifdef USE_REPT
  .rept 16
#else
  movw tmp, #16
  1:
    push {tmp}
#endif

    ldm poly, {poly0-poly7}

    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    fullmontgomery poly0, poly2, poly4, poly6, tmp, tmp2, q, qinv, montconst

    stm poly!, {poly0-poly7}

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 1b
#endif

  sub.w poly, #512

  .equ distance, 32

  ### LAYER 2+3+4
#ifdef USE_REPT
  .rept 8
#else
  movw tmp, #8
  2:
    push {tmp}
#endif

    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    ldr.w twiddle, [twiddle_ptr]
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr, #4]
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    ldr.w twiddle, [twiddle_ptr, #8]
    two_doubleinvbutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    ldrh twiddle, [twiddle_ptr, #12]
    two_doubleinvbutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    fullmontgomery poly0, poly1, poly2, poly3, tmp, tmp2, q, qinv, montconst

    store poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4
    str.w poly1, [poly, #distance/4]
    str.w poly2, [poly, #2*distance/4]
    str.w poly3, [poly, #3*distance/4]
    str.w poly0, [poly], #4

    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    ldr.w twiddle, [twiddle_ptr], #4
    two_doubleinvbutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    ldrh twiddle, [twiddle_ptr], #2
    two_doubleinvbutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

	  fullmontgomery poly0, poly1, poly2, poly3, tmp, tmp2, q, qinv, montconst

    store poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4
    str.w poly1, [poly, #distance/4]
    str.w poly2, [poly, #2*distance/4]
    str.w poly3, [poly, #3*distance/4]
    str.w poly0, [poly], #60

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 2b
#endif

  sub.w poly, #512

  .equ distance, 8*distance

  ### LAYER 5+6+7
#ifdef USE_REPT
  .rept 16
#else
  movw tmp, #16
  3:
    push {tmp}
#endif

    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    ldr.w twiddle, [twiddle_ptr]
    two_doubleinvbutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr, #4]
    two_doubleinvbutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv

    ldr.w twiddle, [twiddle_ptr, #8]
    two_doubleinvbutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv

    ldr.w twiddle, [twiddle_ptr, #12]
    two_doubleinvbutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doubleinvbutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv

    fqmulprecomp poly0, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly1, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly2, twiddle, tmp, tmp2, q, qinv
    fqmulprecomp poly3, twiddle, tmp, tmp2, q, qinv

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
  bne.w 3b
#endif

  pop {r4-r11, pc}
