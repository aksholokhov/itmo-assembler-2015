#include <bigint.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
	char out[10000];
	
	BigInt a = biFromString("-100000001");	
	BigInt b = biFromString("200000002");	
	BigInt c = biFromString("1");	
	BigInt d = biFromString("-1");	

	printf("%d, %d, %d, %d \n", biCmp(a, b), biCmp(b, c), biCmp(c, d), biCmp(d, a));	

	printf("%d, %d, %d, %d\n", biSign(a), biSign(b), biSign(c), biSign(d));
	for (int i = 0; i < 500; i++) {
		//biMul(a, b);
		//printf("%d ", i);
	}

	biAdd(c, d);
	printf("\n OK \n");
	biToString(c, out, 1000);
	printf("%s \n", out);

	biAdd(d, c);
	biToString(d, out, 1000);
	printf("%s \n", out);



	for (int i = 0; i < 50; i++) {
		biAdd(c, d);
	}
	biToString(c, out, 1000);
	printf("%s \n", out);


	printf("add ok \n");
	for (int i = 0; i < 10000; i++) {
	//	biSub(c, d);
	}

	
	biToString(c, out, 1000);
	printf("%s \n", out);

	return 0;
}
