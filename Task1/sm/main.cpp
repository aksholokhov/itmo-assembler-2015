#include <iostream>
#include <stdarg.h>
#include <stdlib.h>
#include "main.h"

using namespace std;

int main() {
    char* out = new char[20];
    /*hw_sprintf(out, "Hello world %d\n", 239);
    cout<<out;
    hw_sprintf(out, "%0+5u\n", 51);
    cout<<out;
    hw_sprintf(out, "<%8u=%-8u>\n", 1234, 5678);
    cout<<out;
    hw_sprintf(out, "%i\n", -1);
    cout<<out;
    //hw_sprintf(out, "%llu\n", (long long)-1);
    //cout<<out<<'\n';
    hw_sprintf(out, "%wtf\n", 1, 2, 3, 4);
    cout<<out;
    hw_sprintf(out, "50%%\n");
    */
    hw_sprintf(out, "aaa", 239);
    cout<<out;
    return 0;
}

const int CONTROL_FLAG = 1;
const int SIGN_FULL_FLAG = 2;
const int LEFT_ALIGN_FLAG = 4;
const int FILL_ZERO_FLAG = 8;
const int ONLY_MINUS_FLAG = 16;
const int LONG_FLAG = 32;
const int SIGNED_NUM_FLAG = 64;


void hw_sprintf(char *buf, char const *format, ...) {

    va_list params;
    va_start(params, format);
    bool correctSequence = false;
    char * reservedBuf = buf;
    int flags = 0;
    int mul = 1;
    int width = 0;
    char const *c = format;
    while (*c != 0) {
        if (*c == '%') {
            flags ^= CONTROL_FLAG;
        }
        if ((flags & CONTROL_FLAG) == CONTROL_FLAG) {
            if (*c == '+') {
                flags |= SIGN_FULL_FLAG;
                c++;
                continue;
            }
            if (*c == '-') {
                flags |= LEFT_ALIGN_FLAG;
                c++;
                continue;
            }
            if (*c == ' ') {
                flags |= ONLY_MINUS_FLAG;
                c++;
                continue;
            }
            if (*c == '0') {
                if ((flags & LEFT_ALIGN_FLAG) != LEFT_ALIGN_FLAG) flags |= FILL_ZERO_FLAG;
                c++;
                continue;
            }

            if ((*c > '0') && (*c <= '9')) {
                width += mul * (*c - '0');
                mul *= 10;
                c++;
                continue;
            }
            if ((*c == 'l') && (format[(*c) + 1] == 'l')) {
                flags |= LONG_FLAG;
                c += 2;
                continue;
            }
            if ((*c == 'i') || (*c == 'd') || (*c == 'u')) {
                if ((*c == 'i') || (*c == 'd')) flags |= SIGNED_NUM_FLAG;
                if ((flags & LONG_FLAG) == LONG_FLAG) {
                    long long int a = va_arg(params, long long int);
                    my_sequence_print(buf, a, flags, width);
                } else {
                    int a = va_arg(params, int);
                    my_sequence_print(buf, a, flags, width);
                }
                c++;
                flags = 0;
                width = 0;
                mul = 1;
                continue;
            }
            if (*c != '%') {
                *buf++ = '%';
                *buf++ = *c;
                c++;
                flags = 0;
                width = 0;
                mul = 1;
                continue;
            }
        } else {
            *buf++ = *c;
        }
        c++; // is better than c, for sure
    }
    *buf++ = 0;
}

void my_sequence_print(char *& buf, long long int c, int flags, int width){

}

void my_sequence_print(char *& buf, int c, int flags, int width) {

    int t = c;
    int i = 0;
    if ((t < 0) || ((flags & SIGNED_NUM_FLAG) == SIGNED_NUM_FLAG)) {
            i += 1;
    }
    while (t != 0) {
        t /= 10;
        i++;
    }
    t = width;
    t -= i;
    if (t <= 0) {
        print_sign(buf, c, flags);
        if (c < 0) c = -c;
        print_module(c, buf);
    } else  {
        if ((flags & LEFT_ALIGN_FLAG) == LEFT_ALIGN_FLAG) {
            print_sign(buf, c, flags);
            print_module(c, buf);
        }
        //TODO: 000+1005

        if ((flags & FILL_ZERO_FLAG) == 0) {
            for (int j = 0; j < t; j++) {
                *buf++ = ' ';
            }
        }
        print_sign(buf, c, flags);

        if ((flags & FILL_ZERO_FLAG) == FILL_ZERO_FLAG) {
            for (int j = 0; j < t; j++) {
                *buf++ = '0';
            }
        }

        if ((flags & LEFT_ALIGN_FLAG) == 0) {
            print_module(c, buf);
        }
    }
}

void print_sign(char *& buf, int c, int flags) {
        if ((flags & SIGNED_NUM_FLAG) == SIGNED_NUM_FLAG) {
            if (c < 0) {
                *buf++ = '-';
                c = -c;
            } else  {
                if ((flags & SIGN_FULL_FLAG) == SIGN_FULL_FLAG) {
                    *buf++ = '+';
                }
                else if ((flags & ONLY_MINUS_FLAG) == ONLY_MINUS_FLAG) {
                    *buf++ = ' ';
                }
            }
        }
}

void print_module(int a, char *& buf) {
    int i = 0;
    char* buf2 = new char[20];
    while (a != 0) {
        int q = a%10;
        *buf2++ = '0' + q;
        i++;
        a/=10;
    }
    buf2--;
    while (i != 0) {
        *buf++ = *buf2--;
        i--;
    }
}
