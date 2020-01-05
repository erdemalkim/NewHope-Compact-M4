#if (NEWHOPE_N == 512)

.syntax unified
.cpu cortex-m4
.thumb

.macro mont_red q, qinv, a, tmp
  smulbt \tmp, \a, \qinv
  smlabb \tmp, \q, \tmp, \a
  asr \tmp, \tmp, #16
.endm

.macro tcc_mont_red q, qinv, a, tmp
  smulbt \tmp, \a, \qinv
  smlabb \tmp, \q, \tmp, \a
.endm

.macro multiply rptr, a0a1, a2a3, b0b1, b2b3, first, second, third, fourth, root, tmp, tmp2, q, qinv
  #c[i+3]
  smuadx \tmp2, \a0a1, \b2b3
  smladx \tmp2, \a2a3, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \fourth]

  #c[i+2]
  smultt \tmp2, \a2a3, \b2b3
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smlabb \tmp2, \a0a1, \b2b3, \tmp
  smlatt \tmp2, \a0a1, \b0b1, \tmp2
  smlabb \tmp2, \a2a3, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \third]

  #c[i+1]
  smuadx \tmp2, \a2a3, \b2b3
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smladx \tmp2, \a0a1, \b0b1, \tmp
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \second]

  #c[i+0]
  smultt \tmp2, \a0a1, \b2b3
  smlabb \tmp2, \a2a3, \b2b3, \tmp2
  smlatt \tmp2, \a2a3, \b0b1, tmp2
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smlabb \tmp2, \a0a1, \b0b1, \tmp
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr], \first

  neg \root, \root
.endm

.global asm_bm
.type asm_bm,%function
.align 2
asm_bm:
  push    {r4-r11, r14}
  a_ptr			.req r0
  b_ptr			.req r1
  root_ptr	.req r2
  a0a1      .req r3
  a2a3      .req r4
  b0b1      .req r5
  b2b3      .req r6
  q         .req r7
  qinv      .req r7
  tmp       .req r8
  tmp2      .req r9
  tmp3      .req r10
  loop      .req r11
  root      .req r12

  movw q, #3329
  movt qinv, #3327

#ifdef USE_REPT
  .rept 64
#else
  movw loop, #64
  1:
#endif

    ldrh root, [root_ptr], #2

    .rept 2

      ldrh a2a3, [a_ptr, #768]
      ldrh tmp, [a_ptr, #512]
      ldrh a0a1, [a_ptr, #256]
      ldrh tmp2, [a_ptr]
      pkhbt a2a3, tmp, a2a3, lsl #16
      pkhbt a0a1, tmp2, a0a1, lsl #16

      ldrh b2b3, [b_ptr, #768]
      ldrh tmp, [b_ptr, #512]
      ldrh b0b1, [b_ptr, #256]
      ldrh tmp2, [b_ptr], #2
      pkhbt b2b3, tmp, b2b3, lsl #16
      pkhbt b0b1, tmp2, b0b1, lsl #16

      multiply a_ptr, a0a1, a2a3, b0b1, b2b3, #2, #256, #512, #768, root, tmp, tmp2, q, qinv

    .endr

#ifdef USE_REPT
  .endr
#else
    subs.w loop, #1
  bne.w 1b
#endif

  pop {r4-r11, pc}


.global asm_multiple_basemul
.type asm_multiple_basemul,%function
.align 2
asm_multiple_basemul:
  push    {r4-r11, r14}
  a_ptr			.req r0
  b_ptr			.req r1
  root_ptr 	.req r2
  a0a1      .req r3
  a2a3      .req r4
  b0b1      .req r5
  b2b3      .req r6
  q         .req r7
  qinv      .req r7
  tmp       .req r8
  tmp2      .req r9
  tmp3      .req r10
  loop      .req r11
  root      .req r12

  movw q, #3329
  movt qinv, #3327

#ifdef USE_REPT
  .rept 8
#else
  movw loop, #8
  1:
#endif

    ldrh root, [root_ptr], #2

    .rept 2

      ldrh a2a3, [a_ptr, #768]
      ldrh tmp, [a_ptr, #512]
      ldrh a0a1, [a_ptr, #256]
      ldrh tmp2, [a_ptr]

      pkhbt a2a3, tmp, a2a3, lsl #16
      pkhbt a0a1, tmp2, a0a1, lsl #16

      ldr b2b3, [b_ptr, #4]
      ldr b0b1, [b_ptr], #8

      multiply a_ptr, a0a1, a2a3, b0b1, b2b3, #2, #256, #512, #768, root, tmp, tmp2, q, qinv

    .endr


#ifdef USE_REPT
  .endr
#else
    subs.w loop, #1
  bne.w 1b
#endif

  pop {r4-r11, pc}


.global asm_double_basemul_frombytes
.type asm_double_basemul_frombytes,%function
.align 2
asm_double_basemul_frombytes:
  push    {r4-r11, r14}
  .unreq root
  .unreq root_ptr
  a_ptr     .req r0
  b_ptr     .req r1
  root      .req r2
  a0a1      .req r3
  a2a3      .req r4
  b0b1      .req r5
  b2b3      .req r6
  q         .req r7
  qinv      .req r7
  tmp       .req r8
  tmp2      .req r9
  tmp3      .req r10
  loop      .req r11

  movw q, #3329
  movt qinv, #3327

#ifdef USE_REPT
  .rept 2
#else
  movw loop, #2
  1:
#endif

    ldrh a2a3, [a_ptr, #768]
    ldrh tmp, [a_ptr, #512]
    ldrh a0a1, [a_ptr, #256]
    ldrh tmp2, [a_ptr]

    pkhbt a2a3, tmp, a2a3, lsl #16
    pkhbt a0a1, tmp2, a0a1, lsl #16

    ldr b2b3, [b_ptr, #4]
    ldr b0b1, [b_ptr], #8

    multiply a_ptr, a0a1, a2a3, b0b1, b2b3, #2, #256, #512, #768, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
  .endr
#else
    subs.w loop, #1
  bne.w 1b
#endif

  pop {r4-r11, pc}

#endif
