.data
	navios_matriz: .space 400
	tiros: .space 400
	record: .space 20 # Record do jogo
	player_1: .space 24 # Dados player 1
	comecou: .word 0 # Flag para saber se o jogo começou
	navio_estatico_1: .string "1 3 5 9" # Horizontal ou Vertical \ Tamanho \ Linha \ Coluna
	navio_estatico_2: .string "1 2 7 8"
	navio_estatico_3: .string "0 2 1 6"
	navios: .asciz	"1\n1 5 1 1\n0 5 2 2\n0 1 6 4"

.text


# =====================================
#
# 		Macros
#
# =====================================

.macro read_str(%rg)
	# ==============================
	# |Leitura de string |
	# Armazena no registrador rg
	# ==============================
	.data
		.align 2
		Frase: .space 10
	.text
		li a7, 8
		la a0, Frase
		li a1, 100
		ecall
		mv %rg, a0	
.end_macro

.macro print_int (%x)
	# =======================================
	# |Imprime inteiro passado em x|
	# =======================================
	li a7, 1
	addi a0, %x, 0
	ecall
.end_macro

.macro print_str (%str)
	# =======================================
	# |Imprime string passada em str|
	# =======================================
	.data
		Frase: .string %str
	.text
		li a7, 4
		la a0, Frase
		ecall
.end_macro


.macro print_char(%rg)
	# =========================================
	# |Imprime caractere contido no registrador|
	# =========================================
	li a7, 11
	mv a0, %rg 
	ecall
.end_macro


.macro cmpi(%operando, %p1, %p2, %desvio) 
	# =============================
	# |Comparação com inteiro|
	# Operando: instrução.
	# P2: inteiro.
	# P1: registrador.
	# Desvio: Rotulo de desvio.
	# =============================
	li t0, %p2 
	%operando, %p1, t0, %desvio
.end_macro


.macro strtol(%ptr, %reg) 
	# =======================================================
	# |Converte string em inteiro|
	# ptr contem a string
	# reg contem aonde vai ser armazenado o inteiro
	# Nao utilizar o macro com registradores acima de t2
	# =======================================================
	
	# Inicializa variavel
	li t5, 32 # Espaco
	li t4, 0 # Null
	li t6, 10 
	start:
		# Recebe a string
		lbu t3, 0(%ptr)
		
		# Testa se o t3 == '/0' ou ' ' 	
		beqz t3, return
		beq t3, t5, search
		beq t3, t6, search
	
		# Adiciona e converte t3
		mul t4, t4, t6
		add t4, t4, t3
		addi t4, t4, -48
	
		# Avanca string
		addi %ptr,%ptr,1
		j start
	
	# Proximo index que nao seja um espaco
	search:
		addi %ptr,%ptr,1
		lbu t3, 0(%ptr)
		beq t3, t5, search
		beq t3, t6, search
	return:	
		mv %reg ,t4
.end_macro


.macro atualiza_record(%tiros, %acertados, %afundados)
	# ===========================================================================
	# Atualiza o record (relação entre menor numero de tiros e navios afundados)
     # ============================================================================
	

	la t0, record
	sw %tiros, 0(t0)
	sw %acertados, 4(t0)
	sw %afundados, 8(t0)
.end_macro

.macro atualiza_info_jogador(%jogador, %tiros, %acertados, %afundados, %ultima_linha, %ultima_coluna)
	# =======================================================
	# Atualiza a 
	mv t0, %jogador
	lw t1, 0(t0)
	lw t2, 4(t0)
	lw t3, 8(t0)
	
	addi t1, t1, %tiros
	addi t2, t2, %acertados
	addi t3, t3, %afundados
	
	sw t1, 0(t0)
	sw t2, 4(t0)
	sw t3, 8(t0)
	sw %ultima_linha, 12(t0)
	sw %ultima_coluna, 16(t0)
	

.end_macro
 
j prepara_principal

