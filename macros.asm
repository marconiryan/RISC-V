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

.macro for(%contador, %condicao_parada, %loop,%desvio)
	BGE %contador,%condicao_parada, %desvio
	j %loop
.end_macro
