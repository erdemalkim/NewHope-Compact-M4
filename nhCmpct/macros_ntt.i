#ifndef MACROS_NTT_I
#define MACROS_NTT_I

#include "macros.i"
#include "params.h"

.macro doublebutterfly tb, a0, a1, twiddle, tmp, tmp2, q, qinv
  smulb\tb \tmp, \a1, \twiddle
  smult\tb \a1, \a1, \twiddle
  montgomery \q, \qinv, \tmp, \tmp2
  montgomery \q, \qinv, \a1, \tmp
  pkhtb \tmp2, \tmp, \tmp2, asr#16
  usub16 \a1, \a0, \tmp2
  uadd16 \a0, \a0, \tmp2
.endm

.macro two_doublebutterfly tb1, tb2, a0, a1, a2, a3, twiddle, tmp, tmp2, q, qinv
  doublebutterfly \tb1, \a0, \a1, \twiddle, \tmp, \tmp2, \q, \qinv
  doublebutterfly \tb2, \a2, \a3, \twiddle, \tmp, \tmp2, \q, \qinv
.endm

#ifndef OPTIMIZE_STACK
.macro doublebutterfly_no_montgomery a0, a1, twiddle, tmp, tmp2
  smulbb \tmp, \a1, \twiddle
  smultb \a1, \a1, \twiddle
  pkhbt \tmp2, \tmp, \a1, lsl#16
  usub16 \a1, \a0, \tmp2
  uadd16 \a0, \a0, \tmp2
.endm

.macro two_doublebutterfly_no_montgomery a0, a1, a2, a3, twiddle, tmp, tmp2
  doublebutterfly_no_montgomery \a0, \a1, \twiddle, \tmp, \tmp2
  doublebutterfly_no_montgomery \a2, \a3, \twiddle, \tmp, \tmp2
.endm
#endif

.macro doublebutterfly_last_stage a0, a1, twiddle, tmp, tmp2, q, qinv
  smultb \tmp, \a0, \twiddle
  smultt \tmp2, \a1, \twiddle
  montgomery \q, \qinv, \tmp, \twiddle  // twiddle is used as temp register
  montgomery \q, \qinv, \tmp2, \tmp
  pkhtb \tmp2, \tmp, \twiddle, asr#16  // twiddle is used as temp register
  pkhbt \tmp, \a0, \a1, lsl#16
  usub16 \a1, \tmp, \tmp2
  uadd16 \tmp, \tmp, \tmp2
  pkhbt \a0, \tmp, \a1, lsl#16
  pkhtb \a1, \a1, \tmp, asr#16
.endm

#endif /* MACROS_NTT_I */
