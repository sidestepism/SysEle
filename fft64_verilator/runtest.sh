#!/bin/sh

set -e;

# ADD FILES HERE!
verilogs='../../rtl/fft64.v'

echo ${verilogs}

dir=test
echo ${dir}
verilator -LDFLAGS '-lfftw3' -Mdir "${dir}" --cc ${verilogs} --exe main.cpp
# verilator --lint-only ${verilogs} 
make -C "${dir}" -f Vfft64.mk Vfft64
./test/Vfft64

