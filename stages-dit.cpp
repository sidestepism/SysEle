
#include <iostream>
#include <complex>
#include <cmath>

using namespace std;

typedef complex<double> cd;

// 3.1415...
const cd pi = cd(M_PI, 0);
// j (imaginary number)
const cd j  = cd(0, 1);

void initialize(cd *arr)
{
    arr[0] = cd(5, 15); 
    arr[1] = cd(1, 3);  
    arr[2] = cd(-12, 3);  
    arr[3] = cd(-7, 11); 
    arr[4] = cd(1, 11); 
    arr[5] = cd(12, 7);  
    arr[6] = cd(-13, 5);  
    arr[7] = cd(-8, 14); 
    arr[8] = cd(13, 4);  
    arr[9] = cd(-8, 1);  
    arr[10] = cd(4, 5);  
    arr[11] = cd(1, 11); 
    arr[12] = cd(-6, 2);  
    arr[13] = cd(-10, 10); 
    arr[14] = cd(0, 6);  
    arr[15] = cd(-4, 4);  
    arr[16] = cd(-9, 7);  
    arr[17] = cd(-9, 3);  
    arr[18] = cd(-8, 12); 
    arr[19] = cd(-7, 11); 
    arr[20] = cd(14, 0);  
    arr[21] = cd(11, 2);  
    arr[22] = cd(8, 2);  
    arr[23] = cd(-7, 12); 
    arr[24] = cd(-4, 0);  
    arr[25] = cd(3, 11); 
    arr[26] = cd(-7, 4);  
    arr[27] = cd(0, 4);  
    arr[28] = cd(-5, 15); 
    arr[29] = cd(-2, 7);  
    arr[30] = cd(10, 2);  
    arr[31] = cd(14, 7);  
    arr[32] = cd(-8, 7);  
    arr[33] = cd(-3, 10); 
    arr[34] = cd(-15, 0);  
    arr[35] = cd(-5, 9);  
    arr[36] = cd(8, 4);  
    arr[37] = cd(-12, 9);  
    arr[38] = cd(-12, 13); 
    arr[39] = cd(5, 13); 
    arr[40] = cd(4, 13); 
    arr[41] = cd(-8, 2);  
    arr[42] = cd(2, 15); 
    arr[43] = cd(8, 4);  
    arr[44] = cd(-8, 15); 
    arr[45] = cd(-9, 1);  
    arr[46] = cd(-14, 5);  
    arr[47] = cd(2, 14); 
    arr[48] = cd(12, 11); 
    arr[49] = cd(-13, 4);  
    arr[50] = cd(3, 2);  
    arr[51] = cd(6, 11); 
    arr[52] = cd(10, 8);  
    arr[53] = cd(-9, 1);  
    arr[54] = cd(-6, 9);  
    arr[55] = cd(-7, 15); 
    arr[56] = cd(10, 2);  
    arr[57] = cd(-6, 4);  
    arr[58] = cd(6, 1);  
    arr[59] = cd(-12, 4);  
    arr[60] = cd(12, 2);  
    arr[61] = cd(3, 3);  
    arr[62] = cd(13, 12); 
    arr[63] = cd(-11, 6);  
}

int stage(cd *arr, int n)
{
    int di = n/2;

    //cout << n << "\n";
    
    for (int k=0; k<64; k+=n) {
        for (int i=0; i<di; i++) {
            //cout << "k=" << k << ", i=" << i << ", di=" << di << "\n";
            cd a = arr[k+i];
            cd b = arr[k+i+di];

	    b *= exp(-pi*cd(2,0)*cd(i,0)*j/cd(n,0));

            arr[k+i] = a + b;
            arr[k+i+di] = (a - b);
        }
    }
}

int reverse6(int i)
{
    i = ((i & 3) << 4) | (i & 0x0c) | ((i & 0x30) >> 4);
    i = ((i & 0x15) << 1) | ((i & 0x2a) >> 1);
    return i;
}

int reorder(cd *arr)
{
    for (int i=0; i<64; i++) {
        int j = reverse6(i);
        if (i < j) {
            cout << "swap " << i << " " << j << "\n";
            swap(arr[i], arr[j]);
        }
    }
}

int main(int argc, char *argv[])
{
    cd arr[64];
    int n = 1;

    initialize(arr);

    cout << "==================================================\n"
         << " REORDER\n\n";
    reorder(arr);
    cout << "\n";

    for (int i=0; n<=64; n<<=1, i++) {
        stage(arr, n);
        
        cout << "==================================================\n"
             << " STAGE " << (i+1) << "\n\n";
        for (int j=0; j<64; j++) {
            cout << j << ": " << round(arr[j].real()) << " " << round(arr[j].imag()) << "\n";
        }
        cout << "\n\n";
    }


    cout << "==================================================\n"
         << " FINAL RESULT (after reorder)\n\n";
    for (int i=0; i<64; i++) {
        cout << i << ": " << round(arr[i].real()) << " " << round(arr[i].imag()) << "\n";
    }

    return 0;
}
