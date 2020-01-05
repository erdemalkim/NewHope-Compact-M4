#include <string.h>
#include "poly.h"
#include "fips202.h"

extern int16_t asm_gammas_montgomery[];
extern int16_t asm_gammas_montgomery_mul[];
extern int16_t asm_gammas_inv_montgomery[];

/*************************************************
* Name:        flipabs
*
* Description: Computes |(x mod q) - Q/2|
*
* Arguments:   int16_t x: input coefficient
*
* Returns |(x mod q) - Q/2|
**************************************************/
static uint16_t flipabs(int16_t x)
{
  int16_t r,m;

  r = x - NEWHOPE_Q/2;

  m = r >> 15;
  return (r + m) ^ m;
}

/*************************************************
* Name:        poly_frombytes
*
* Description: De-serialization of a polynomial
*
* Arguments:   - poly *r:                pointer to output polynomial
*              - const unsigned char *a: pointer to input byte array
**************************************************/
void poly_frombytes(poly *r, const unsigned char *a)
{
  int i;
  for(i=0;i<NEWHOPE_N/2;i++)
  {
    r->coeffs[2*i+0] =  a[3*i+0]       | (((uint16_t)a[3*i+1] & 0x0f) << 8);
    r->coeffs[2*i+1] = (a[3*i+1] >> 4) | (((uint16_t)a[3*i+2] & 0xff) << 4);
  }
}


extern void asm_double_basemul_frombytes(int16_t*, int16_t*, const int16_t);

/*************************************************
* Name:        poly_frombytes_mul
*
* Description: De-serialization of two polynomials TODO
*
* Arguments:   - poly *r:                pointer to output polynomial
*              - const unsigned char *a: pointer to input byte array
**************************************************/
void poly_frombytes_mul(poly *r, const unsigned char *a, const unsigned char *b)
{
  int16_t poly1[2*NEWHOPE_NTT_POLY];
  int i,j,k=0;

  for(i=0;i<NEWHOPE_N/(2*NEWHOPE_NTT_POLY);i++)
  {
    for (j=0; j < NEWHOPE_NTT_POLY; ++j){
      r->coeffs[2*i+128*j+0]    =  a[3*i+192*j+0]         | (((uint16_t)a[3*i+192*j+1] & 0x0f) << 8);
      r->coeffs[2*i+128*j+1]    = (a[3*i+192*j+1] >> 4)   | (((uint16_t)a[3*i+192*j+2] & 0xff) << 4);
      poly1[j]                  =  b[3*i+192*j+0]         | (((uint16_t)b[3*i+192*j+1] & 0x0f) << 8);
      poly1[j+NEWHOPE_NTT_POLY] = (b[3*i+192*j+1] >> 4)   | (((uint16_t)b[3*i+192*j+2] & 0xff) << 4);
    }

    asm_double_basemul_frombytes(&r->coeffs[2*i], poly1, asm_gammas_montgomery_mul[k]);
    ++k;
  }
}

/*************************************************
* Name:        poly_tobytes
*
* Description: Serialization of a polynomial
*
* Arguments:   - unsigned char *r: pointer to output byte array
*              - const poly *p:    pointer to input polynomial
**************************************************/
void poly_tobytes(unsigned char *r, const poly *a)
{
  int i;
  for(i=0;i<NEWHOPE_N/2;i++)
  {
    r[3*i+0] =  a->coeffs[2*i] & 0xff;
    r[3*i+1] = (a->coeffs[2*i] >> 8) | ((a->coeffs[2*i+1] & 0xf) << 4);
    r[3*i+2] = (a->coeffs[2*i+1] >> 4);
  }
}

