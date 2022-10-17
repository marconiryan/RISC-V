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
