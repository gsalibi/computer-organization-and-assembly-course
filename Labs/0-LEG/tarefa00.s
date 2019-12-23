@ Gustavo Henrique Storti Salibi
@ RA: 174135

	.org 0x100 @ avança para a posição adequada das variaveis
varA: .word 0x00 @ inicia cada variavel com um valor arbitrário
varB: .word 0x00 @ que será substituído pelo SuSy
varC: .word 0x00
	
	.org 0x200	@ avança para a posição onde o programa deve começar
start: 
	set r0, 0x1000 @ atribui o valor constante que deve ser somado
	
	ld r1, varA	@ carrega o primeiro valor a ser somado da memória
	ld r2, varB @ carrega o segundo valor a ser somado da memória
	ld r3, varC @ carrega o terceiro valor a ser somado da memória
	
	add r0, r1 @ soma, um por vez, os três valores das variáveis 
	add r0, r2 @ ao valor constante, mantendo sempre a soma 
	add r0, r3 @ atualizada em r0
	
	hlt
