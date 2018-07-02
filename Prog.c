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
	int T5;
	double T6;
	double T7;
	/*------------------------------*/
	lit A;
	int B;
	double D;
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
			T2 = B >= 7;
			if( T2 ){
				printf("B esta entre 2 e 4");
			}
		}
	}
	T3 = B + 1;
	B = T3;
	T4 = B + 2;
	B = T4;
	T5 = B + 3;
	B = T5;
	T6 = B + 1.0;
	D = T6;
	E = 5.5;
	T7 = 2E5 + E;
	C = T7;
	printf("\nB=\n");
	printf("%lf",D);
	printf("\n");
	printf("%lf",C);
	printf("\n");
	printf("%s",A);
}
