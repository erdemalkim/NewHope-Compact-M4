#ifndef PARAMS_H
#define PARAMS_H


#ifndef NEWHOPE_N
#define NEWHOPE_N 512
#endif

#if  (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
#define NEWHOPE_Q    3329
#define NEWHOPE_QINV 62209   /* inverse_mod(p,2^16) */
#elif (NEWHOPE_N == 768)
#define NEWHOPE_Q    3457
#define NEWHOPE_QINV 12929   /* inverse_mod(p,2^16) */
#endif

#define NEWHOPE_K    2       /* used in noise sampling */

#define NEWHOPE_NTT_LENGTH 128

#if   (NEWHOPE_N == 512)
#define NEWHOPE_NTT_POLY 4
#define NEWHOPE_POLYCOMPRESSEDBITS  3
#elif (NEWHOPE_N == 768)
#define NEWHOPE_NTT_POLY 6
#define NEWHOPE_POLYCOMPRESSEDBITS  4
#elif (NEWHOPE_N == 1024)
#define NEWHOPE_NTT_POLY 8
#define NEWHOPE_POLYCOMPRESSEDBITS  4
#endif

#define NEWHOPE_SYMBYTES 32   /* size of shared key, seeds/coins, and hashes */

#define NEWHOPE_POLYBYTES            ((3*NEWHOPE_N)/2)
#define NEWHOPE_POLYCOMPRESSEDBYTES  ((NEWHOPE_POLYCOMPRESSEDBITS*NEWHOPE_N)/8)

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
// or 'make FLAG1=-DOPTIMIZE_STACK'. When it is not selected, it will perform
// the addition in NTT domain instead of normal domain.
// #define OPTIMIZE_STACK

#define NEWHOPE_CPAPKE_PUBLICKEYBYTES  (NEWHOPE_POLYBYTES + NEWHOPE_SYMBYTES)
#ifdef SMALL_SECRET_KEY
#define NEWHOPE_CPAPKE_SECRETKEYBYTES  (NEWHOPE_SYMBYTES)
#else
#define NEWHOPE_CPAPKE_SECRETKEYBYTES  (NEWHOPE_POLYBYTES)
#endif
#define NEWHOPE_CPAPKE_CIPHERTEXTBYTES (NEWHOPE_POLYBYTES + NEWHOPE_POLYCOMPRESSEDBYTES)

#define NEWHOPE_CPAKEM_PUBLICKEYBYTES NEWHOPE_CPAPKE_PUBLICKEYBYTES
#define NEWHOPE_CPAKEM_SECRETKEYBYTES NEWHOPE_CPAPKE_SECRETKEYBYTES
#define NEWHOPE_CPAKEM_CIPHERTEXTBYTES NEWHOPE_CPAPKE_CIPHERTEXTBYTES

#define NEWHOPE_CCAKEM_PUBLICKEYBYTES NEWHOPE_CPAPKE_PUBLICKEYBYTES
#define NEWHOPE_CCAKEM_SECRETKEYBYTES (NEWHOPE_CPAPKE_SECRETKEYBYTES + NEWHOPE_CPAPKE_PUBLICKEYBYTES + 2*NEWHOPE_SYMBYTES)
#define NEWHOPE_CCAKEM_CIPHERTEXTBYTES (NEWHOPE_CPAPKE_CIPHERTEXTBYTES + NEWHOPE_SYMBYTES)  /* Second part is for Targhi-Unruh */

#endif
