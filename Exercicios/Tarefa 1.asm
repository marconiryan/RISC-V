.include "macros.asm"

.data 
	Z: .space 4
	X: .word 5
	Y: .word 12

.text

	
main:	
	la t0, Z
	lw s0, 0(t0)
	
	la t1, X
	lw s1, 0(t1)
	
	la t2, Y
	lw s2, 0(t2)
	
	read_int(s0)
	
	cmpi(BNE, 10, s0, else)


if:
	addi s1, s1, -1
	j continua

else:
	addi s2, s2, 1

continua:

	print_str("X:")
	print_int(s1)
	print_str("\n")
	
	print_str("Y:")
	print_int(s2)
	print_str("\n")
	
	
	
	