preenche:
	# ==================================
	# Funcao preenche a matriz do jogo
	# a0 Recebe endereço da matriz
	# ==================================
	li s0, 0 # Linha
	li s1, 0 # Coluna
	li s11, 0 # Quantas embarcacoes foram inseridas
	linha_preenche:
		cmpi(bge, s0, 10, fim_preenche)
		coluna_preenche:
			cmpi(bge, s1,10, coluna_preenche_branch)
			mv t6, a0 # Carrega o endereço das embarcacoes	
			li t0, 10 # Quantidade de colunas
			li t1, 4 # 4Bytes
			mul t3, s0, t0 # Offset linha
			add t3, t3, s1 # Offset coluna e linha
			mul t3, t3, t1 # Offset em 4Bytes
			add t6, t6, t3 # Atualiza o endereço com o offset
			li t1, 126 # ~ em ASCII
			sw t1, 0(t6) # Preenche ~ na matriz
			addi s1, s1, 1 # Atualiza o segundo contador
			
			j coluna_preenche
			coluna_preenche_branch:
				addi s0, s0, 1 # Atualiza o primeiro contador
				li s1, 0 # Reseta o segundo contador
				j linha_preenche
	fim_preenche:
		ret 
		
		
verifica_posicao:
	# =============================================================
	# Funcao que verifica se as dimensões extrapolam o tabuleiro
	# a0 recebe a linha
	# a1 recebe a coluna
	# retorna 0 caso falso, 1 caso verdadeiro em a0 
	# =============================================================
	cmpi(bge a0, 10, posicao_erro_func) # Verifica se a linha é maior que 9
	blt a0, zero, posicao_erro_func # Verifica se a linha é menor que 0
	cmpi(bge a1, 10, posicao_erro_func) # Verifica se a coluna é maior que 9
	blt a1, zero, posicao_erro_func #Verifica se a coluna é menor que 0
	j verifica_pos_true
	posicao_erro_func:
		li a0, 0 # False
		ret
	verifica_pos_true:
		li a0, 1
		ret
	

