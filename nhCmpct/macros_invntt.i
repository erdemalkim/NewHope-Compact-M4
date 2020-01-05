#ifndef MACROS_INVNTT_I
#define MACROS_INVNTT_I

#include "macros.i"

.macro doubleinvbutterfly_first_stage a0, a1, twiddle, tmp ,tmp2, q, qinv
  pkhbt \tmp, \a0, \a1, lsl#16
  pkhtb \tmp2, \a1, \a0, asr#16
  uadd16 \a1, \tmp, \tmp2
  usub16 \tmp2, \tmp, \tmp2
  smulbb \a0, \twiddle, \tmp2
  smultt \tmp2, \twiddle, \tmp2
  montgomery \q, \qinv, \tmp2, \tmp
  montgomery \q, \qinv, \a0, \tmp2
  pkhbt \a0, \a1, \tmp2
  pkhtb \a1, \tmp, \a1, asr#16
.endm

.macro doubleinvbutterfly tb, a0, a1, twiddle, tmp, tmp2, q, qinv
  usub16 \tmp, \a0, \a1
  uadd16 \a0, \a0, \a1

  smulb\tb \a1, \tmp, \twiddle
  smult\tb \tmp, \tmp, \twiddle
  montgomery \q, \qinv, \a1, \tmp2
  montgomery \q, \qinv, \tmp, \a1
  pkhtb \a1, \a1, \tmp2, asr#16
.endm

.macro two_doubleinvbutterfly tb1, tb2, a0, a1, a2, a3, twiddle, tmp, tmp2, q, qinv
  doubleinvbutterfly \tb1, \a0, \a1, \twiddle, \tmp, \tmp2, \q, \qinv
  doubleinvbutterfly \tb2, \a2, \a3, \twiddle, \tmp, \tmp2, \q, \qinv
.endm

.macro fqmulprecomp a, twiddle, tmp, tmp2, q, qinv
  smulbt \tmp, \a, \twiddle
  smultt \a, \a, \twiddle
  montgomery \q, \qinv, \a, \tmp2
  montgomery \q, \qinv, \tmp, \a
  pkhtb \a, \tmp2, \a, asr#16
.endm

#endif /* MACROS_INVNTT_I */
