
#include <iostream>
#include <vector>
#include "Vfft64.h"
#include <cmath>
#include <fftw3.h>

using namespace std;

class testbench
{
    vector<short> ar;
    vector<short> ai;

    vector<short> xr;
    vector<short> xi;

    int index;
    int eindex;
    int depth_;

    int count16;
    int invalid_top;
    enum {
        invalid,
        valid
    } mode;

public:
    testbench(int n = 1024);
    void set_input(Vfft64 *top);
    void verify_output(Vfft64 *top);
};

int main(int argc, char *argv[])
{
    testbench tb(16384); 
    Verilated::commandArgs(argc-1, argv+1);

    Vfft64 *top = new Vfft64();

    top->CLK = 0;
    top->RST = 1;

    top->CLK = 0;
    // reset
    top->RST = 1;
    top->eval();
    top->RST = 0;
    top->eval();
    top->RST = 1;
    top->eval();

    cout << "ce\tvalid_i\tar\tai\tbr\tbi\txr\txi\tyr\tyi\tvalid_o\n";
    while (!Verilated::gotFinish()) {
        if (top->CLK) {
            tb.set_input(top);
        }         

        top->CLK = !top->CLK;
        top->eval();

        if (!top->CLK) {
            tb.verify_output(top);
        }
    }

    top->final();


    return 0;
}

testbench::testbench(int n)
    : index(0), eindex(0)
{
    if (n % 64 != 0) {
        cout << "n should be a multiple of 64" << endl;
        exit(EXIT_FAILURE);
    }
    for (int i=0; i<n; i++) {
        ar.push_back(random() & 0x3ff);
        ai.push_back(random() & 0x3ff);
        if (random() & 1) 
            ar[i] *= -1;
        if (random() & 1)
            ar[i] *= -1;
        ar[i] /= 64;
        ai[i] /= 64;
    }

    int fftn = 64;
    fftw_complex *in, *out;
    fftw_plan p;
    in = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * fftn);
    out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * fftn);

    p = fftw_plan_dft_1d(fftn, in, out, FFTW_FORWARD, FFTW_ESTIMATE);

    for (int i=0; i<n; i+=fftn) {

        // fft
        for (int j=0; j<fftn; j++) {
            in[j][0] = ar[i+j];
            in[j][1] = ai[i+j];
        }

        fftw_execute(p);

        for (int j=0; j<fftn; j++) {
            xr.push_back(round(out[j][0]));
            xi.push_back(round(out[j][1]));
        }
    }

    for (int i=0; i<fftn; i++) {
        cout << "(" << (int)ar[i] << ")+j*(" << (int)ai[i] << "), ";
    }
    cout << "\n";
    // // stage 1
    // for (int i=0; i<8; i++) {
    //     int pr = ar[i] + ar[i+8];
    //     int pi = ai[i] + ai[i+8];
    //     int mr = ar[i] - ar[i+8];
    //     int mi = ai[i] - ai[i+8];

    //     int tr = round(mr * cos(-2*M_PI*i/16) - mi * sin(-2*M_PI*i/16));
    //     int ti = round(mr * sin(-2*M_PI*i/16) + mi * cos(-2*M_PI*i/16));

    //     cout << pr << "+j*" << pi << "\t" << mr << "+j*" << mi << "\t" << tr << "+j*" << ti << "\n";
    // }
    for (int i=0; i<16; i++) {
        cout << (int)xr[i] << "+j*" << (int)xi[i] << " ";
    }
    cout << "\n\n";

    cout << "ar.size() = " << ar.size() << "\n"
         << "ar.size() = " << ai.size() << "\n"
         << "ar.size() = " << xr.size() << "\n"
         << "ar.size() = " << xi.size() << "\n";
    count16 = 0;
    invalid_top = 10;
    mode = invalid;
}

void testbench::set_input(Vfft64 *top)
{
    top->rd_en = 1;

    if (mode == valid) {
        if (index >= ar.size()) {
            top->valid_a = 0;
        }
        else {
            top->valid_a = 1;
            top->ar = ar[index];
            top->ai = ai[index];
            index++;
            if (count16 == 63) {
//                    mode = invalid;
                count16 = 0;
            }
            else {
                count16++;
            }
        }
    }
    else {
        top->valid_a = 0;
        if (count16 == invalid_top) {
            mode = valid;
            count16 = 0;
        }
        else {
            count16++;
        }
    }
}

