#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	char out[2048];
//	char a_str[256] = "123456";
	BigInt a = biFromString("200000002");
	BigInt amul = biFromString("200000002");
	BigInt c = biFromString("12434543657645745764564534");
	BigInt cmul = biFromString("12434543657645745764564534");
/*
	biToString(a, out, 1000000);
	printf("%s \n", out);
	printf("\n");


	biToString(amul, out, 1000000);
	printf("%s \n", out);
	printf("\n");
*/

	int k = 700;
	for (int i = 0; i < k; i++) {
		biMul(amul, a);
		/*printf("cycle: %d \n", i);
		biToString(amul, out, 1000000);
		printf("%s \n", out);*/
		printf("%d \n", i);
	}
//	printf("after cycle");
	
//	biToString(amul, out, 1000000);
//	printf("%s \n", out);
	printf("OK \n");



/*	biCopy(amul, a);
	biMul(amul, c);
	biCopy(cmul, amul);
	for (int i = 0; i < k; i++) {
		biMul(cmul, amul);
	}

	biToString(cmul, out, 1000000);
	printf("%s \n", out);
*/	
/*	biMulSc(b, k, 0);
	for (int i = 0; i < k -1; i++) {
		biSubMod(b, a);
	}	
*/
//	biAdd(a, b);	
/*	int iter = 1000000;
	for (int i = 0; i < iter; i++) {
		biAddMod(a, b);
	}  
	for (int i = 0; i < iter; i++) {
		biSubMod(a, b);
	}
*/

/*
	int cmp = biCmp(a, b);
	int signA = biSign(a);
	int signB = biSign(b);
	printf("%d and a = %d, b = %d \n", cmp, signA, signB);

	biToString(a, out, 1000);
	printf("%s \n", out);
	biToString(b, out, 1000);
	printf("%s \n", out);
	biSubMod(a, b);
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
