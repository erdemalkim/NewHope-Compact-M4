#include "api.h"
#include "hal.h"
#include "sendfn.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>


#define printcycles(S, U) send_unsignedll((S), (U))

int main(void)
{
  unsigned char key_a[CRYPTO_BYTES], key_b[CRYPTO_BYTES];
  unsigned char sk[CRYPTO_SECRETKEYBYTES];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char ct[CRYPTO_CIPHERTEXTBYTES];
  unsigned long long t0, t1;

  hal_setup(CLOCK_BENCHMARK);

  hal_send_str("==========================");

  // Key-pair generation
  t0 = hal_get_time();
  crypto_kem_keypair(pk, sk);
  t1 = hal_get_time();
  printcycles("keypair cycles: ", t1-t0);

  // Encapsulation
  t0 = hal_get_time();
  crypto_kem_enc(ct, key_a, pk);
  t1 = hal_get_time();
  printcycles("encaps cycles: ", t1-t0);

  // Decapsulation
  t0 = hal_get_time();
  crypto_kem_dec(key_b, ct, sk);
  t1 = hal_get_time();
  printcycles("decaps cycles: ", t1-t0);

  if (memcmp(key_a, key_b, CRYPTO_BYTES)) {
    hal_send_rstr("ERROR KEYS\n");
  }
  else {
    hal_send_rstr("OK KEYS\n");
  }

#include "poly.h"

  // ntt
  poly a,b;
  t0 = hal_get_time();
  poly_ntt(&a);
  t1 = hal_get_time();
  printcycles("\npoly ntt cycles: ", t1-t0);

  // inv ntt
  t0 = hal_get_time();
  poly_invntt(&a);
  t1 = hal_get_time();
  printcycles("poly invntt cycles: ", t1-t0);

  // basemul
  t0 = hal_get_time();
#ifdef NEWHOPE_Q
#if NEWHOPE_Q == 12289
  poly_mul_pointwise(&a, &b);
#else
  poly_basemul(&a, &b);
#endif
#else
  poly c;
  poly_basemul(&a, &b, &c);
#endif
  t1 = hal_get_time();
  printcycles("poly basemul cycles: ", t1-t0);

  hal_send_str("#");
  while(1);
  return 0;
}
