.include "macros.asm"
.data
	Parada: .word 3	
.text


main:
	lw s0, Parada
	li s1, 0 #Contador
	#S2 - S4 = Entrada
	#S5 = min
	#S6 = Max

loop:
	for(BGE,s1, s0, entrada, desvio)
entrada:
	
	ler_3(s1,s2,s3,s4) 
	addi s1, s1, 1
	j loop

desvio:
	cmp_3(BLT, s2,s3,s4,s5)
	cmp_3(BGE, s2,s3,s4,s6)
	
	print_str("Menor Numero:")
	print_int(s5)
	print_str("\n")
	print_str("Maior Numero:")
	print_int(s6)