insere_embarcacoes:
	# ===============================================================
	#
	# Função que insere navios no Jogo
	# --------------
	# Entradas
	#
	# a0 (0) => Escolhe a Inserção dinâmica
	# a0 (-1) => Escolhe a Inserção padrão
	# a0 (1) => Escolhe a Inserção bônus
	# a1 (necessário somente quando a0 = 1 ou a0 = -1) => string de inserção 
	# a2 recebe por parametro a quantidade de navios ja inseridos.
	# --------------
	# 
	# Saídas
	#
	# a0 retorna a quantidade de barcos inseridos
	#
	# ===============================================================
	
	mv s11, a2 # Carrega a quantidade salva em s11
	mv sp, a0 # Salva o tipo de inserção em sp
	
	bltz a0, pula_leitura_str # Verifica se a entrada é do tipo padrão
	bnez a0, insere_estatico # Verifica se a entrada é do tipo bonus
	
	print_str("Quantidade de insercoes:")
	read_str(t0) # Lê a string e retorna o endereço
	j atribui_contador_inserir
	pula_leitura_str:
		mv t0, a1 # Move a string para t0
	atribui_contador_inserir:
	strtol(t0,s9) # Converte a string para inteiro
	mv a1, t0 # a1 Contem a string sem a quantidade de repetições (necessario para o tipo padrão)
	print_str("\n")
	li s10, 0 # Contador
	blez s9, fim_while # Verifica se a quantidade informada é maior que zero
	bltz sp, insere_estatico
	while_insere_embarcacoes: # O loop só usado para inserção padrão e dinamica.
		bge s10, s9, fim_while
		bltz sp, insere_estatico # Pula se for do tipo padrão
		print_str("--------------------------------------------------\n")
		print_str("Horizontal / Vertical | Tamanho | Linha | Coluna |\n")
		print_str("    0     /    1      |   1-10  |  0-9  |   0-9  |\n")
		print_str("--------------------------------------------------\n")
		read_str(t1) # Lê string e retorna o endereço
		j insere_verificacao
		insere_estatico:
			mv t1, a1 # Salva a string em t1 até aonde foi lida.
		insere_verificacao:
			strtol(t1, s5) # Horizontal ou vertical
			strtol(t1, s6) # Tamanho
			strtol(t1, s7) # Linha
			strtol(t1, s8) # Coluna
			mv t6, t1 # Salva 
			mv a0, s7 # Prepara Linha para funcao
			mv a1, s8 # Prepara Coluna para funcao
			mv t5 ,ra # Salva o valor de retorno em t5
			call verifica_posicao
			mv ra, t5 # Corrige o valor de retorno
			mv t1, a0 # Passa o valor da funcao para t1
		bltz sp, avanca_str_inserir
		j comeca_verificacao
		avanca_str_inserir:
			mv a1, t6
		comeca_verificacao:
			beqz t1, posicao_erro # Se nao for igual a zero
		verifica_tamanho:
			ble s6, zero, tamanho_erro
			beq s5, zero, verifica_tamanho_vertical # Verifica se é Horizontal ou vertical
			add t1, s7, s6 # Soma linha com o tamanho
			cmpi(bge, t1, 11, tamanho_erro) # Verifica se extrapola o tamanho
			j verifica_sobreposicao
			verifica_tamanho_vertical:
				add t1, s8, s6 # Soma coluna com o tamanho
				cmpi(bge, t1, 11, tamanho_erro) # Verifica se extrapola o tamanho
		
		verifica_sobreposicao:
			li t1, 0 # Contador
			mv t5, s7 # Linha 
			mv t6, s8 # Coluna
			whille_verifica_sobreposicao:
				bge t1, s6, prepara_inserir # Verificacao do contador
				li t0, 4 # 4Bytes
				li t2, 10 # Quantidade de colunas
				la t3, navios_matriz # Carrega o endereco das embarcacoes	
				mul t2, t2, t5 # Offset linha
				add t2, t2, t6 # Offset linha com coluna
				mul t2, t2, t0 # Offset em 4Bytes
				add t3, t3, t2 # Atualiza o endereco
				lw t3, (t3) # Carrega o valor com endereco atualizado
				li t4, 126 # ~ em ASCII
				bne t4, t3, sobreposicao_erro # Verifica se ja foi preenchido
				beq zero, s5,  verifica_vertical_sobreposicao # Verifica se a insercao é vertical
				addi t5, t5, 1 # Adiciona 1 na linha
				addi t1, t1, 1 # Atualiza contador
				j whille_verifica_sobreposicao
				
				verifica_vertical_sobreposicao:
					addi t6, t6, 1 # Adiciona 1 na coluna
					addi t1, t1, 1 # Atualiza contador
					j whille_verifica_sobreposicao		
		
		prepara_inserir:
			li t4, 0 # Contador do inserir

		inserir:
			bge t4, s6, fim_inserir # Verifica o contador
			li t0, 4 # 4Bytes
			li t1, 10 # Quantidade de colunas
			la t2 , navios_matriz # Carrega o endereco das embarcacoes
			mul t3, s7, t1 # Offset linha
			add t3, t3, s8 # Offset linha com coluna
			mul t3, t3, t0 # Offset com 4Bytes
			add t2, t2, t3 # Atualiza o endereco
			li t6, 65 # Carrega o A em ASCII
			#add t5, s11, s10 # Quantas embarcacoes foram inseridas
			add t6, t6, s11 # Calcula qual caractere sera com base no contador
			sw t6, 0(t2) # Preenche o espaco com o caractere
			addi t4, t4, 1 # Atualiza Contador
			beq s5, zero, vertical # Verifica se é vertical
			addi s7, s7, 1 # Se for horizontal atualiza linha
			j inserir
			vertical:
				addi s8, s8, 1 # Se for vertical atualiza coluna
				j inserir
			
		fim_inserir:
			print_str("Inserido!\n")
			addi s11, s11, 1 # Salva que foi inserido mais um
			la t0, comecou # Flag para saber se existe alguma embarcação
			li t1, 1
			sw t1, 0(t0) # Salva a Flag
			bltz sp, while_contador_adiciona_um
			bnez sp, fim_while # Se for inserção do tipo bonus, pular para o final do loop
			while_contador_adiciona_um: 
				addi s10, s10, 1 # Atualiza contador
				j while_insere_embarcacoes
			
		tamanho_erro:
			print_str("Tamanho nao suportado!!\n")
			beqz sp, while_contador_adiciona_um # Se nao for do tipo bonus
			j fim_while
			
			
		sobreposicao_erro:
			print_str("Essa posicao está invalida no momento!\n")
			beqz sp, while_contador_adiciona_um # Se nao for do tipo bonus
			j fim_while
		
		posicao_erro:
			print_str("Posição invalida!\n")
			beqz sp, while_contador_adiciona_um # Se nao for do tipo bonus
			j fim_while
			
		

	fim_while:
		mv a0, s11 # Carrega a quantidade de inserções em a0 e retorna
		ret
		
	