/*************************************************
* Name:        poly_tobytes_cmp
*
* Description: TODO
*
* Arguments:   - const unsigned char *r: pointer to input byte array
*              - const poly *a:    pointer to input polynomial
*
* Returns:     integer indicating whether r and serialized a are equal
**************************************************/
int poly_tobytes_cmp(const unsigned char *r, const poly *a)
{
  unsigned char rc= 0;
  int i;
  for(i=0; i < NEWHOPE_N/2; ++i){
    rc |= r[3*i+0] ^ (a->coeffs[2*i] & 0xff);
    rc |= r[3*i+1] ^ ((a->coeffs[2*i] >> 8) | (a->coeffs[2*i+1] << 4));
    rc |= r[3*i+2] ^ (a->coeffs[2*i+1] >> 4);
  }

  return rc;
}

/*************************************************
* Name:        poly_compress
*
* Description: Compression and subsequent serialization of a polynomial
*
* Arguments:   - unsigned char *r: pointer to output byte array
*              - const poly *a:    pointer to input polynomial
**************************************************/
void poly_compress(unsigned char * restrict r, const poly * restrict a)
{
  uint8_t t[8];
  int i,j,k=0;

#if (NEWHOPE_POLYCOMPRESSEDBITS == 3)
  for(i=0;i<NEWHOPE_N;i+=8)
  {
    for(j=0;j<8;j++)
      t[j] = (((a->coeffs[i+j] << 3) + NEWHOPE_Q/2) / NEWHOPE_Q) & 7;

    r[k]   =  t[0]       | (t[1] << 3) | (t[2] << 6);
    r[k+1] = (t[2] >> 2) | (t[3] << 1) | (t[4] << 4) | (t[5] << 7);
    r[k+2] = (t[5] >> 1) | (t[6] << 2) | (t[7] << 5);
    k += 3;
  }
#elif (NEWHOPE_POLYCOMPRESSEDBITS == 4)
  for(i=0;i<NEWHOPE_N;i+=8)
  {
    for(j=0;j<8;j++)
      t[j] = (((a->coeffs[i+j] << 4) + NEWHOPE_Q/2) / NEWHOPE_Q) & 15;

    r[k]   = t[0] | (t[1] << 4);
    r[k+1] = t[2] | (t[3] << 4);
    r[k+2] = t[4] | (t[5] << 4);
    r[k+3] = t[6] | (t[7] << 4);
    k += 4;
  }
#else
#error "NEWHOPE_POLYCOMPRESSEDBITS needs to be in {3, 4}"
#endif
}

/*************************************************
* Name:        poly_compress_cmp
*
* Description: Compression and subsequent serialization of a polynomial TODO
*
* Arguments:   - const unsigned char *r: pointer to input byte array
*              - const poly *a:    pointer to input polynomial
*
* Returns:     integer indicating whether r and compressed a are equal
**************************************************/
int poly_compress_cmp(const unsigned char * restrict r, const poly * restrict a)
{
  unsigned char rc = 0;
  uint8_t t[8];
  int i,j,k=0;

#if (NEWHOPE_POLYCOMPRESSEDBITS == 3)
  for(i=0;i<NEWHOPE_N;i+=8)
  {
    for(j=0;j<8;j++)
      t[j] = (((a->coeffs[i+j] << 3) + NEWHOPE_Q/2) / NEWHOPE_Q) & 7;

    rc |= r[k]   ^ (t[0]       | (t[1] << 3) | (t[2] << 6));
    rc |= r[k+1] ^ ((t[2] >> 2) | (t[3] << 1) | (t[4] << 4) | (t[5] << 7));
    rc |= r[k+2] ^ ((t[5] >> 1) | (t[6] << 2) | (t[7] << 5));
    k += 3;
  }
#elif (NEWHOPE_POLYCOMPRESSEDBITS == 4)
  for(i=0;i<NEWHOPE_N;i+=8)
  {
    for(j=0;j<8;j++)
      t[j] = (((a->coeffs[i+j] << 4) + NEWHOPE_Q/2) / NEWHOPE_Q) & 15;

    rc |= r[k]   ^ (t[0] | (t[1] << 4));
    rc |= r[k+1] ^ (t[2] | (t[3] << 4));
    rc |= r[k+2] ^ (t[4] | (t[5] << 4));
    rc |= r[k+3] ^ (t[6] | (t[7] << 4));
    k += 4;
  }
#else
#error "NEWHOPE_POLYCOMPRESSEDBITS needs to be in {3, 4}"
#endif

  return rc;
}

