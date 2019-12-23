@           LAB 2 
@   Gustavo Henrique Storti Salibi
@   RA: 174135

@ aloca espaço para as variáveis
divisor:    .skip 4
num_elem:   .skip 4
vetor:      .skip 64*2

inicio:
    set r1, vetor       @ posição do início do vetor
    ld r2, num_elem     @ carrega número de elementos
    ld r3, divisor      @ carrega valor do divisor
    set r4, 0           @ zera contador
    set r0, 0           @ zera valor total da soma

loop:
    cmp r2, r4          @ se contador é maior que número de elementos, finaliza loop
    jna fim_loop

    ld r10, [r1]        @ carrega valor da posiçao atual do vetor
    ld r11, [r1+2]      @ carrega valor correspondente ao elemento seguinte

    shl r10, 16	        @ descarta bits que não correspondem ao elemento
    sar r10, 16	        @ corrige posição do elemento na palavra
    shl r11, 16	        @ descarta bits desnecessários do segundo elemento
    sar r11, 16	        @ corrige posição do segundo elemento

    cmp r3, 2           @ verifica qual a divisão adequada
    jz divisao_2
    cmp r3, 4
    jz divisao_4
    jmp divisao_8

divisao_2: 
    sar r10, 1          @ desloca o primeiro elemento mantendo o sinal
    sar r11, 1          @ desloca o segundo elemento mantendo o sinal
    jmp soma
divisao_4:
    sar r10, 2          @ desloca o primeiro elemento mantendo o sinal
    sar r11, 2          @ desloca o segundo elemento mantendo o sinal
    jmp soma
divisao_8:
    sar r10, 3          @ desloca o primeiro elemento mantendo o sinal
    sar r11, 3          @ desloca o segundo elemento mantendo o sinal	
	
soma:
    add r0, r10         @ soma valor da divisão do primeiro elemento ao total
    add r0, r11         @ soma valor da divisão do segundo elemento ao total


    add r4, 2           @ incrementa contador
    add r1, 4           @ incrementa índice do vetor

    jmp loop            @ retorna ao início do laço

fim_loop:

    hlt