imprime:
	# =====================================
	# Funcao que imprime os navios do jogo
	# a0 Endereço Matriz
	# =====================================
	li s0, 0 # Linha
	li s1, 0 # Coluna
	mv a1, a0 # A1 Recebe o endereço de A0, pois vai ser utilizado nas ecall
	print_str("   0  1  2  3  4  5  6  7  8  9\n")
	linha_imprime:
		cmpi(bge, s0, 10, fim_imprime) # Verifica contador linha
		print_int(s0)
		print_str("  ")
		coluna_imprime:
			cmpi(bge, s1, 10, coluna_imprime_branch) # Verifica contador coluna
			mv t6, a1 # Carrega endereco embarcacoes
			li t0, 10 # Quantidade de colunas
			li t1, 4 # 4Bytes
			mul t3, s0, t0 # Offset linha
			add t3, t3, s1 # Offset linha com coluna
			mul t3, t3, t1 # Offset em 4Bytes
			add t6, t6, t3 # Atualiza endereco
			lw t0, 0(t6) # Carrega caractere
			print_char(t0) # Imprime caractere
			print_str("  ") 
			addi s1, s1, 1 # Atualiza contador coluna
			j coluna_imprime
			
			coluna_imprime_branch:
				print_int(s0)
				addi s0, s0, 1 # Atualiza contador linha
				print_str("\n") 
				li s1, 0  # Zera contador coluna
				j linha_imprime
	fim_imprime:
		print_str("   0  1  2  3  4  5  6  7  8  9\n")
		ret

efetuar_disparos:
	# ===========================================================
	# Essa função efetua disparos nas embarcações.
	# O simbolo '*' significa que tiro errou a embarcação
	# O simbolo '#' significa que o tiro acertou a embarcação
	# Ambos os simbolos são escrito nas duas matrizes. Matriz dos navios e Matriz de tiros (tabuleiro)
	# ===========================================================
	
	entrada_efetuar_disparos:
		print_str("Efetuar disparos\n")
		print_str("(Linha) (Coluna):\n")
		read_str(t1) # Le a string
		strtol(t1,s0) # Adiciona linha a s0
		strtol(t1,s1) # Adiciona coluna a s1
		
		# Verifica posicao
		mv a0, s0
		mv a1, s1
		mv t5, ra
		call verifica_posicao
		mv ra, t5
		mv t1, a0
		beqz t1, entrada_efetuar_disparos # Se o retorno for 0, repete
		# Fim verificacao
		
	disparos_verificar_alvo:
		la t5, tiros
		la t6, navios_matriz
		li t0, 10 # Quantidade de colunas
		li t1, 4 # 4Bytes
		mul t3, s0, t0 # Offset linha
		add t3, t3, s1 # Offset linha com coluna
		mul t3, t3, t1 # Offset em 4Bytes
		add t5, t5, t3 # Offset com o endereço dos tiros (tabuleiro)
		add t6, t6, t3 # Offset com o endereço dos navios_matriz
		lw t5, 0(t5) # Matriz Jogador
		lw t6, 0(t6) # Matriz Navios
		li t2, 126  # ~ em ASCII
		beq t5, t2, disparos_preenche_matrizes # Verifica se posicão ja foi disparada
		print_str("Posição invalida de disparo\n")
		j entrada_efetuar_disparos
	disparos_preenche_matrizes:
		bne t6, t2, disparos_acerta_embarcacao # Verifica se acertou uma embarcação 
		# Errou o tiro
		la t5, tiros
		la t6, navios_matriz
		add t5, t5, t3
		add t6, t6, t3 
		li t2, 42 # * ASCII
		# Preenche em ambas matrizes *
		sw t2, 0(t5) 
		sw t2, 0(t6)
		preenche_placar_erro:
			la t0, player_1
			atualiza_info_jogador(t0,1,0,0, s0,s1) # Adiciona + 1 nos tiros e ultimos disparos (s0, s1)
			ret
	disparos_acerta_embarcacao:
		la t5, tiros
		la t6, navios_matriz
		add t5, t5, t3
		add t6, t6, t3 
		li t2, 35 # # ASCII
		lw s7, 0(t6) # Salva caractere escrito
		sw t2, 0(t5)
		sw t2, 0(t6)
		
		preenche_placar_acerto:
		# Verifica se o tiro afundou uma embarcação
		# Compara o caractere salvo (s7) com toda a matriz de navios. 
		# Se nao achar outro caractere igual a s7: afundou
			mv s5, s0
			mv s6, s1
			li s0, 0 # Linha
			li s1, 0 # Coluna
			linha_afundou:
				cmpi(bge, s0, 10, fim_afundou) # Verifica contador linha
			coluna_afundou:
				cmpi(bge, s1, 10, coluna_afundou_branch) # Verifica contador coluna
				la t6, navios_matriz # Carrega endereco embarcacoes
				li t0, 10 # Quantidade de colunas
				li t1, 4 # 4Bytes
				mul t3, s0, t0 # Offset linha
				add t3, t3, s1 # Offset linha com coluna
				mul t3, t3, t1 # Offset em 4Bytes
				add t6, t6, t3 # Atualiza endereco
				lw t0, 0(t6) # Carrega caractere
				beq s7, t0, nao_afundou
				addi s1, s1, 1 # Atualiza contador coluna
				j coluna_afundou
			
			coluna_afundou_branch:
				addi s0, s0, 1 # Atualiza contador linha
				li s1, 0  # Zera contador coluna
				j linha_afundou
	fim_afundou:
		la t0, player_1
		atualiza_info_jogador(t0,1,1,1, s5,s6) # Atualiza o placar se afundou
		ret
	nao_afundou:
		la t0, player_1
		atualiza_info_jogador(t0,1,1,0, s5,s6) # Atualiza o placar se nao afundou
		ret
			

