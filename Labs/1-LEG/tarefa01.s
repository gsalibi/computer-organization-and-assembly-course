@ Gustavo Henrique Storti Salibi
@ RA: 174135

@ define os valores do intervalo
MAXVAL	.equ 100
MINVAL	.equ -100

@ reserva memória para as variáveis utilizadas no programa
sequencia:	.skip 400 	@ reserva espaço para a sequencia de inteiros
compr:		.skip 4
resultado:	.skip 4

inicio:
@ inicializa as variáveis com 0
	set r3, 0			@ utiliza r3 como ponteiro para percorrer sequência
	set r0, 0			@ r0 representa o valor de i
	st resultado, r0

@ início do laço for
teste_for:	@ verifica se o laço pode continuar
	ld r5, compr
	cmp r0, r5
	jge final_for		@ se r5 >= compr, finaliza laço

corpo_for:
add r0, 1 @incrementa contador
@ verifica se o elemento atende às condições necessárias
if:	
	@ se elemento da sequência >= -100
	ld r1, [r3]
	set r2, MINVAL
	cmp r1, r2
	jl reinicia_for
	
	@ se elemento da sequência <= 100
	set r2, MAXVAL
	cmp r1, r2
	jg reinicia_for
	
	@ incrementa quantidade de elementos válidos
	ld r4, resultado
	add r4, 1	
	st resultado, r4

reinicia_for:
	@ atualiza posicao atual da sequência
	add r3, 4			@ incrementa ponteiro no tamanho de um int
	jmp teste_for		@ fim do bloco, volta ao início do laço

final_for:
	hlt







