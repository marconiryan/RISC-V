.include "macros.asm"
.data
	vetor: .word 1,2,3,4,5,6,7,8,9,1
	tam: .word 10
	
.text

ini:	
	la t0, tam
	lw s0, 0(t0)  #Tamanho
	li s5, 4 #Bytes
	li s1, 0  # Contador 
	
main:
	BGE, s1, s0, desvio
	mul a1, s1, s5  
	la a0, vetor
	call func
	addi s1, s1, 1
	j main
	
	
	
func:
	add a0, a0, a1
	lw a3, 0(a0)
	print_int(a3)
	print_str("\n")
	ret
	
desvio:
	print_str("Acabou")
	
	
	
	