mostrar_placar_jogadores:
	# ==================================
	# Mostra Tiros, Acertos, Afundados e Ultimos Tiros do jogador
	# Mostra o Record de jogos anteriores
	# ==================================
	la s0, player_1
	la s1, record
	lw, t1, 0(s0)
	lw, t2, 0(s1)
	print_str("            |   Player 1   |   Recorde    |\n")
	print_str("------------|--------------|--------------|\n")
	print_str("Tiros       |      ")
	print_int(t1)
	print_str("       |      ")
	print_int(t2)
	print_str("       |\n")
	print_str("Acertos     |      ")
	
	lw, t1, 4(s0)
	lw, t2, 4(s1)
	
	print_int(t1)
	print_str("       |      ")
	print_int(t2)
	print_str("       |\n")
	print_str("Afundados   |      ")
	
	lw, t1, 8(s0)
	lw, t2, 8(s1)
	
	print_int(t1)
	print_str("       |      ")
	print_int(t2)
	print_str("       |\n")
	
	lw, t1, 12(s0)
	lw, t2, 16(s0)
	
	print_str("Ultimo Tiro |     ")
	print_int(t1)
	print_str(" ")
	print_int(t2)
	print_str("      |")
	print_str("--------------|\n------------|--------------|--------------|\n")
	ret
	

acabou_jogo:
	# ========================================================================
	# Funcao define se acabou o jogo
	# Verifica se encontra alguma embarcação entre 65 e 125 em ASCII
	# a0 retorna 1 para verdadeiro (comecou)
	# a0 retorna 0 para falso (nao terminou) 
	# a0 retorna -1 se nao comecou a partida
	# ========================================================================
	la t0, comecou
	lw t1, 0(t0)
	beqz t1, ainda_nao_comecou
	li s0, 0 # Linha
	li s1, 0 # Coluna
	linha_acabou_jogo:
		cmpi(bge, s0, 10, fim_acabou_jogo)
		coluna_acabou_jogo:
			cmpi(bge, s1,10, coluna_acabou_jogo_branch)
			la t6, navios_matriz # Carrega o endereço das embarcacoes	
			li t0, 10 # Quantidade de colunas
			li t1, 4 # 4Bytes
			mul t3, s0, t0 # Offset linha
			add t3, t3, s1 # Offset coluna e linha
			mul t3, t3, t1 # Offset em 4Bytes
			add t6, t6, t3 # Atualiza o endereço com o offset	
			lw t3, 0(t6) # Carrega a posição da matriz
			cmpi(bge, t3, 65, procura_fim_jogo)
			j atualiza_contador_fim_jogo
			procura_fim_jogo:
			cmpi(ble t3, 125, ainda_nao_acabou_jogo)
			
			atualiza_contador_fim_jogo:
			addi s1, s1, 1 # Atualiza o segundo contador
			
			j coluna_acabou_jogo
			coluna_acabou_jogo_branch:
				addi s0, s0, 1 # Atualiza o primeiro contador
				li s1, 0 # Reseta o segundo contador
				j linha_acabou_jogo
	fim_acabou_jogo:
		li a0, 1
		ret 
	ainda_nao_acabou_jogo:
		li a0, 0
		ret
	ainda_nao_comecou:
		print_str("O jogo ainda nao possui embarcações\n")
		li a0, -1
		ret
	
	
