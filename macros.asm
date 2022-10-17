.macro print_int (%x)
	li a7, 1
	addi a0, %x, 0
	ecall
	.end_macro

.macro read_int(%rg)
	li a7,5
	ecall
	addi %rg, a0, 0
.end_macro


.macro print_str (%str)
	.data
		Frase: .string %str
	.text
		li a7, 4
		la a0, Frase
		ecall
.end_macro


.macro cmpi(%operando, %p1, %p2, %desvio) #Comparação com inteiro
	# Operando: instrução.
	# P1: inteiro.
	# P2: registrador.
	# Desvio: Rotulo de desvio.
	li t0, %p1 
	%operando, t0, %p2, %desvio
.end_macro

.macro for(%condicao,%contador, %condicao_parada, %loop,%desvio)
	
	%condicao %contador,%condicao_parada, %desvio
	j %loop
.end_macro


.macro read_int_rule(%rg, %parameter_1, %parameter_2, %desvio, %condicao)
	# Rg: Destino
	# Parameter_1 e Parameter_2 valores a serem comparados
	# Desvio: Label de desvio
	# Instrução de desvio. Ex: BNE
	cmpi(%condicao %parameter_1, %parameter_2, %desvio)
	read_int(%rg)
	j %desvio
.end_macro

.macro ler_3(%contador, %reg_1, %reg_2, %reg_3)
	Label_1:
		read_int_rule(%reg_1, 0, %contador, Label_2, BNE)
		j Desvio
	Label_2:
		read_int_rule(%reg_2, 1, %contador, Label_3, BNE)
		j Desvio
	Label_3:
		read_int_rule(%reg_3, 2, %contador, Desvio, BNE)
	Desvio:
	

.end_macro


.macro cmp_3(%condicao,%r1, %r2, %r3, %retorno)
	addi %retorno,%r1, 0
	%condicao %r2, %retorno,R2
	%condicao %r3, %retorno, R3
	j Desvio
	R2:
		addi %retorno, %r2,0
		
	R3:	
		%condicao %r2, %r3, Desvio
		addi %retorno, %r3,0
	Desvio:
.end_macro
