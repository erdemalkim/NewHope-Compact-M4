#ifndef PARAMS_H
#define PARAMS_H

#define KYBER_K KYBER_P/256

/* Don't change parameters below this line */

#define KYBER_N 256
#define KYBER_Q 3329

#define KYBER_ETA 2

#define KYBER_SYMBYTES 32   /* size in bytes of hashes, and seeds */
#define KYBER_SSBYTES  32   /* size in bytes of shared key */

#define KYBER_POLYBYTES              384
#define KYBER_POLYVECBYTES           (KYBER_K * KYBER_POLYBYTES)

#if KYBER_K == 2
#define KYBER_POLYCOMPRESSEDBYTES    96
#define KYBER_POLYVECCOMPRESSEDBYTES (KYBER_K * 320)
#elif KYBER_K == 3
#define KYBER_POLYCOMPRESSEDBYTES    128
#define KYBER_POLYVECCOMPRESSEDBYTES (KYBER_K * 320)
#elif KYBER_K == 4
#define KYBER_POLYCOMPRESSEDBYTES    160
#define KYBER_POLYVECCOMPRESSEDBYTES (KYBER_K * 352)
#endif

/***************************************************************
********************** Optimization Flags **********************
****************************************************************/
// In order to enable secret key size optimization uncomment following macro
// or call 'make FLAG1=-DSMALL_SECRET_KEY'.
// #define SMALL_SECRET_KEY

// To use rept, uncomment following macro or call 'make FLAG1=-DUSE_REPT',
// it will change most of the loops in assembly implementations to rept.
// It will increase code size while reducing the runtime.
// #define USE_REPT

// To use stack usage optimization during key generation uncomment following macro
// or 'make FLAG1=-DOPTIMIZE_STACK'.When it is not selected, it will perform
// the addition in NTT domain instead of normal domain.
// #define OPTIMIZE_STACK

#define KYBER_INDCPA_MSGBYTES       KYBER_SYMBYTES
#define KYBER_INDCPA_PUBLICKEYBYTES (KYBER_POLYVECBYTES + KYBER_SYMBYTES)
#ifdef SMALL_SECRET_KEY
#define KYBER_INDCPA_SECRETKEYBYTES (KYBER_SYMBYTES)
#else
#define KYBER_INDCPA_SECRETKEYBYTES (KYBER_POLYVECBYTES)
#endif
#define KYBER_INDCPA_BYTES          (KYBER_POLYVECCOMPRESSEDBYTES + KYBER_POLYCOMPRESSEDBYTES)

#define KYBER_PUBLICKEYBYTES  (KYBER_INDCPA_PUBLICKEYBYTES)
#define KYBER_SECRETKEYBYTES  (KYBER_INDCPA_SECRETKEYBYTES +  KYBER_INDCPA_PUBLICKEYBYTES + 2*KYBER_SYMBYTES) /* 32 bytes of additional space to save H(pk) */
#define KYBER_CIPHERTEXTBYTES  KYBER_INDCPA_BYTES

#endif