prepara_principal:
	# ================================================================
	# Prepara valores e embarcações estaticas (.data) para o jogo
	# ================================================================

	la a0, navios_matriz
	call preenche
	la a0, tiros
	call preenche
	la t0, record
	sw zero, 12(t0)
	
	la t0, navios
	li a0, -1
	mv a1, t0
	mv a2, s11 # Carrega quantas embarcacoes foram inseridas
	call insere_embarcacoes
	mv s11, a0 # Salva quantas embarcacoes foram inseridas
	
	###########
	la t0, navio_estatico_1
	li a0, 1
	mv a1, t0
	mv a2, s11 # Carrega quantas embarcacoes foram inseridas
	call insere_embarcacoes
	mv s11, a0 # Salva quantas embarcacoes foram inseridas
	
	la t0, navio_estatico_2
	li a0, 1
	mv a1, t0
	mv a2, s11 # Carrega quantas embarcacoes foram inseridas
	call insere_embarcacoes
	mv s11, a0 # Salva quantas embarcacoes foram inseridas
	
	la t0, navio_estatico_3
	li a0, 1
	mv a1, t0
	mv a2, s11 # Carrega quantas embarcacoes foram inseridas
	call insere_embarcacoes
	mv s11, a0 # Salva quantas embarcacoes foram inseridas
	j principal
	

principal:
	print_str("|Menu Principal|\n(1)Inserir\n(2)Imprimir Navios\n(3)Imprimir Tabuleiro\n(4)Efetuar Disparos\n(5)Mostrar Placar\n(8)Zerar Valores\n(9)Sair\nOpcao:")
	read_str(t0)
	strtol(t0, t1)
	print_str("\n")
	cmpi(beq, t1, 1, ir_inserir)
	cmpi(beq, t1, 2, ir_imprimir)
	cmpi(beq, t1, 3, ir_imprimir_jogador)
	cmpi(beq, t1, 4, ir_tiros)
	cmpi(beq, t1, 5, ir_placar_jogadores)
	cmpi(beq, t1, 8, ir_zerar)
	cmpi(beq, t1, 9, sair)
	j principal
	ir_zerar: # Zera o placar do player matrizes. Nao insere novamente os navios estaticos (.data) 
		la a0, navios_matriz
		call preenche
		print_str("Jogo Resetado!\n")
		la a0, tiros
		call preenche
		la t0, comecou
		sw zero, 0(t0)
		la t0, player_1
		sw zero, 0(t0)
		sw zero, 4(t0)
		sw zero, 8(t0)
		sw zero, 12(t0)
		sw zero, 16(t0)
		j principal
	
	ir_inserir: # Prepara para inserir
		li a0, 0 # Inserção dinamica
		mv a2, s11 # Carrega quantas embarcacoes foram inseridas
		call insere_embarcacoes
		mv s11, a0 # Salva quantas embarcacoes foram inseridas
		j principal
	ir_imprimir:
		la a0, navios_matriz
		call imprime
		j principal
		
	ir_imprimir_jogador:
		la a0, tiros
		call imprime
		j principal
	
	ir_tiros:
		call acabou_jogo # Antes de jogar, verifica se o jogo possui embarcações.
		mv t1, a0
		beqz t1, pode_jogar
		j nao_pode_jogar
		pode_jogar:
			la a0, tiros
			call imprime
			call efetuar_disparos
			call acabou_jogo
			mv t1, a0
			bnez t1, final_de_jogo
			j principal
		nao_pode_jogar:
			bltz t1, principal
		final_de_jogo:
			print_str("O jogo acabou!\n")	
			la t0, player_1
			la t3, record
			lw t1, 0(t0) # Tiros Player
			lw t2, 8(t0) # Afundados Player
			lw t4, 0(t3) # Tiros Record
			lw t5, 8(t3) # Afundados Record
			lw t6, 12(t3) # Flag se ja foi salvo alguma vez. Usado na primeira partida para definir o recorde
			beqz t6, atualiza_afundados_record
			ble t1, t4, atualiza_tiros_record # Verifica se os tiros do player foram menor que o recorde
			atualiza_tiros_record:
			bge t2, t5, atualiza_afundados_record # Verifica tambem se houve a mesma quantidade ou maior de afundados
			j ir_zerar
			atualiza_afundados_record:
			lw t3, 4(t0)
			li t4, 1
			sw t4, 12(t0)
			atualiza_record(t1,t3, t2)
			j ir_zerar
		
	 ir_placar_jogadores:
	 	call mostrar_placar_jogadores
	 	j principal
		
		
	sair:
		print_str("Saindo....")
