@       Tarefa 06
@ Gustavo Henrique Storti Salibi
@ RA: 174135

@ constantes
    VERDE       .equ 0x01
    AMARELO     .equ 0x02
    VERMELHO    .equ 0x04
    TIMER       .equ 0x50
    RUA_1       .equ 0x90
    RUA_2       .equ 0x91 
    ESTADO_1    .equ 0x01 
    ESTADO_2    .equ 0x02 
    ESTADO_3    .equ 0x03
    CRESCENTE   .equ 0x01
    DECRESCENTE .equ 0x00
    INT_TIMER   .equ 0x10
    INI_PILHA   .equ 0x80000
    MENOS_SIG   .equ 0x40       
    MAIS_SIG    .equ 0x41       
    INTERVALO   .equ 1000  

@ vetor de interrupções
    .org INT_TIMER*4
    .word trata_int_timer

@ espaço para vetor de interrupções
    .org 0x400

@ tabela com valores do mostrador de sete segmentos em ordem crescente
tabela:
    .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47

@ ********
@ trata_int_timer
@ ********
trata_int_timer:
    cmp r5, 0                   @ verifica se registrador verificador da chamada inicial é igual a zero
    jnz chamada_comum           @ se não, desvia para uma chamada comum (não a primeira)
    set r5, 1                   @ marca que a primeira chamada já foi feita
    set r3, ESTADO_1            @ seta valor inicial do estado
    set r11, 0                  @ valor inicial do mostrador menos significativo
    set r12, 3                  @ valor inicial do mostrador mais significativo
    call muda_semaforos         @ configura semaforos com o valor inicial
    call atualiza_mostradores   @ coloca valores iniciais nos mostradores
    iret                        @ retorna da primeira chamada
chamada_comum:
    call atualiza_estado        @ altera estado dos semafóros e dos mostradores
    iret                        @ retorna das demais chamadas

@ ********
@ atualiza_mostradores
@ ********
atualiza_mostradores:
    set r7, tabela              @ carrega endereço inicial da tabela 
    set r8, tabela              @ carrega endereço inicial da tabela 
    add r7, r11                 @ adiciona valor a ser exibido para alcançar o dígito correspondente
    add r8, r12                 @ adiciona valor a ser exibido para alcançar o dígito correspondente
    ldb r7, [r7]                @ carrega valor da tabela para mostrador do dígito menos significativo
    ldb r8, [r8]                @ carrega valor da tabela para mostrador do dígito mais significativo
    outb MAIS_SIG, r8           @ envia para o mostrador mais significativo
    outb MENOS_SIG, r7          @ envia para o mostrador menos significativo
    ret

@ ********
@ atualiza_estado
@ ********
atualiza_estado:
    cmp r12, 0                  @ verifica se o dígito mais significativo é 0
    jnz verifica_menos_sig      @ caso não seja, desvia para verificar o próximo
    cmp r11, 1                  @ verifica se o dígito menos significativo é 1
    jnz verifica_menos_sig      @ caso não seja, desvia para tratá-lo
    set r12, 3                  @ atribui valor 3 para resetar o mostrador mais significativo
    set r11, 0                  @ atribui valor 0 para resetar o mostrador menos significativo
    jmp verifica_mudanca        @ desvia para verificar se há mudanças a serem feitas no semaforo
verifica_menos_sig:            
    cmp r11, 0                  @ verifica se o dígito menos significativo é 0
    jnz dif_zero                @ caso não seja, desvia para tratar
    set r11, 9                  @ atribui valor 9 ao dígito menos significativo
    sub r12, 1                  @ subtrai 1 do dígito mais significativo
    jmp verifica_mudanca        @ desvia para verificar se há mudanças a serem feitas no semaforo
dif_zero:
    sub r11, 1                  @ subtrai 1 do dígito menos significativo
verifica_mudanca:
    cmp r12, 3                  @ verifica se dígito mais significativo é 3
    jnz verifica_amarelo        @ caso não seja, verifica se os semáforos devem ser amarelos
    call muda_semaforos         @ muda estado dos semáforos
    jmp fim                     @ desvia para finalizar alterações
verifica_amarelo:
    cmp r12, 0                  @ verifica se o dígito mais significativo é 0
    jnz fim                     @ caso não seja, desvia para finalizar alterações
    cmp r11, 5                  @ verifica se o dígito menos significativo é 5
    jnz fim                     @ caso não seja, desvia para finalizar alterações
    call muda_semaforos         @ muda estado dos semáforos 
fim:
    call atualiza_mostradores   @ atualiza os mostradores
    ret

@ ********
@ muda_semaforos
@ ********
muda_semaforos:
    cmp  r3, ESTADO_1           @ verifica se é estado 1
    jnz  est_2                  @ se não for, verifica o próximo
    set  r1, VERDE              @ valor da rua1
    set  r2, VERMELHO           @ valor da rua2
    set  r3, ESTADO_2           @ próximo estado
    set  r4, CRESCENTE          @ estados aumentam
    jmp  altera                 @ altera configuração do semáforo

est_2:
    cmp  r3, ESTADO_2           @ verifica se é estado 2
    jnz  est_3                  @ se não for, verifica o próximo
    set  r1, AMARELO            @ valor da rua1
    set  r2, AMARELO            @ valor da rua2
    cmp  r4, CRESCENTE          @ verifica se estado é crescente
    jnz  decres                 @ se não, é decrescente
    set  r3, ESTADO_3           @ próximo estado é maior
    jmp  conf_est               @ pula para configurar estado
decres:
    set  r3, ESTADO_1           @ se for decrescente, próximo estado é menor
conf_est:
    jmp  altera                 @ altera configuração do semáforo

est_3:
    set  r1, VERMELHO           @ valor da rua1
    set  r2, VERDE              @ valor da rua2
    set  r3, ESTADO_2           @ próximo estado    
    set  r4, DECRESCENTE        @ estados diminuem
altera:                 
    outb RUA_1, r1              @ altera configuração da rua1
    outb RUA_2, r2              @ altera configuração da rua2
    ret

@ ********
@ inicio
@ ********
inicio:
    set  sp, INI_PILHA          @ posiciona ponteiro sp na posição correta
    sti                         @ habilita interrupções
    set r0, INTERVALO           @ carrega valor do intervalo
    outb TIMER, r0              @ determina valor de intervalo
aguarda_int:
    jmp aguarda_int             @ enquanto não houver interrupção, recomeça o laço
