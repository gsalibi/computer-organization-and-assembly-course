@       Tarefa 07
@ Gustavo Henrique Storti Salibi
@ RA: 174135

.global _start
          .org 0x1000
_start:

@ ********
@ linhas
@ ********
linhas: 
    ldrb  r1, [r0]      @ carrega byte da posição atual da cadeia de caracteres
    add   r0, #1        @ incrementa posição atual da cadeia de caracteres
    cmp   r1, #0        @ verifica se byte atual é 0
    beq   final         @ se for, a cadeia terminou
    cmp   r1, #0x0a     @ compara byte da posição atual com final de linha
    addeq r2, #1        @ se for, adiciona 1 ao contador de finais de linhas
    b     linhas        @ recomeça o loop
final:
    mov r0, r2          @ atribui quantidade de caracteres encontrados a r0

@ syscall exit(int status)
    mov   r7, #1        @ exit is syscall #1
    swi   #0x55         @ invoke syscall 
