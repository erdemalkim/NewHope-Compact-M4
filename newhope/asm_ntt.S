#include "macros.i"
#include "macros_ntt.i"

.syntax unified
.cpu cortex-m4
.thumb


.macro fullmontgomery a0, a1, a2, a3, a4, a5, a6, a7, tmp, tmp2, q, qinv, montconst
  movw \montconst, #4091
  doublemontgomery \a0, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a1, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a2, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a3, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a4, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a5, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a6, \tmp, \tmp2, \q, \qinv, \montconst
  doublemontgomery \a7, \tmp, \tmp2, \q, \qinv, \montconst
.endm


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

.macro fullbarrett a0, a1, a2, a3, a4, a5, a6, a7, tmp, tmp2, q, barrettconst
  movw \barrettconst, #21844
  doublebarrett_newhope \a0, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a1, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a2, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a3, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a4, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a5, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a6, \tmp, \tmp2, \q, \barrettconst
  doublebarrett_newhope \a7, \tmp, \tmp2, \q, \barrettconst
.endm


.global asm_ntt
.type asm_ntt,%function
.align 2
asm_ntt:
  push    {r4-r11, r14}

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

  movw q, #12289
  movt qinv, #12287  // gp command: Mod(-12289^-1, 2^16)

  .equ distance, NEWHOPE_N

  /* stages 1 & 2 & 3 */
#if NEWHOPE_N == 512
  .equ loopcount, 32
#elif NEWHOPE_N == 1024
  .equ loopcount, 64
#endif

#ifdef USE_REPT
  .rept loopcount
#else
  movw tmp, #loopcount
  1:
    push {tmp}
#endif

    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

    // Stage 1
    ldrh twiddle, [twiddle_ptr]
    two_doublebutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv
    fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

    // Stage 2
    ldr.w twiddle, [twiddle_ptr, #2]
    two_doublebutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv
    fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

    // Stage 3
    ldr.w twiddle, [twiddle_ptr, #6]
    two_doublebutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr, #10]
    two_doublebutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv
    fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

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

  sub poly, #distance/4
  add twiddle_ptr, #14

  .equ distance, distance/8


  /* stage 4 & 5 & 6 */
#if NEWHOPE_N == 512
  .equ loopcount2, 4
#elif NEWHOPE_N == 1024
  .equ loopcount2, 8
#endif

#ifdef USE_REPT
  .rept 8
#else
  movw tmp, #8
  2:
    push {tmp}
#endif

#ifdef USE_REPT
    .rept loopcount2
#else
    movw tmp, #loopcount2
    3:
      push {tmp}
#endif

      load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
      load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

      // Stage 4
      ldrh twiddle, [twiddle_ptr]
      two_doublebutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
      two_doublebutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv
      fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

      // Stage 5
      ldr.w twiddle, [twiddle_ptr, #2]
      two_doublebutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
      two_doublebutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv
      fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

      // Stage 6
      ldr.w twiddle, [twiddle_ptr, #6]
      two_doublebutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
      ldr.w twiddle, [twiddle_ptr, #10]
      two_doublebutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv
      fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

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

    add poly, #7*distance/4
    add twiddle_ptr, #14

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 2b
#endif

  sub poly, #NEWHOPE_N*2

  .equ distance, 16


  /* stages 7 & 8 & 9 for n=512 */
  /* stages 7 & 8 & 9 & 10 for n=1024 */
#ifdef USE_REPT
  .rept loopcount
#else
  movw tmp, #loopcount
  4:
    push {tmp}
#endif

    // ldm poly, {poly0-poly7} // This line is slower than below by 8 cycles.
    load poly, poly0, poly1, poly2, poly3, #0, #distance/4, #2*distance/4, #3*distance/4
    load poly, poly4, poly5, poly6, poly7, #distance, #5*distance/4, #6*distance/4, #7*distance/4

#if NEWHOPE_N == 1024
    // Stage 7
    ldrh twiddle, [twiddle_ptr], #2
    two_doublebutterfly b, b, poly0, poly4, poly1, poly5, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly b, b, poly2, poly6, poly3, poly7, twiddle, tmp, tmp2, q, qinv
    fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst
#endif

    // Stage 7 for NEWHOPE_N=512 and Stage 8 for NEWHOPE_N=1024
    ldr.w twiddle, [twiddle_ptr], #4
    two_doublebutterfly b, b, poly0, poly2, poly1, poly3, twiddle, tmp, tmp2, q, qinv
    two_doublebutterfly t, t, poly4, poly6, poly5, poly7, twiddle, tmp, tmp2, q, qinv
    fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

    // Stage 8 for NEWHOPE_N=512 and Stage 9 for NEWHOPE_N=1024
    ldr.w twiddle, [twiddle_ptr], #4
    two_doublebutterfly b, t, poly0, poly1, poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    two_doublebutterfly b, t, poly4, poly5, poly6, poly7, twiddle, tmp, tmp2, q, qinv
    fullmontgomery poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, qinv, montconst

    // Stage 9 for NEWHOPE_N=512 and Stage 10 for NEWHOPE_N=1024
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly0, poly1, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly2, poly3, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly4, poly5, twiddle, tmp, tmp2, q, qinv
    ldr.w twiddle, [twiddle_ptr], #4
    doublebutterfly_last_stage poly6, poly7, twiddle, tmp, tmp2, q, qinv

    fullbarrett poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, tmp, tmp2, q, montconst

    stm poly!, {poly0-poly7}

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 4b
#endif

  pop     {r4-r11, pc}
