#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	char out[256];
//	char a_str[256] = "123456";
	BigInt a = biFromString("10000000000000000");
	BigInt b = biFromString("32564634643563456");
	
	int iter = 1000000;
	for (int i = 0; i < iter; i++) {
		biAddMod(a, b);
	}  
	for (int i = 0; i < iter; i++) {
		biSubMod(a, b);
	}
/*
	int cmp = biCmp(a, b);
	int signA = biSign(a);
	int signB = biSign(b);
	printf("%d and a = %d, b = %d \n", cmp, signA, signB);
*/
	biToString(a, out, 1000);
	printf("%s \n", out);

/*	biSubMod(a, b);
	biToString(a, out, 1000);
	printf("%s \n", out);
*/
/*	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
*/	return 0;
}
