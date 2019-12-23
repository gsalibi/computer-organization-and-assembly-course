@       Tarefa 03
@ Gustavo Henrique Storti Salibi
@ RA: 174135

@ constantes
INICIO_PILHA .equ 0x8000
PARAR        .equ 10

@ tabela com valores do mostrador de sete segmentos em ordem crescente
tabela:
    .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47

@ ********
@ read
@ ********
read:
    TECL_DADO   .equ 0x80   @ porta de dados
    TECL_ESTADO .equ 0x81   @ porta de estado   
    set r2, 1               @ valor READY 
@ lê primiero byte
read1:
    inb r0, TECL_ESTADO     @ lê porta de estado
    tst r0, r2              @ dado pronto para ser lido?
    jz  read1               @ espera que dado esteja pronto
    inb r0, TECL_DADO       @ salva primeiro dígito lido
@ lê segundo byte
read2:
    inb r1, TECL_ESTADO     @ lê porta de estado
    tst r1, r2              @ dado pronto para ser lido?
    jz  read2               @ espera que dado esteja pronto
    inb r1, TECL_DADO       @ salva segundo dígito lido
    ret

@ ********
@ display
@ ********
display:
    MOSTRADOR .equ 0x40     @ porta de dados
    ldb r0, [r0]            @ carrega valor da tabela para mostrador de sete segmentos
    outb MOSTRADOR, r0      @ envia para o display
    ret

inicio:
    set sp, INICIO_PILHA    @ faz pilha apontar para o final da memória
    call display            @ inicia display com valor de r0 sendo 0
recebe_digito:
    call read               @ lê um digito em r0 e outro em r1
    add r3, r0              @ incrementa valor total com dígito lido
    mov r0, r3              @ copia valor total para o parâmetro do display
    call display            @ exibe resultado atual no display
    cmp r1, PARAR           @ verifica se o segundo dígito é o comando para parar
    jnz recebe_digito       @ recebe mais dois dígitos, caso não seja o comando de parada
    
    hlt
    

@ ********
@ verificar_senha (parametro r8, retorna em r3 se a senha é válida)
@ ********
verificar_senha:
    ldrb r1, =senha
    ldrb r0, senha
    cmp r0, #10
    beq existente
    ldrb r0, =DISPLAY_1
    strb r0, [r1]
    ldrb r0, =DISPLAY_2
    strb r0, [r1,#1]
    ldrb r0, =DISPLAY_3
    strb r0, [r1,#2]
    ldrb r0, =DISPLAY_4
    strb r0, [r1,#3]
    mov r3, #1                  @ senha válida
    b  verificada
    
existente:
    mov r2, #0
    ldrb r0, =DISPLAY_1
    cmp r0, r1
    bne verificada
    add r1, #1  
    ldrb r0, =DISPLAY_2
    cmp r0, r1
    bne verificada
    add r1, #1  
    ldrb r0, =DISPLAY_3
    cmp r0, r1
    bne verificada
    add r1, #1  
    ldrb r0, =DISPLAY_4
    cmp r0, r1
    bne verificada
    add r1, #1   
verificada:
    bx lr

