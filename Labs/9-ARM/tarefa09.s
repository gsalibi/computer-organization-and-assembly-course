@       Tarefa 09
@ Gustavo Henrique Storti Salibi
@ RA: 174135

.global _start
@ constantes
    .equ PARADA,    0xa0000
    .equ CHEGOU_A,  0xa0001
    .equ PARTIU_A,  0xa0002
    .equ CHEGOU_B,  0xa0003
    .equ PARTIU_B,  0xa0004
    .equ CHEGOU_C,  0xa0005
    .equ PARTIU_C,  0xa0006
    .set STACK,     0x80000

@ vetores com cadeias de caracteres a serem lidas
prox_A:
.ascii "\n\nproxima parada: A"      @ 19 caracteres
prox_B:
.ascii "\n\nproxima parada: B"      @ 19 caracteres
prox_C:
.ascii "\n\nproxima parada: C"      @ 19 caracteres
parada_solicitada:
.ascii " - Parada solicitada"       @ 20 caracteres
chegada_A:
.ascii "\n\nEsta eh a parada A"     @ 20 caracteres
chegada_B:
.ascii "\n\nEsta eh a parada B"     @ 20 caracteres
chegada_C:
.ascii "\n\nEsta eh a parada C"     @ 20 caracteres

    .org 0x1000
_start:
    mov   sp, #STACK                @ pilha do usuário no final da memória 

estado1:
    cmp   r11, #1                   @ verifica se verificador de parada está ativo
    bleq  parada_A                  @ caso esteja, desvia para tratar
    cmp r12, #1                     @ verifica se botão já foi apertado
    beq partida_A                   @ se sim, parte de A
aguarda_partida_A:
    ldr   r8, =PARTIU_A             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_partida_A         @ caso nao, aguarda
partida_A:
    mov   r12, #0                   @ desativa verificador
    mov   r0, #1                    @ seta r0 com 1
    mov   r7, #4                    @ seta r7 com 4
    ldr   r1, =prox_B               @ carrega r1 com frase da próxima parada 
    mov   r2, #19                   @ seta r2 com número de caracteres
    svc   0x55                      @ executa chamada
aguarda_B:    
    ldr   r8, =PARADA               @ carrega endereço do botão Parada
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bleq  parada_sol                @ se parada foi solicitada, desvia para tratar
    ldr   r8, =CHEGOU_B             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_B                 @ caso nao, aguarda
estado2:
    cmp   r11, #1                   @ verifica se verificador de parada está ativo
    bleq  parada_B                  @ caso esteja, desvia para tratar
    cmp r12, #1                     @ verifica se botão já foi apertado
    beq partida_B                   @ se sim, parte de B
aguarda_partida_B:
    ldr   r8, =PARTIU_B             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_partida_B         @ caso nao, aguarda
partida_B:
    mov   r12, #0                   @ desativa verificador
    mov   r0, #1                    @ seta r0 com 1 
    mov   r7, #4                    @ seta r7 com 4 
    ldr   r1, =prox_C               @ carrega frase da próxima parada 
    mov   r2, #19                   @ seta r2 com número de caracteres 
    svc   0x55                      @ executa chamada
aguarda_C:    
    ldr   r8, =PARADA               @ carrega endereço do botão Parada
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bleq  parada_sol                @ se parada foi solicitada, desvia para tratar
    ldr   r8, =CHEGOU_C             @ carrega endereço do botão Chegou_em_C
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_C                 @ caso nao, aguarda
estado3:
    cmp   r11, #1                   @ verifica se verificador de parada está ativo
    bleq  parada_C                  @ caso esteja, desvia para tratar
    cmp r12, #1                     @ verifica se botão já foi apertado
    beq partida_C                   @ se sim, parte de C
aguarda_partida_C:
    ldr   r8, =PARTIU_C             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_partida_C         @ caso nao, aguarda
partida_C:
    mov   r12, #0                   @ desativa verificador
    mov   r0, #1                    @ seta r0 com 1 
    mov   r7, #4                    @ seta r7 com 4 
    ldr   r1, =prox_A               @ carrega frase da próxima parada 
    mov   r2, #19                   @ seta r2 com número de caracteres 
    svc   0x55                      @ executa chamada
aguarda_A:    
    ldr   r8, =PARADA               @ carrega endereço do botão Parada
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bleq  parada_sol                @ se parada foi solicitada, desvia para tratar
    ldr   r8, =CHEGOU_A             @ carrega endereço do botão Chegou_em_A
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_A                 @ caso nao, aguarda
    b     estado1                   @ recomeça loop

@ ********
@ parada_sol
@ ********
parada_sol:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov   r0, #1                    @ seta r0 com 1
    ldr   r1, =parada_solicitada    @ carrega em r1 o endereço da string
    mov   r2, #20                   @ seta r2 com número de caracteres 
    mov   r7, #4                    @ seta r7 com 4 
    svc   0x55                      @ executa chamada
    mov   r11, #1                   @ ativa verificador
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ parada_A
@ ********
parada_A:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov   r0, #1                    @ seta r0 com 1
    ldr   r1, =chegada_A            @ carrega endereço da frase de chegada em A
    mov   r2, #20                   @ seta r2 com número de caracteres 
    mov   r7, #4                    @ seta r7 com 4 
    svc   0x55                      @ executa chamada
    mov   r11, #0                   @ seta verificador de parada com valor 0 para desativá-lo
    ldr   r8, =PARTIU_A             @ carrega endereço do botão PARTIU_de_A
    mov   r12, #1
aguarda_saida_A:
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_saida_A           @ caso não, recomeça loop
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ parada_B
@ ********
parada_B:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov   r0, #1                    @ seta r0 com 1 
    ldr   r1, =chegada_B            @ carrega endereço da frase de chegada em A
    mov   r2, #20                   @ seta r2 com número de caracteres  
    mov   r7, #4                    @ seta r7 com 4 
    svc   0x55                      @ executa chamada 
    mov   r11, #0                   @ seta verificador de parada com valor 0 para desativá-lo
    ldr   r8, =PARTIU_B             @ carrega endereço do botão PARTIU_de_A
    mov   r12, #1
aguarda_saida_B:
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_saida_B           @ caso não, recomeça loop
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ parada_C
@ ********
parada_C:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov   r0, #1                    @ seta r0 com 1 
    ldr   r1, =chegada_C            @ carrega endereço da frase de chegada em A
    mov   r2, #20                   @ seta r2 com número de caracteres
    mov   r7, #4                    @ seta r7 com 4 
    svc   0x55                      @ executa chamada 
    mov   r11, #0                   @ seta verificador de parada com valor 0 para desativá-lo
    ldr   r8, =PARTIU_C             @ carrega endereço do botão PARTIU_de_A
    mov   r12, #1
aguarda_saida_C:
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_saida_C           @ caso não, recomeça loop
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

