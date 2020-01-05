.syntax unified
.cpu cortex-m4
.thumb

.macro doublebarrett a, tmp, tmp2, q, barrettconst
  smulbt \tmp, \a, \barrettconst
  smultt \tmp2, \a, \barrettconst
  asr \tmp, \tmp, #26
  asr \tmp2, \tmp2, #26
  smulbb \tmp, \tmp, \q
  smulbb \tmp2, \tmp2, \q
  pkhbt \tmp, \tmp, \tmp2, lsl#16
  usub16 \a, \a, \tmp
.endm

.global asm_add
.type asm_add,%function
.align 2
asm_add:
  push    {r4-r11, r14}
  loop          .req r12
  q             .req r14
  barrettconst  .req r14

#if (NEWHOPE_N == 512)
  .equ loopcount, 51
  movw q, #3329
  movt barrettconst, #20159
#elif (NEWHOPE_N == 768)
  .equ loopcount, 76
  movw q, #3457
  movt barrettconst, #19412
#elif (NEWHOPE_N == 1024)
  .equ loopcount, 102
  movw q, #3329
  movt barrettconst, #20159
#endif

#ifdef USE_REPT
  .rept loopcount
#else
  movw loop, #loopcount
  1:
#endif

    ldm r0, {r2-r6}
    ldm r1!, {r7-r11}

    uadd16 r2, r2, r7
    uadd16 r3, r3, r8
    uadd16 r4, r4, r9
    uadd16 r5, r5, r10
    uadd16 r6, r6, r11

    doublebarrett r2, r8, r9, q, barrettconst
    doublebarrett r3, r8, r9, q, barrettconst
    doublebarrett r4, r8, r9, q, barrettconst
    doublebarrett r5, r8, r9, q, barrettconst
    doublebarrett r6, r8, r9, q, barrettconst

    stm r0!, {r2-r6}

#ifdef USE_REPT
  .endr
#else
    subs.w loop, #1
  bne.w 1b
#endif

#if (NEWHOPE_N == 512)
  ldr r2, [r0]
  ldr r7, [r1]

  uadd16 r2, r2, r7

  doublebarrett r2, r8, r9, q, barrettconst

  str r2, [r0]
#elif (NEWHOPE_N == 768)
  ldm r0, {r2-r5}
  ldm r1!, {r7-r10}

  uadd16 r2, r2, r7
  uadd16 r3, r3, r8
  uadd16 r4, r4, r9
  uadd16 r5, r5, r10

  doublebarrett r2, r8, r9, q, barrettconst
  doublebarrett r3, r8, r9, q, barrettconst
  doublebarrett r4, r8, r9, q, barrettconst
  doublebarrett r5, r8, r9, q, barrettconst

  stm r0!, {r2-r5}
#elif (NEWHOPE_N == 1024)
  ldm r0, {r2-r3}
  ldm r1!, {r7-r10}

  uadd16 r2, r2, r7
  uadd16 r3, r3, r8

  doublebarrett r2, r8, r9, q, barrettconst
  doublebarrett r3, r8, r9, q, barrettconst

  stm r0!, {r2-r3}
#endif
  pop     {r4-r11, pc}