void testbench::verify_output(Vfft64 *top)
{
    short txr = top->xr;
    short txi = top->xi;

    if (txr >= 1024) {
        txr -= 2048;
    }
    if (txi >= 1024) {
        txi -= 2048;
    }

    // FULL
    cout << (int)top->valid_a << "\t"
         << (int)top->ar << "\t"
         << (int)top->ai << "\t"
         << (int)txr << "\t(" << (int)xr[eindex] << ")" << "\t"
         << (int)txi << "\t(" << (int)xi[eindex] << ")" << "\t"
         << (int)top->valid_o << "\t"
         << "(" << eindex << ")\n";

    // if (top->ce) 
    //     // Stage 1
    //     cout << (int)(char)top->ce << "\t"
    //          << (int)(char)top->valid_a << "\t"
    //          << (int)(char)top->ar << "\t"
    //          << (int)(char)top->ai << "\t"
    //          << (int)(char)top->v__DOT__valid_1 << "\t"
    //          << (int)(char)top->v__DOT__ar1 << "\t"
    //          << (int)(char)top->v__DOT__ai1 << "\t"
    //          << (int)(char)top->v__DOT__br1 << "\t"
    //          << (int)(char)top->v__DOT__bi1 << "\t"
    //          << (int)(char)top->v__DOT__ar2 << "\t"
    //          << (int)(char)top->v__DOT__ai2 << "\t"
    //          << (int)(char)top->v__DOT__br2 << "\t"
    //          << (int)(char)top->v__DOT__bi2 << "\t"
    //          << (int)(char)top->v__DOT__ar3 << "\t"
    //          << (int)(char)top->v__DOT__ai3 << "\t"
    //          << (int)(char)top->v__DOT__br3 << "\t"
    //          << (int)(char)top->v__DOT__bi3 << "\t"
    //         // Stage 2
    //          // << (int)(char)top->v__DOT__ar4 << "\t"
    //          // << (int)(char)top->v__DOT__ai4 << "\t"
    //          // << (int)(char)top->v__DOT__br4 << "\t"
    //          // << (int)(char)top->v__DOT__bi4 << "\t"
    //          // << (int)(char)top->v__DOT__ar5 << "\t"
    //          // << (int)(char)top->v__DOT__ai5 << "\t"
    //          // << (int)(char)top->v__DOT__br5 << "\t"
    //          // << (int)(char)top->v__DOT__bi5 << "\t"
    //          // << (int)(char)top->v__DOT__ar6 << "\t"
    //          // << (int)(char)top->v__DOT__ai6 << "\t"
    //          // << (int)(char)top->v__DOT__br6 << "\t"
    //          // << (int)(char)top->v__DOT__bi6 << "\t"
    //         // Stage 3
    //          // << (int)(char)top->v__DOT__ar7 << "\t"
    //          // << (int)(char)top->v__DOT__ai7 << "\t"
    //          // << (int)(char)top->v__DOT__br7 << "\t"
    //          // << (int)(char)top->v__DOT__bi7 << "\t"
    //          // << (int)(char)top->v__DOT__ar8 << "\t"
    //          // << (int)(char)top->v__DOT__ai8 << "\t"
    //          // << (int)(char)top->v__DOT__br8 << "\t"
    //          // << (int)(char)top->v__DOT__bi8 << "\t"
    //          // << (int)(char)top->v__DOT__ar9 << "\t"
    //          // << (int)(char)top->v__DOT__ai9 << "\t"
    //          // << (int)(char)top->v__DOT__br9 << "\t"
    //          // << (int)(char)top->v__DOT__bi9 << "\t"
    //         // Stage 4
    //          // << (int)(char)top->v__DOT__ar10 << "\t"
    //          // << (int)(char)top->v__DOT__ai10 << "\t"
    //          // << (int)(char)top->v__DOT__br10 << "\t"
    //          // << (int)(char)top->v__DOT__bi10 << "\t"
    //          // << (int)(char)top->xr << "\t(" << (int)xr[eindex] << ")" << "\t"
    //          // << (int)(char)top->xi << "\t(" << (int)xi[eindex] << ")" << "\t"
    //          // << (int)(char)top->yr << "\t(" << (int)yr[eindex] << ")" << "\t"
    //          // << (int)(char)top->yi << "\t(" << (int)yi[eindex] << ")" << "\t"
    //          << "\n";

    int error_limit = 8;    // 0.5 * 6 stages
    if (top->valid_o) {
        if (txr != xr[eindex]) {
            if (abs(txr - xr[eindex]) <= error_limit) {
//                cout << "xr differs by " << abs(txr - xr[eindex]) << "\n";
            }
            else {
                cout << "xr " << (int)txr << "!=" << (int)xr[eindex] << "\n";
                exit(EXIT_FAILURE);
            }
        }
        if (txi != xi[eindex]) {
            if (abs(txi - xi[eindex]) <= error_limit) {
//                cout << "xi differs by" << abs(txi - xi[eindex]) << ".\n";
            }
            else {
                cout << "xi " << (int)txi << "!=" << (int)xi[eindex] << "\n";
                exit(EXIT_FAILURE);
            }
        }
        eindex++;

        if (eindex >= xr.size()) {
            cout << "OK" << endl;
            exit(EXIT_SUCCESS);
        }
    }
}
