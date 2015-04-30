#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	int v = 1;
	char out[256];
	BigInt a = bInit(2);
	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
	bPush(a, v);
	biToStringAsIs(a, out);
	printf("%s \n", out);
	return 0;
}
