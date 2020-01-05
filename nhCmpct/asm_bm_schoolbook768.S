#if (NEWHOPE_N == 768)

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

.macro multiply rptr, a0a1, a2a3, a4a5, b0b1, b2b3, b4b5, first, second, third, fourth, fifth, sixth, root, tmp, tmp2, q, qinv
  # c[i+5]
  smuadx \tmp2, \a0a1, \b4b5
  smladx \tmp2, \a2a3, \b2b3, \tmp2
  smladx \tmp2, \a4a5, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \sixth]

  # c[i+4]
  smultt \tmp, \a4a5, \b4b5
  tcc_mont_red \q, \qinv, \tmp, \tmp2
  smulbt \tmp2, \root, \tmp2
  smlabb \tmp2, \a0a1, \b4b5, \tmp2
  smlatt \tmp2, \a0a1, \b2b3, \tmp2
  smlabb \tmp2, \a2a3, \b2b3, \tmp2
  smlatt \tmp2, \a2a3, \b0b1, \tmp2
  smlabb \tmp2, \a4a5, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \fifth]

  # c[i+3]
  smuadx \tmp, \a4a5, \b4b5
  tcc_mont_red \q, \qinv, \tmp, \tmp2
  smulbt \tmp2, \root, \tmp2
  smladx \tmp2, \a0a1, \b2b3, \tmp2
  smladx \tmp2, \a2a3, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \fourth]

  # c[i+2]
  smultt \tmp, \a2a3, \b4b5
  smlabb \tmp, \a4a5, \b4b5, \tmp
  smlatt \tmp, \a4a5, \b2b3, \tmp
  tcc_mont_red \q, \qinv, \tmp, \tmp2
  smulbt \tmp2, \root, \tmp2
  smlabb \tmp2, \a0a1, \b2b3, \tmp2
  smlatt \tmp2, \a0a1, \b0b1, \tmp2
  smlabb \tmp2, \a2a3, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \third]

  # c[i+1]
  smuadx \tmp, \a2a3, \b4b5
  smladx \tmp, \a4a5, \b2b3, \tmp
  tcc_mont_red \q, \qinv, \tmp, \tmp2
  smulbt \tmp2, \root, \tmp2
  smladx \tmp2, \a0a1, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \second]

  # c[i]
  smultt \tmp, \a0a1, \b4b5
  smlabb \tmp, \a2a3, \b4b5, \tmp
  smlatt \tmp, \a2a3, \b2b3, \tmp
  smlabb \tmp, \a4a5, \b2b3, \tmp
  smlatt \tmp, \a4a5, \b0b1, \tmp
  tcc_mont_red \q, \qinv, \tmp, \tmp2
  smulbt \tmp2, \root, \tmp2
  smlabb \tmp2, \a0a1, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr], \first

  neg \root, \root
.endm

.global asm_bm
.type asm_bm,%function
.align 2
asm_bm:
  push    {r4-r11, r14}
  a_ptr     .req r0
  b_ptr     .req r1
  root_ptr  .req r2
  a0a1      .req r3
  a2a3      .req r4
  a4a5      .req r5
  b0b1      .req r6
  b2b3      .req r7
  b4b5      .req r8
  q         .req r9
  qinv      .req r9
  tmp       .req r10
  tmp2      .req r11
  loop      .req r12
  root      .req r14

  movw q, #3457
  movt qinv, #52607

#ifdef USE_REPT
  .rept 64
#else
  movw loop, #64
  1:
#endif

    ldrh root, [root_ptr], #2

#ifdef USE_REPT
    .rept 2
#else
    movw tmp, #2
    2:
      push {tmp}