/*************************************************
* Name:        poly_decompress_sub
*
* Description: De-serialization and subsequent decompression of a polynomial
*              is substracted from another polynomial
*              Computes r=r-poly_decompress(a)
*
* Arguments:   - poly *r:                pointer to input and output polynomial
*              - const unsigned char *a: pointer to input byte array
**************************************************/
void poly_decompress_sub(poly * r, const unsigned char * a)
{
  int i;
#if (NEWHOPE_POLYCOMPRESSEDBITS == 3)
  for(i=0;i<NEWHOPE_N;i+=8)
  {
    r->coeffs[i]   -=  (((a[0] & 7) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+1] -= ((((a[0] >> 3) & 7) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+2] -= ((((a[0] >> 6) | ((a[1] << 2) & 4)) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+3] -= ((((a[1] >> 1) & 7) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+4] -= ((((a[1] >> 4) & 7) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+5] -= ((((a[1] >> 7) | ((a[2] << 1) & 6)) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+6] -= ((((a[2] >> 2) & 7) * NEWHOPE_Q) + 4) >> 3;
    r->coeffs[i+7] -= ((((a[2] >> 5)) * NEWHOPE_Q) + 4) >> 3;
    a += 3;
  }
#elif (NEWHOPE_POLYCOMPRESSEDBITS == 4)
  for(i=0;i<NEWHOPE_N;i+=8)
  {
    r->coeffs[i]   -= (((a[0] & 15) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+1] -= (((a[0] >> 4) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+2] -= (((a[1] & 15) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+3] -= (((a[1] >> 4) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+4] -= (((a[2] & 15) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+5] -= (((a[2] >> 4) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+6] -= (((a[3] & 15) * NEWHOPE_Q) + 8) >> 4;
    r->coeffs[i+7] -= (((a[3] >> 4) * NEWHOPE_Q) + 8) >> 4;
    a += 4;
  }
#else
#error "NEWHOPE_POLYCOMPRESSEDBITS needs to be in {3, 4}"
#endif
}

/*************************************************
* Name:        poly_frommsg
*
* Description: Convert 32-byte message to polynomial
*
* Arguments:   - poly *r:                  pointer to output polynomial
*              - const unsigned char *msg: pointer to input message
**************************************************/
void poly_frommsg(poly *r, const unsigned char *msg)
{
  unsigned int i,j,mask;
  for(i=0;i<NEWHOPE_SYMBYTES;i++)
  {
    for(j=0;j<8;j++)
    {
      mask = -((msg[i] >> j)&1);
      r->coeffs[8*i+j+  0] += mask & (NEWHOPE_Q/2);
      r->coeffs[8*i+j+256] += mask & (NEWHOPE_Q/2);
#if   (NEWHOPE_N == 768)
      r->coeffs[8*i+j+512] += mask & (NEWHOPE_Q/2);
#elif (NEWHOPE_N == 1024)
      r->coeffs[8*i+j+512] += mask & (NEWHOPE_Q/2);
      r->coeffs[8*i+j+768] += mask & (NEWHOPE_Q/2);
#endif
    }
  }
}

/*************************************************
* Name:        poly_tomsg
*
* Description: Convert polynomial to 32-byte message
*
* Arguments:   - unsigned char *msg: pointer to output message
*              - const poly *x:      pointer to input polynomial
**************************************************/
void poly_tomsg(unsigned char *msg, const poly *x)
{
  unsigned int i;
  uint16_t t;

  memset(msg,0,NEWHOPE_SYMBYTES);

  for(i=0;i<256;i++)
  {
    t  = flipabs(x->coeffs[i+  0]);
    t += flipabs(x->coeffs[i+256]);
#if   (NEWHOPE_N == 512)
    t = (t - NEWHOPE_Q/2);
#elif (NEWHOPE_N == 768)
    t += flipabs(x->coeffs[i+512]);
    t = (t - 3*NEWHOPE_Q/4);
#elif (NEWHOPE_N == 1024)
    t += flipabs(x->coeffs[i+512]);
    t += flipabs(x->coeffs[i+768]);
    t = (t - NEWHOPE_Q);
#endif

    t >>= 15;
    msg[i>>3] |= t<<(i&7);
  }
}


void asm_multiple_basemul(int16_t* a, const int16_t* b, const int16_t* root);

/*************************************************
* Name:        poly_uniform_mul_s
*
* Description: Sample a polynomial deterministically from a seed,
*              with output polynomial looking uniformly random TODO
*
* Arguments:   - poly *a:                   pointer to output polynomial
*              - const unsigned char *seed: pointer to input seed
**************************************************/
void poly_uniform_mul_s(poly *s, unsigned char *seed)
{
  unsigned int ctr=0;
  uint16_t val;
  int i,j,l=0;

#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
  int16_t c[64];
#elif (NEWHOPE_N == 768)
  int16_t c[24];
  int count_768=0;
#endif

  shake128ctx state;
  uint8_t buf[SHAKE128_RATE];
  uint8_t extseed[NEWHOPE_SYMBYTES+1];
  memcpy(extseed,seed,NEWHOPE_SYMBYTES);

  for(i=0;i<NEWHOPE_N;i+=64) /* generate a in blocks of 64 coefficients */
  {
    ctr = 0;
    extseed[NEWHOPE_SYMBYTES] = i/64; /* domain-separate the 8, 12 or 16 independent calls */
    shake128_absorb(&state, extseed, NEWHOPE_SYMBYTES+1);
    while(ctr < 64) /* Very unlikely to run more than once */
    {
      shake128_squeezeblocks(buf,1,&state);
      for(j=0;j<SHAKE128_RATE && ctr < 64;j+=2)
      {
        val = (buf[j] | ((uint16_t) buf[j+1] << 8));
#if   (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
        if(val < 19*NEWHOPE_Q)
        {
          val -= ((val*20)>>16)*NEWHOPE_Q;
          c[ctr++] = val;
        }
#elif (NEWHOPE_N == 768)
        if(val < 18*NEWHOPE_Q)

        {
          val -= ((val*19)>>16)*NEWHOPE_Q;
          c[count_768++] = val;
          ctr++;
        }

        if (count_768 == (sizeof(c)/sizeof(c[0]))) {
          asm_multiple_basemul(&s->coeffs[2*l], c, &asm_gammas_montgomery_mul[l]);
          l += 2;
          count_768 =0;
        }
#endif
      }
    }
#if (NEWHOPE_N == 512 || NEWHOPE_N == 1024)
    asm_multiple_basemul(&s->coeffs[2*l], c, &asm_gammas_montgomery_mul[l]);
    l += 64/NEWHOPE_NTT_POLY/2;
#endif
  }
}

/*************************************************
* Name:        poly_sample
*
* Description: Sample a polynomial deterministically from a seed and a nonce,
*              with output polynomial close to centered binomial distribution
*              with parameter k=2
*
* Arguments:   - poly *r:                   pointer to output polynomial
*              - const unsigned char *seed: pointer to input seed
*              - unsigned char nonce:       one-byte input nonce
**************************************************/
void poly_sample(poly *r, const unsigned char *seed, unsigned char nonce, int add)
{
#if NEWHOPE_K != 2
#error "poly_sample in poly.c only supports k=2"
#endif
  unsigned char buf[128], a, b;
  uint32_t t, d;
  int i,j,k;

  unsigned char extseed[NEWHOPE_SYMBYTES+2];

  memcpy(extseed,seed,NEWHOPE_SYMBYTES);
  extseed[NEWHOPE_SYMBYTES] = nonce;

  for(i=0;i<NEWHOPE_N;i+=256) /* Generate noise in blocks of 256 coefficients */
  {
    extseed[NEWHOPE_SYMBYTES+1] = i/256;
    shake256(buf,128,extseed,NEWHOPE_SYMBYTES+2);
    for(j=0;j<128;j+=4)
    {
      t = buf[j] | ((uint32_t)buf[j+1] << 8) | ((uint32_t)buf[j+2] << 16) | ((uint32_t)buf[j+3] << 24);
      d = t & 0x55555555;
      d += (t >> 1) & 0x55555555;

      for(k=0;k<8;k++)
      {
        a = (d >>  4*k)    & 0x3;
        b = (d >> (4*k+2)) & 0x3;
        if(!add)
          r->coeffs[i+2*j+k] = 0;
        r->coeffs[i+2*j+k] += (a - b);
      }
    }
  }
}


extern void asm_bm(int16_t *a, const int16_t *b, const int16_t* gamma);

/*************************************************
* Name:        poly_basemul
*
* Description: Multiply two polynomials in NTT domain.
*
* Arguments:   - const poly *a: pointer to first input and output polynomial
*              - const poly *b: pointer to second input polynomial
**************************************************/
void poly_basemul(poly* a, const poly* b){
  asm_bm(a->coeffs, b->coeffs, asm_gammas_montgomery_mul);
}


extern void asm_barrett_reduce(int16_t *r);

/*************************************************
* Name:        poly_reduce
*
* Description: Applies Barrett reduction to all coefficients of a polynomial
*              for details of the Barrett reduction see comments in reduce.c
*
* Arguments:   - poly *r:       pointer to input/output polynomial
**************************************************/
void poly_reduce(poly *r) {
  asm_barrett_reduce(r->coeffs);
}


extern void asm_div_montconstant(int16_t *r);

/*************************************************
* Name:        poly_div_montconstant
*
* Description: Applies Barrett reduction to all coefficients of a polynomial
*              for details of the Barrett reduction see comments in reduce.c
*
* Arguments:   - poly *r:       pointer to input/output polynomial
**************************************************/
void poly_div_montconstant(poly *r) {
  asm_div_montconstant(r->coeffs);
}


extern void asm_add(int16_t* r, const int16_t* a);

/*************************************************
* Name:        poly_add
*
* Description: Add two polynomials
*
* Arguments:   - poly *r:       pointer to input and output polynomials
*              - const poly *a: pointer to first input polynomial
**************************************************/
void poly_add(poly *r, const poly *a)
{
  asm_add(r->coeffs,a->coeffs);
}


void asm_ntt(int16_t *poly, const int16_t *gammas);

/*************************************************
* Name:        poly_ntt
*
* Description: Forward NTT transform of a polynomial in place
*              Input is assumed to have coefficients in bitreversed order
*              Output has coefficients in normal order
*
* Arguments:   - poly *r: pointer to in/output polynomial
**************************************************/
void poly_ntt(poly *r)
{
  int i;
  for(i=0;i<NEWHOPE_NTT_POLY;i++)
    asm_ntt(r->coeffs+i*NEWHOPE_NTT_LENGTH, asm_gammas_montgomery);
}


void asm_invntt(int16_t *poly, const int16_t *gammas);

/*************************************************
* Name:        poly_invntt
*
* Description: Inverse NTT transform of a polynomial in place
*              Input is assumed to have coefficients in normal order
*              Output has coefficients in normal order
*
* Arguments:   - poly *r: pointer to in/output polynomial
**************************************************/
void poly_invntt(poly *r)
{
  int i;
  for(i=0;i<NEWHOPE_NTT_POLY;i++)
    asm_invntt(r->coeffs+i*NEWHOPE_NTT_LENGTH, asm_gammas_inv_montgomery);
}
