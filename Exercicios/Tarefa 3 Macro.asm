.include "macros.asm"
.data
	vetor: .word 1,2,3,4,5,6,7,8,9
	tam: .word 9
	
.macro percorrer(%vetor, %i)
	la t0, %vetor
	add t0, t0, %i
	lw a0, 0(t0)
	print_int(a0)
	print_str("\n")
.end_macro


.text

ini:	
	la t0, tam
	lw s0, 0(t0)  #Tamanho
	li s5, 4 #Bytes
	li s1, 0  # Contador 
	
main:
	BGE, s1, s0, desvio
	mul t2, s1, s5  
	percorrer(vetor, t2)
	addi s1, s1, 1
	j main
	
desvio:
	print_str("Acabou")
	
	
	
	
