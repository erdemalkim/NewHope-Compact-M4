#if NEWHOPE_N == 1024
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

.macro multiply rptr, a0a1, a2a3, a4a5, a6a7, b0b1, b2b3, b4b5, b6b7, first, second, third, fourth, fifth, sixth, seventh, eighth, root, tmp, tmp2, q, qinv
  #c[i+7]
  smuadx \tmp2, \a0a1, \b6b7
  smladx \tmp2, \a6a7, \b0b1, \tmp2
  smladx \tmp2, \a2a3, \b4b5, \tmp2
  smladx \tmp2, \a4a5, \b2b3, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp

  strh \tmp, [\rptr, \eighth]

  #c[i+6]
  smultt \tmp2, \a6a7, \b6b7
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smlabb \tmp2, \a0a1, \b6b7, \tmp
  smlatt \tmp2, \a0a1, \b4b5, \tmp2
  smlabb \tmp2, \a2a3, \b4b5, \tmp2
  smlatt \tmp2, \a2a3, \b2b3, \tmp2
  smlabb \tmp2, \a4a5, \b2b3, \tmp2
  smlatt \tmp2, \a4a5, \b0b1, \tmp2
  smlabb \tmp2, \a6a7, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \seventh]

  #c[i+5]
  smuadx \tmp2, \a6a7, \b6b7
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smladx \tmp2, \a0a1, \b4b5, \tmp
  smladx \tmp2, \a2a3, \b2b3, \tmp2
  smladx \tmp2, \a4a5, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \sixth]

  #c[i+4]
  smultt \tmp2, \a4a5, \b6b7
  smlabb \tmp2, \a6a7, \b6b7, \tmp2
  smlatt \tmp2, \a6a7, \b4b5, \tmp2
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smlabb \tmp2, \a0a1, \b4b5, \tmp
  smlatt \tmp2, \a0a1, \b2b3, \tmp2
  smlabb \tmp2, \a2a3, \b2b3, \tmp2
  smlatt \tmp2, \a2a3, \b0b1, \tmp2
  smlabb \tmp2, \a4a5, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \fifth]

  #c[i+3]
  smuadx \tmp2, \a4a5, \b6b7
  smladx \tmp2, \a6a7, \b4b5, \tmp2
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smladx \tmp2, \a0a1, \b2b3, \tmp
  smladx \tmp2, \a2a3, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \fourth]

  #c[i+2]
  smultt \tmp2, \a2a3, \b6b7
  smlabb \tmp2, \a4a5, \b6b7, \tmp2
  smlatt \tmp2, \a4a5, \b4b5, \tmp2
  smlabb \tmp2, \a6a7, \b4b5, \tmp2
  smlatt \tmp2, \a6a7, \b2b3, \tmp2
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smlabb \tmp2, \a0a1, \b2b3, \tmp
  smlatt \tmp2, \a0a1, \b0b1, \tmp2
  smlabb \tmp2, \a2a3, \b0b1, \tmp2
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \third]

  #c[i+1]
  smuadx \tmp2, \a2a3, \b6b7
  smladx \tmp2, \a4a5, \b4b5, \tmp2
  smladx \tmp2, \a6a7, \b2b3, \tmp2
  tcc_mont_red \q, \qinv, \tmp2, \tmp
  smulbt \tmp, \root, \tmp
  smladx \tmp2, \a0a1, \b0b1, \tmp
  mont_red \q, \qinv, \tmp2, \tmp
  strh \tmp, [\rptr, \second]

  #c[i+0]
  smultt \tmp2, \a0a1, \b6b7
  smlabb \tmp2, \a2a3, \b6b7, \tmp2
  smlatt \tmp2, \a2a3, \b4b5, \tmp2
  smlabb \tmp2, \a4a5, \b4b5, \tmp2
  smlatt \tmp2, \a4a5, \b2b3, \tmp2
  smlabb \tmp2, \a6a7, \b2b3, \tmp2
  smlatt \tmp2, \a6a7, \b0b1, \tmp2
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
  root			.req r2
  a0a1      .req r3
  a2a3      .req r4
  a4a5      .req r5
  a6a7      .req r6
  b0b1      .req r7
  b2b3      .req r8
  b4b5      .req r9
  b6b7      .req r10
  q         .req r11
  qinv      .req r11
  tmp       .req r12
  tmp2      .req r14

	# compute a <-- a*b with register spilling for the root

  movw q, #3329
  movt qinv, #3327

#ifdef USE_REPT
  .rept 64
#else
  movw tmp, #64
  1:
    push {tmp}
#endif

		#push the root pointer on the stack
		push {root}
		ldrh root, [root]

#ifdef USE_REPT
   .rept 2
#else
    movw tmp, #2
    2:
      push {tmp}
