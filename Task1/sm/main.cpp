#include <iostream>
#include <stdarg.h>
#include <stdlib.h>
#include "main.h"

using namespace std;

int main() {
    char* buf = new char[20];
    hw_sprintf(buf, "%d", 50);
    cout<<buf;
    return 0;
}

void hw_sprintf(char *buf, char const *format, ...) {
    va_list params;
    va_start(params, format);
    bool correctSequence = false;
    char* reservedBuf = buf;
    int flags = 0;
    int mul = 1;
    int width = 0;
    char const *c = format;
    while (*c != 0) {
        if (!correctSequence) {
            if (*c != '%') {
                *buf = *c;
                buf++;
                continue;
            }
            correctSequence = true;
            flags = 0;
            width = 0;
            mul = 1;
            c++;
            continue;

        }
        if (*c == '%') {
            *buf = *c;
            buf++;
            c++;
            continue;
        }
        if (*c == '+') {
            flags |= 2;
            c++;
            continue;
        }
        if (*c == '-') {
            flags |= 4;
            c++;
            continue;
        }
        if (*c == ' ') {
            flags |= 16;
            c++;
            continue;
        }
        if (*c == '0') {
            if ((flags & 4) != 4) flags |= 8;
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
            flags |= 32;
            c += 1;
            c++;
            continue;
        }
        if ((*c == 'i') || (*c == 'd')) {
            flags |= 64;
            if (flags & 32) {
                long long int a = va_arg(params, long long int);
                my_sequence_print(buf, a, flags, width);
                correctSequence = false;
                c++;
                continue;
            }
            int a = va_arg(params, int);
            cout<<a<<" "<<width<<'\n';
            my_sequence_print(buf, a, flags, width);
            correctSequence = false;
            c++;
            continue;
        }
        if (*c == 'u') {

        }
        *buf = *c;
        buf++;
        c++;
        correctSequence = false;
    }
    *buf = '0';
    buf = reservedBuf;

}

void my_sequence_print(char *buf, long long int c, int flags, int width){

}

void my_sequence_print(char *& buf, int c, int flags, int width) {
    if (width == 0) {
        if (c >= 0) {
            if ((flags & 2) == 2) {
                *buf = '+';
                buf++;
                if ((flags & 16) == 16) {
                    *buf = ' ';
                    buf++;
                }
            }
        }
        my_itoa(c, buf);
        buf++;
        return;
    }
    int t = c;
    int i = 0;
    if (t < 0) i += 1;
    while (t != 0) {
        t /= 10;
        i++;
    }
    t = width;
    t -= i;
    if ((flags & 4) == 4) {
        itoa(c, buf, 10);
        for (int j = 0; j < t; j++) {
            *buf = ' ';
            buf++;
        }
        return;
    }

    for (int j = 0; j < t; j++) {
        if ((flags & 8) == 8) {
            *buf = '0';
        }
        else {
            *buf = ' ';
        }
        buf++;
    }
    my_itoa(c, buf);
}

void my_itoa(int a, char *& buf) {
    int i = 0;
    char* buf2 = new char[5];
    while (a != 0) {
        int q = a%10;
        cout<<q<<'\n';
        i++;
        buf2++;
        a/=10;
    }
    while (i != 0) {
        buf2--;
        *buf == *buf2;
        buf++;
        i--;
    }
}
