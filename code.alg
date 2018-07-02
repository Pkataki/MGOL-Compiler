inicio
	varinicio
		A lit;
		B int;
		D real;
		E real;
		C real;
	varfim;
	
	escreva "Digite B" ;
	
	leia B;
	
	escreva "Digite A:";
	
	leia A;

	se ( B > 2 ) 
	entao	
		se ( B <= 4 )
		entao
			se (B >= 7)
			entao
			escreva "B esta entre 2 e 4";
			fimse
		fimse
	fimse
	
	B<-B+1;
	B<-B+2;
	B<-B+3;
	D<-B + 1.0;
	E<-5.5;
	C<-2E5 + E;

	escreva "\nB=\n";
	escreva D;
	escreva "\n";
	escreva C;
	escreva "\n";
	escreva A;


fim
