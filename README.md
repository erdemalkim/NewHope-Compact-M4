# Cortex-M4 optimizations for {R,M}LWE schemes

This repository contains ARM Cortex-M4 implementation of three lattice-based 
KEMs, NewHope, Kyber, and NewHope-Compact. 

For prerequisites, setup and installation please refer to 
[PQM4](https://github.com/mupq/pqm4/blob/master/README.md). You can obtain our 
code and libopencm3 with:
```
git clone --recursive https://github.com/erdemalkim/NewHope-Compact-M4.git
```

## Usage

There are 3 different compilation options for each scheme:

- `test`: This outputs binaries for each parameter set to test whether the scheme
works as expected or not.
- `speed`: This outputs binaries for each parameter sets to measure the runtime of
specific routines.
- `hashing`: This outputs binaries for each parameter sets to measure the cycles
spent for hashing.

These options can be compiled by calling `make {option}`. Replace `{option}` by
one of the above keywords. Note that there are also three different optimization 
flags that can be enabled/disabled in `params.h` or calling 
`make FLAG1=-D{optimization_flag} FLAG2=-D{optimization_flag} FLAG3=-D{optimization_flag} {option}`.
Replace `{optimization_flag}` by one of the below keywords:

- `USE_REPT`: It changes most of the loops in assembly implementations to `rept`.
It will increase the code size while reducing the runtime.
- `OPTIMIZE_STACK`: When it is not selected, it performs the addition in NTT domain
instead of the normal domain.
- `SMALL_SECRET_KEY`: It only stores the seed, which is used to sample the secret
key, instead of storing the whole secret key. 

Then, the generated binaries can be flashed to STM32F4DISCOVERY board by running 
`make run{Option}`. For example; `make FLAG1=-DOPTIMIZE_STACK test` to compile
and `make runTest` to flash and get results from the board. Moreover, there is 
also a code-size measurement option that excludes common code like hashing or 
C standard library functions. This measurement can be performed by calling
`make FLAG1=-D{optimization_flag} FLAG2=-D{optimization_flag} FLAG3=-D{optimization_flag} runSize`.

## Benchmarks
The current benchmark results can be found in [benchmarks.md](benchmarks.md).
These numbers were obtained with `arm-none-eabi-gcc 9.2.1`. 
[benchmarks.sh](benchmarks.sh) can be used to reproduce these numbers. It
compiles all possible binaries for each implementation and flashes them to
the board. Then, it collects the results and writes them to 
[benchmarks.md](benchmarks.md).

## Licence

The most of the c codes in the repository are taken from
[PQM4](https://github.com/mupq/pqm4) which is released under CC0, the codes
that have different licence (public domain or MIT) indicated in the top of the
file if needed.
All assembly files in this repository released under
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).
