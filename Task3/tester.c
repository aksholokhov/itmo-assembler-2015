#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	char out[10000];

	BigInt a = biFromInt(-0);
	BigInt b = biFromString("-0");
	
	biToString(b, out, 1000000);
	printf("%s \n", out);
	printf("\n");

	biToString(b, out, 1000000);
	printf("%s \n", out);
	printf("\n");


/*int64_t t = 7328575930287495857;
	BigInt a = biFromString("2189507098532170298357210983570982135");
		
	for (int i =0; i < 50; i++) {
		biToString(a, out, i);
		printf("%d: %s ",i, out);
		printf("\n");
	}
 	BigInt amul = biFromString("98174981264");
	BigInt b = biFromString("-7432503025832049856073465073265020432923087450234509874358763052874309852304875632");
	BigInt bmul = biFromString("2");
	BigInt res = biFromString("1");

	BigInt a = biFromInt(12345;
	BigInt b = biFromInt(1000000000);
	
	biSub(b, a);	

	for (int i = 0; i < 300; i++) {
		biMul(a, amul);
	}
	biToString(a, out, 1000000);
	printf("%s \n", out);
	printf("\n");

	biToString(b, out, 1000000);
	printf("%s \n", out);
	printf("\n"); 

	int k = 1000;
	for (int i = 0; i < k; i++) {
		biMul(a, b);;
	//	printf("%d, \n", i);
		biToString(a, out, 1000000);
		//printf("%s \n", out);
		//printf("\n");
	}
*/
/*	int k = 10000;
	for (int i = 0; i < k; i++) {
		printf("%d \n", i);
		a = biInit(1);
		if (i % 2 == 0) biCopy(a, amul);
		else biCopy(a, b);
		biDelete(a);
//		biToString(a, out, 1000000);
//		printf("%s \n", out);
	}
*/

/*
	biCopy(res, amul);
	biSub(amul, c);
	biSub(amul, cmul);
//	printf("after cycle");
	int i = biCmp(res, amul);
	biToString(amul, out, 1000000);
	printf("%s \n", out);
	printf("%d \n", i);
*/

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
