@       Tarefa 05
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

@ vetor de interrupções
    .org INT_TIMER*4
    .word trata_int_timer

@ espaço para vetor de interrupções
    .org 0x400

@ variaveis
intervalo:
	.skip 4

@ ********
@ trata_int_timer
@ ********
trata_int_timer:
    call muda_semaforos     @ altera estado dos semafóros
    iret                    @ retorna


@ ********
@ muda_semaforos
@ ********
muda_semaforos:
    cmp  r3, ESTADO_1       @ verifica se é estado 1
    jnz  est_2              @ se não for, verifica o próximo
    set  r1, VERDE          @ valor da rua1
    set  r2, VERMELHO       @ valor da rua2
    set  r3, ESTADO_2       @ próximo estado
    set  r4, CRESCENTE      @ estados aumentam
    jmp  altera             @ altera configuração do semáforo

est_2:
    cmp  r3, ESTADO_2       @ verifica se é estado 2
    jnz  est_3              @ se não for, verifica o próximo
    set  r1, AMARELO        @ valor da rua1
    set  r2, AMARELO        @ valor da rua2
    cmp  r4, CRESCENTE      @ verifica se estado é crescente
    jnz  decres             @ se não, é decrescente
    set  r3, ESTADO_3       @ próximo estado é maior
    jmp  conf_est           @ pula para configurar estado
decres:
    set  r3, ESTADO_1       @ se for decrescente, próximo estado é menor
conf_est:
    jmp  altera             @ altera configuração do semáforo

est_3:
    set  r1, VERMELHO       @ valor da rua1
    set  r2, VERDE          @ valor da rua2
    set  r3, ESTADO_2       @ próximo estado    
    set  r4, DECRESCENTE    @ estados diminuem
altera:                 
    outb RUA_1, r1          @ altera configuração da rua1
    outb RUA_2, r2          @ altera configuração da rua2
    ret

@ ********
@ inicio
@ ********
inicio:
    set  sp, INI_PILHA      @ posiciona ponteiro sp na posição correta
    set  r3, ESTADO_1       @ valor inicial do estado é 
    call muda_semaforos     @ configura semaforos com o valor inicial
    sti                     @ habilita interrupções
    ld r0, intervalo        @ carrega valor de intervalo
    outb TIMER, r0          @ determina valor de intervalo
aguarda_int:                @ aguarda interrupção, assim como aconteceria se houvessem outras tarefas
    jz aguarda_int              	