#endif

		  ldrh a6a7, [a_ptr, #1792]
		  ldrh tmp, [a_ptr, #1536]
		  ldrh a4a5, [a_ptr, #1280]
		  ldrh tmp2, [a_ptr, #1024]

		  pkhbt a6a7, tmp, a6a7, lsl #16
		  pkhbt a4a5, tmp2, a4a5, lsl #16

		  ldrh a2a3, [a_ptr, #768]
		  ldrh tmp, [a_ptr, #512]
		  ldrh a0a1, [a_ptr, #256]
		  ldrh tmp2, [a_ptr]

		  pkhbt a2a3, tmp, a2a3, lsl #16
		  pkhbt a0a1, tmp2, a0a1, lsl #16

		  ldrh b6b7, [b_ptr, #1792]
		  ldrh tmp, [b_ptr, #1536]
		  ldrh b4b5, [b_ptr, #1280]
		  ldrh tmp2, [b_ptr, #1024]

		  pkhbt b6b7, tmp, b6b7, lsl #16
		  pkhbt b4b5, tmp2, b4b5, lsl #16

		  ldrh b2b3, [b_ptr, #768]
		  ldrh tmp, [b_ptr, #512]
		  ldrh b0b1, [b_ptr, #256]
		  ldrh tmp2, [b_ptr], #2

		  pkhbt b2b3, tmp, b2b3, lsl #16
		  pkhbt b0b1, tmp2, b0b1, lsl #16

		  multiply a_ptr, a0a1, a2a3, a4a5, a6a7, b0b1, b2b3, b4b5, b6b7, #2, #256, #512, #768, #1024, #1280, #1536, #1792, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
    .endr
#else
      pop {tmp}
      subs.w tmp, #1
    bne.w 2b
#endif

		#pop the root pointer from the stack and increment by 2 bytes
		pop {root}
		add root, #2

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 1b
#endif

  pop     {r4-r11, pc}


.global asm_multiple_basemul
.type asm_multiple_basemul,%function
.align 2
asm_multiple_basemul:
  push    {r4-r11, r14}
  a_ptr			.req r0
  b_ptr			.req r1
  root			.req r2
  a0a1      .req r3
  a2a3      .req r4
  a4a5      .req r5
  a6a7      .req r6
  b0b1      .req r7
  b2b3      .req r8
  b4b5      .req r9
  b6b7      .req r10
  q         .req r11
  qinv      .req r11
  tmp      .req r12
  tmp2      .req r14

  movw q, #3329
  movt qinv, #3327

#ifdef USE_REPT
.rept 4
#else
movw tmp, #4
1:
  push {tmp}
#endif

  push {root}
  ldrh root, [root]

#ifdef USE_REPT
  .rept 2
#else
  movw tmp, #2
  2:
    push {tmp}
#endif

    ldrh a6a7, [a_ptr, #1792]
	  ldrh tmp, [a_ptr, #1536]
	  ldrh a4a5, [a_ptr, #1280]
	  ldrh tmp2, [a_ptr, #1024]

	  pkhbt a6a7, tmp, a6a7, lsl #16
	  pkhbt a4a5, tmp2, a4a5, lsl #16

	  ldrh a2a3, [a_ptr, #768]
	  ldrh tmp, [a_ptr, #512]
	  ldrh a0a1, [a_ptr, #256]
	  ldrh tmp2, [a_ptr]

    pkhbt a2a3, tmp, a2a3, lsl #16
	  pkhbt a0a1, tmp2, a0a1, lsl #16

		ldr b6b7, [b_ptr, #12]
	  ldr b4b5, [b_ptr, #8]
	  ldr b2b3, [b_ptr, #4]
	  ldr b0b1, [b_ptr], #16

    multiply a_ptr, a0a1, a2a3, a4a5, a6a7, b0b1, b2b3, b4b5, b6b7, #2, #256, #512, #768, #1024, #1280, #1536, #1792, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 2b
#endif

  pop {root}
  add root, #2

#ifdef USE_REPT
.endr
#else
  pop {tmp}
  subs.w tmp, #1
bne.w 1b
#endif

  pop     {r4-r11, pc}


.global asm_double_basemul_frombytes
.type asm_double_basemul_frombytes,%function
.align 2
asm_double_basemul_frombytes:
  push    {r4-r11, r14}
	a_ptr			.req r0
	b_ptr			.req r1
	root			.req r2
  a0a1      .req r3
  a2a3      .req r4
  a4a5      .req r5
  a6a7      .req r6
  b0b1      .req r7
  b2b3      .req r8
  b4b5      .req r9
  b6b7      .req r10
  q         .req r11
  qinv      .req r11
  tmp       .req r12
  tmp2      .req r14

  movw q, #3329
  movt qinv, #3327

#ifdef USE_REPT
  .rept 2
#else
  movw tmp, #2
  1:
    push {tmp}
#endif

    ldrh a6a7, [a_ptr, #1792]
    ldrh tmp, [a_ptr, #1536]
    ldrh a4a5, [a_ptr, #1280]
    ldrh tmp2, [a_ptr, #1024]

    pkhbt a6a7, tmp, a6a7, lsl #16
    pkhbt a4a5, tmp2, a4a5, lsl #16

    ldrh a2a3, [a_ptr, #768]
    ldrh tmp, [a_ptr, #512]
    ldrh a0a1, [a_ptr, #256]
    ldrh tmp2, [a_ptr]

    pkhbt a2a3, tmp, a2a3, lsl #16
    pkhbt a0a1, tmp2, a0a1, lsl #16

    ldr b6b7, [b_ptr, #12]
    ldr b4b5, [b_ptr, #8]
    ldr b2b3, [b_ptr, #4]
    ldr b0b1, [b_ptr], #16

    multiply a_ptr, a0a1, a2a3, a4a5, a6a7, b0b1, b2b3, b4b5, b6b7, #2, #256, #512, #768, #1024, #1280, #1536, #1792, root, tmp, tmp2, q, qinv

#ifdef USE_REPT
  .endr
#else
    pop {tmp}
    subs.w tmp, #1
  bne.w 1b
#endif

  pop     {r4-r11, pc}

#endif