#endif

      ldrh a4a5, [a_ptr, #1280]
      ldrh tmp, [a_ptr, #1024]
      ldrh a2a3, [a_ptr, #768]
      ldrh tmp2, [a_ptr, #512]
      pkhbt a4a5, tmp, a4a5, lsl#16
      pkhbt a2a3, tmp2, a2a3, lsl#16

      ldrh a0a1, [a_ptr, #256]
      ldrh tmp, [a_ptr]
      pkhbt a0a1, tmp, a0a1, lsl#16

      ldrh b4b5, [b_ptr, #1280]
      ldrh tmp, [b_ptr, #1024]
      ldrh b2b3, [b_ptr, #768]
      ldrh tmp2, [b_ptr, #512]
      pkhbt b4b5, tmp, b4b5, lsl#16
      pkhbt b2b3, tmp2, b2b3, lsl#16

      ldrh b0b1, [b_ptr, #256]
      ldrh tmp, [b_ptr], #2
      pkhbt b0b1, tmp, b0b1, lsl#16

      multiply a_ptr, a0a1, a2a3, a4a5, b0b1, b2b3, b4b5, #2, #256, #512, #768 ,#1024, #1280, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
    .endr
#else
      pop {tmp}
      subs.w tmp, #1
    bne.w 2b
#endif

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
  a_ptr     .req r0
  b_ptr     .req r1
  root_ptr  .req r2
  a0a1      .req r3
  a2a3      .req r4
  a4a5      .req r5
  b0b1      .req r6
  b2b3      .req r7
  b4b5      .req r8
  q         .req r9
  qinv      .req r9
  tmp       .req r10
  tmp2      .req r11
  loop      .req r12
  root      .req r14

  movw q, #3457
  movt qinv, #52607

#ifdef USE_REPT
  .rept 2
#else
  movw loop, #2
  1:
#endif

    ldrh root, [root_ptr], #2

#ifdef USE_REPT
    .rept 2
#else
    movw tmp, #2
    2:
      push {tmp}
#endif

      ldrh a4a5, [a_ptr, #1280]
	    ldrh tmp,  [a_ptr, #1024]
	    ldrh a2a3, [a_ptr, #768]
	    ldrh tmp2, [a_ptr, #512]

      pkhbt a4a5, tmp, a4a5, lsl#16
	    pkhbt a2a3, tmp2, a2a3, lsl#16

	    ldrh a0a1, [a_ptr, #256]
	    ldrh tmp, [a_ptr]

      pkhbt a0a1, tmp, a0a1, lsl#16

      ldr.w b4b5, [b_ptr, #8]
	    ldr.w b2b3, [b_ptr, #4]
	    ldr.w b0b1, [b_ptr], #12

      multiply a_ptr, a0a1, a2a3, a4a5, b0b1, b2b3, b4b5, #2, #256, #512, #768, #1024, #1280, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
    .endr
#else
      pop {tmp}
      subs.w tmp, #1
    bne.w 2b
#endif

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
  a_ptr     .req r0
  b_ptr     .req r1
  root      .req r2
  a0a1      .req r3
  a2a3      .req r4
  a4a5      .req r5
  b0b1      .req r6
  b2b3      .req r7
  b4b5      .req r8
  q         .req r9
  qinv      .req r9
  tmp       .req r10
  tmp2      .req r11
  loop      .req r12

  movw q, #3457
  movt qinv, #52607

#ifdef USE_REPT
  .rept 2
#else
  movw loop, #2
  1:
#endif

    ldrh a4a5, [a_ptr, #1280]
    ldrh tmp,  [a_ptr, #1024]
    ldrh a2a3, [a_ptr, #768]
    ldrh tmp2, [a_ptr, #512]

    pkhbt a4a5, tmp, a4a5, lsl#16
    pkhbt a2a3, tmp2, a2a3, lsl#16

    ldrh a0a1, [a_ptr, #256]
    ldrh tmp, [a_ptr]

    pkhbt a0a1, tmp, a0a1, lsl#16

    ldr.w b4b5, [b_ptr, #8]
    ldr.w b2b3, [b_ptr, #4]
    ldr.w b0b1, [b_ptr], #12

    multiply a_ptr, a0a1, a2a3, a4a5, b0b1, b2b3, b4b5, #2, #256, #512, #768, #1024, #1280, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
  .endr
#else
    subs.w loop, #1
  bne.w 1b
#endif

  pop {r4-r11, pc}

#endif
