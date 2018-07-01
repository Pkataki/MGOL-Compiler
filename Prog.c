#include<stdio.h>
#include<stdlib.h>
typedef char lit[256];
void main(void){
	/*----Variaveis temporarias----*/
	int T0;
	int T1;
	int T2;
	int T3;
	int T4;
	double T5;
	/*------------------------------*/
	lit A;
	int B;
	int D;
	double E;
	double C;



	printf("Digite B");
	scanf("%d",&B);
	printf("Digite A:");
	scanf("%s",A);
	T0 = B > 2;
	if( T0 ){
		T1 = B <= 4;
		if( T1 ){
			printf("B esta entre 2 e 4");
		}
	}
	T2 = B + 1;
	B = T2;
	T3 = B + 2;
	B = T3;
	T4 = B + 3;
	B = T4;
	D = B;
	E = 5.5;
	T5 = 2E5 + E;
	C = T5;
	printf("\nB=\n");
	printf("%d",D);
	printf("\n");
	printf("%lf",C);
	printf("\n");
	printf("%s",A);
}
