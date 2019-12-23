@       Tarefa 10
@ Gustavo Henrique Storti Salibi
@ RA: 174135

.global _start
@ constantes
    .equ PARADA,             0xa0000
    .equ CHEGOU_A,           0xa0001
    .equ PARTIU_A,           0xa0002
    .equ CHEGOU_B,           0xa0003
    .equ PARTIU_B,           0xa0004
    .equ CHEGOU_C,           0xa0005
    .equ PARTIU_C,           0xa0006
    .set STACK,              0x80000
    .set ADISPLAY_DAT,       0x90001
    .set ADISPLAY_CMD,       0x90000
    .set LCD_CLEARDISPLAY,   0x01
    .set LCD_DISPLAYCONTROL, 0x08
    .set LCD_SETDDRAMADDR,   0x80
    .set LCD_BUSYFLAG,       0x80
    .set LCD_DISPLAYON,      0x04
    .set LCD_BLINKOFF,       0x00


@ vetores com cadeias de caracteres a serem lidas
prox_A:
.ascii "Proxima parada: A   "       @ 20 caracteres
prox_B:
.ascii "Proxima parada: B   "       @ 20 caracteres
prox_C:
.ascii "Proxima parada: C   "       @ 20 caracteres
parada_solicitada:
.ascii "Parada solicitada   "       @ 20 caracteres
chegada_A:
.ascii "Esta eh a parada A  "       @ 20 caracteres
chegada_B:
.ascii "Esta eh a parada B  "       @ 20 caracteres
chegada_C:
.ascii "Esta eh a parada C  "       @ 20 caracteres
linha_vazia:
.ascii "                    "       @ 20 caracteres

    .org 0x1000
_start:
    mov   sp, #STACK                @ pilha do usuário no final da memória 
	mov	  r3,#LCD_DISPLAYCONTROL+LCD_DISPLAYON+LCD_BLINKOFF 
    bl    wr_cmd                    @ escreve comando de iniciar no display
estado1:
    cmp   r11, #1                   @ verifica se verificador de parada está ativo
    bleq  parada_A                  @ caso esteja, desvia para tratar
    cmp   r12, #1                   @ verifica se botão já foi apertado
    beq   partida_A                 @ se sim, parte de A
aguarda_partida_A:
    ldr   r8, =PARTIU_A             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_partida_A         @ caso nao, aguarda
partida_A:
    mov   r12, #0                   @ desativa verificador
    mov	  r3,#LCD_CLEARDISPLAY      @ r3 tem comando: clear display
    bl    wr_cmd                    @ escreve comando no display
    ldr   r4, =prox_B               @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, primeira linha
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
    cmp   r12, #1                   @ verifica se botão já foi apertado
    beq   partida_B                 @ se sim, parte de B
aguarda_partida_B:
    ldr   r8, =PARTIU_B             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_partida_B         @ caso nao, aguarda
partida_B:
    mov	  r3,#LCD_CLEARDISPLAY      @ r3 tem comando: clear display
    bl    wr_cmd                    @ escreve comando no display
    mov   r12, #0                   @ desativa verificador
    ldr   r4, =prox_C               @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, primeira linha
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
    cmp   r12, #1                   @ verifica se botão já foi apertado
    beq   partida_C                 @ se sim, parte de C
aguarda_partida_C:
    ldr   r8, =PARTIU_C             @ carrega endereço do botão Chegou_em_B
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_partida_C         @ caso nao, aguarda
partida_C:
    mov   r12, #0                   @ desativa verificador
    mov	  r3,#LCD_CLEARDISPLAY      @ r3 tem comando: clear display
    bl    wr_cmd                    @ escreve comando no display
    ldr   r4, =prox_A               @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, primeira linha
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
@ wr_cmd - escreve comando em r3 no display
@ ********
wr_cmd:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    ldr	  r6,=ADISPLAY_CMD          @ r6 tem porta display
    ldrb  r5,[r6]                   @ carrega BF
    tst   r5,#LCD_BUSYFLAG          @ verifica BF
    beq	  wr_cmd                    @ espera BF ser 1
    strb  r3,[r6]                   @ escreve comando no display
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ wr_dat - escreve dado em r0 no display
@ ********
wr_dat:
    ldr	  r6,=ADISPLAY_CMD          @ r6 tem porta display
    ldrb  r5,[r6]                   @ lê flag BF
    tst   r5,#LCD_BUSYFLAG          @ verifica BF
    beq	  wr_dat                    @ espera BF ser 1
    ldr   r6,=ADISPLAY_DAT          @ r6 tem porta display
    strb  r0,[r6]                   @ grava saída na porta display
    bx    lr                        @ retorna

@ ********
@ write_msg - escreve cadeia de caracteres apontada por r4
@ ********
write_msg:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov	r1, #20                     @ tamanho da cadeia
write_msg1:
    ldrb  r0,[r4]                   @ caractere a ser escrito
    bl    wr_dat                    @ escreve caractere
    add   r4,#1                     @ avança contador
    sub   r1,#1                     @ decrementa contador
    cmp   r1,#0                     @ verifica se todos os caracteres foram lidos
    bne   write_msg1                @ caso não, lê o próximo
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ parada_sol
@ ********
parada_sol:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov	  r3,#(LCD_SETDDRAMADDR+64) @ coloca cursor na segunda linha
    bl    wr_cmd                    @ escreve comando no display
    ldr   r4, =parada_solicitada    @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, segunda linha
    mov	  r3,#(LCD_SETDDRAMADDR+0)  @ coloca cursor na primeira linha
    bl    wr_cmd                    @ escreve comando no display
    mov   r11, #1                   @ ativa verificador
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ parada_A
@ ********
parada_A:
    stmfd sp!,{r0-r10, r14}         @ salva registradores na pilha
    mov	  r3,#LCD_CLEARDISPLAY      @ r3 tem comando: clear display
    bl    wr_cmd                    @ escreve comando no display
    ldr   r4, =chegada_A            @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, primeira linha
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
    mov	  r3,#LCD_CLEARDISPLAY      @ r3 tem comando: clear display
    bl    wr_cmd                    @ escreve comando no display
    ldr   r4, =chegada_B            @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, primeira linha
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
    mov	  r3,#LCD_CLEARDISPLAY      @ r3 tem comando: clear display
    bl    wr_cmd                    @ escreve comando no display
    ldr   r4, =chegada_C            @ carrega mensagem a ser escrita
    bl    write_msg                 @ escreve mensagem no display, primeira linha
    mov   r11, #0                   @ seta verificador de parada com valor 0 para desativá-lo
    ldr   r8, =PARTIU_C             @ carrega endereço do botão PARTIU_de_A
    mov   r12, #1
aguarda_saida_C:
    ldr   r9, [r8]                  @ carrega valor atual do botão
    cmp   r9, #1                    @ verifica se o botão foi pressionado
    bne   aguarda_saida_C           @ caso não, recomeça loop
    ldmfd sp!,{r0-r10, r14}         @ desempilha registradores
    bx    lr                        @ retorna

