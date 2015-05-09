#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	char out[256];
//	char a_str[256] = "123456";
	BigInt a = biFromString("0000000000");
	BigInt b = biFromString("00000000000000000000000000000000000000000000000000000000000000000000000");
	int cmp = biCmp(a, b);
	int signA = biSign(a);
	int signB = biSign(b);
	printf("%d and a = %d, b = %d \n", cmp, signA, signB);
//	biAddMod(a, b);
	biToString(b, out, 1000);
	printf("%s \n", out);
/*	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
*/	return 0;
}
