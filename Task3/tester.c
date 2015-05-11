#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	char out[10000];
	BigInt bi1 = biFromInt(0xffffffffffffll);
        BigInt bi2 = biFromInt(0x123456789abcll);
        BigInt bi2t = biFromInt(0x123456789abcll);
        BigInt bi3 = biFromString("5634002667680754350229513540");
        BigInt bi4 = biFromString("112770188065645873042730879462335281972720");
        BigInt bi4t =biFromString("112770188065645873042730879462335281972720");
        biMul(bi1, bi2);
        printf("1: %d \n", biCmp(bi1, bi3) == 0);
        printf("2: %d \n",  biCmp(bi2, bi2t) == 0);

	biToString(bi1, out, 10000);
	printf("%s \n", out);

	biToString(bi2, out, 10000);
	printf("%s \n", out);


        biMul(bi1, bi2);
        printf("3: %d \n", biCmp(bi1, bi4) == 0);
	
	biToString(bi1, out, 10000);
	printf("%s \n", out);

        printf("4: %d \n", biCmp(bi2, bi2t) == 0);
        BigInt bi5 = biFromInt(-1ll);
        BigInt bi5t = biFromInt(-1ll);
        biMul(bi1, bi5);
        printf("5: %d \n", biCmp(bi5, bi5t) == 0);
        printf("6: %d \n", biSign(bi1) < 0);
        biMul(bi1, bi4);
        printf("7: %d \n", biCmp(bi4, bi4t) == 0);
        bi5 = biFromString("-12717115316361138893215167268288118108744759009945360365688272198554511014824198400");
        printf("8: %d \n", biCmp(bi1, bi5) == 0); 

}
