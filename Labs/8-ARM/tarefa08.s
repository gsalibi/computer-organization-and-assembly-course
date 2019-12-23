@       Tarefa 08
@ Gustavo Henrique Storti Salibi
@ RA: 174135

.global _start
@ constantes
    .equ DISPLAY_1, 0xa0000
    .equ DISPLAY_2, 0xa0001
    .equ DISPLAY_3, 0xa0002
    .equ DISPLAY_4, 0xa0003
    .equ TECL_DADO, 0xb0001
    .equ TECL_EST,  0xb0000
    .equ TIMER,     0xc0000
    .equ LEDS,      0x90000
    .equ BOTAO,     0xd0000
    .set IRQ,       0x6
    .set FIQ,       0x40
    .set IRQ_MODE,  0x12
    .set FIQ_MODE,  0x11
    .set USER_MODE, 0x10
    .set STACK,     0x80000
    .set STACK_FIQ, 0x72000
    .set STACK_IRQ, 0x70000

@ vetor de interrupções
    .org IRQ*4                      @ preenche apenas uma posição do vetor, correspondente à IRQ
    b    tratador_irq               @ desvio para o tratador


    .org 0x1000
_start:
    mov	  r0, #IRQ_MODE	            @ coloca processador no modo IRQ (interrupção externa)
    msr   cpsr, r0                  @ processador agora no modo IRQ
    mov   sp, #STACK_IRQ            @ seta pilha de interrupção IRQ
    mov   r0, #USER_MODE            @ coloca processador no modo usuário
    bic   r0,r0, #IRQ               @ interrupções IRQ habilitadas
    msr   cpsr, r0                  @ processador agora no modo usuário
    mov   sp, #STACK                @ pilha do usuário no final da memória 

    ldr   r1, =BOTAO                @ carrega endereço do botão
    ldr   r10, =TIMER               @ carrega endereço do timer
aguarda_botao:
    mov   r0, #10                   @ r0 recebe valor que representa senha não configurada
    strb  r0, senha                 @ atribui valor de não configurada à senha
    ldr   r0, [r1]                  @ carrega valor atual do botão
    cmp   r0, #0                    @ verifica se o botão está despressionado
    bne   aguarda_botao             @ se não, reinicia loop para aguardar
    bl    abrir_cofre               @ abre o cofre     
aguarda:
    ldr   r0, [r1]                  @ carrega valor atual do botão
    cmp   r0, #1                    @ verifica se está pressionado
    bne   aguarda                   @ se não, reinicia loop para aguardar
    bl    fechar_cofre              @ fecha o cofre
    b     aguarda_botao             @ reinicia primeiro loop

@ ********
@ tratador_irq
@ ********
tratador_irq:
    stmfd sp!,{r0-r4, r14}          @ salva registradores na pilha
    mov   r5, #1                    @ ativa reinicialização da digitação
    mov   r6, #0                    @ desativa espera após senha completa ser digitada
    mov   r0, #0                    @ atribui valor 0 a ser gravado no temporizador
    str   r0, [r10]                 @ desativa temporizador
    bl    apagar_mostrador          @ apaga mostrador
    ldmfd sp!,{r0-r4, r14}          @ desempilha registradores
    movs  pc,lr                     @ retorna da interrupção

@ ********
@ apagar_mostrador
@ ********
apagar_mostrador:
    mov   r0, #0                    @ atribui valor 0 a ser escrito nos displays
    ldr   r1, =DISPLAY_1            @ carrega endereço do display 1
    ldr   r2, =DISPLAY_2            @ carrega endereço do display 2
    ldr   r3, =DISPLAY_3            @ carrega endereço do display 3
    ldr   r4, =DISPLAY_4            @ carrega endereço do display 4
    str   r0, [r1]                  @ apaga display 1
    str   r0, [r2]                  @ apaga display 2
    str   r0, [r3]                  @ apaga display 3
    str   r0, [r4]                  @ apaga display 4
    bx    lr                        @ retorna

@ ********
@ abrir_cofre
@ ********
abrir_cofre:
    stmfd sp!,{r0-r4, r14}          @ salva registradores na pilha
    mov   r0, #0                    @ valor a ser escrito para apagar leds
    ldr   r1, =LEDS                 @ coloca o endereço dos leds em r2
    str   r0, [r1]                  @ escreve o valor nos leds
    bl    apagar_mostrador          @ apaga mostradores
    ldmfd sp!,{r0-r4, r14}          @ desempilha registradores
    bx    lr                        @ retorna


@ ********
@ fechar_cofre
@ ********
fechar_cofre:
    stmfd sp!,{r0-r4, r14}          @ salva registradores na pilha
    mov   r0, #1                    @ valor a ser escrito nos leds
    ldr   r1, =LEDS                 @ coloca o endereço dos leds em r2
    str   r0, [r1]                  @ escreve o valor nos leds
    bl    digitar_senha             @ digita nova senha
    bl    verificar_senha           @ verifica senha e escreve no lugar da antiga
    bl    trancar_cofre             @ tranca o cofre
    mov   r0, #1                    @ valor a ser escrito nos leds
    ldr   r1, =LEDS                 @ coloca o endereço dos leds em r2
    str   r0, [r1]                  @ escreve o valor nos leds
    ldmfd sp!,{r0-r4, r14}          @ desempilha registradores
    bx    lr                        @ retorna

@ ********
@ trancar_cofre
@ ********
trancar_cofre:
    stmfd sp!,{r0-r4, r14}          @ salva registradores na pilha
    mov   r0, #2                    @ valor a ser escrito nos leds
    ldr   r1, =LEDS                 @ coloca o endereço dos leds em r2
    str   r0, [r1]                  @ escreve o valor nos leds
tentativa:
    bl    digitar_senha             @ digita senha
    bl    verificar_senha           @ verifica se a senha está correta
    ldr   r2, verificador           @ carrega valor do verificador de senha
    cmp   r2, #3                    @ caso seja 3 (vezes erradas)
    beq   trava_permanente          @ trava permanentemente o cofre
    cmp   r2, #0                    @ caso seja 0, a senha está correta
    bne   tentativa                 @ caso senha seja outro número, é inválida e deve tentar novamente
    ldmfd sp!,{r0-r4, r14}          @ desempilha registradores
    bx    lr                        @ retorna
trava_permanente:
    b     trava_permanente          @ loop infinito inutilizando cofre

@ ********
@ ler_tecla (tem parâmetro display_atual como o mostrador de saída)
@ ********
ler_tecla:
    ldr   r0, display_atual         @ carrega endereço do display atual
    ldr   r1, =TECL_EST             @ carrega endereço do estado do teclado
ler_tecla1:
    ldr   r2, [r1]                  @ lê estado do teclado
    cmp   r5, #1                    @ verifica se houve interrupção
    beq   tempo_expirado            @ se sim, marca que o tempo foi excedido
    cmp   r2, #1                    @ verifica se alguma tecla foi pressionada
    bne   ler_tecla1                @ se não, continua laço
    ldr   r1, =TECL_DADO            @ carrega porta de dados do teclado em r1
    ldr   r3, [r1]                  @ carrega valor da tecla em r3
    ldr   r1, =digitos              @ carrega tabela de dígitos de 7 segmentos
    ldr   r4, [r1, r3]              @ carrega em r4 valor da telca somado a tabela
    str   r4, [r0]                  @ seta valor no mostrador
    str   r4, display_atual         @ salva valor do display atual
tempo_expirado:
    bx    lr                        @ retorna

@ ********
@ digitar_senha 
@ ********
digitar_senha:
    stmfd sp!,{r0-r4, r14}          @ salva registradores na pilha
    ldr   r9, =10000                @ valor em milissegundos da interrupção

reinicia_digitacao: 
loop:
    cmp   r6, #0                    @ verifica se o tempo de espera já terminou
    bne   loop                      @ se não, reinicia o loop para aguardar
    mov   r5, #0                    @ destiva registrador que verifica digitação deve ser reiniciada
    ldr   r0, =DISPLAY_1            @ carrega endereço de display 1 em r0
    str   r0, display_atual         @ salva endereço do display 1 em display_atual
    bl    ler_tecla                 @ lê tecla e exibe no display 1
    ldrb  r0, display_atual         @ carrega valor do display atual
    strb  r0, atual                 @ salva na senha atual, posição 1
    mov   r5, #0                    @ destiva registrador que verifica digitação deve ser reiniciada
    str   r9, [r10]                 @ ativa temporizador antes da segunda tecla
    ldr   r0, =DISPLAY_2            @ carrega endereço de display 2 em r0
    str   r0, display_atual         @ salva endereço do display 2 em display_atual
    bl    ler_tecla                 @ lê tecla e exibe no display 2
    cmp   r5, #1                    @ verifica se o tempo de leitura expirou
    beq   reinicia_digitacao        @ se sim, reinicia digitação
    ldrb  r0, display_atual         @ carrega valor do display atual
    strb  r0, atual+1               @ salva na senha atual, posição 2
    mov   r5, #0                    @ destiva registrador que verifica digitação deve ser reiniciada
    str   r9, [r10]                 @ ativa temporizador antes da terceira tecla
    ldr   r0, =DISPLAY_3            @ carrega endereço de display 3 em r0
    str   r0, display_atual         @ salva endereço do display 3 em display_atual
    bl    ler_tecla                 @ lê tecla e exibe no display 3
    str   r9, [r10]                 @ ativa temporizador antes da terceira tecla
    cmp   r5, #1                    @ verifica se o tempo de leitura expirou
    beq   reinicia_digitacao        @ se sim, reinicia digitação
    ldrb  r0, display_atual         @ carrega valor do display atual
    strb  r0, atual+2               @ salva na senha atual, posição 3
    mov   r5, #0                    @ destiva registrador que verifica digitação deve ser reiniciada
    str   r9, [r10]                 @ ativa temporizador antes da quarta tecla
    ldr   r0, =DISPLAY_4            @ carrega endereço de display 4 em r0
    str   r0, display_atual         @ salva endereço do display 4 em display_atual
    bl    ler_tecla                 @ lê tecla e exibe no display 4
    cmp   r5, #1                    @ verifica se o tempo de leitura expirou
    beq   reinicia_digitacao        @ se sim, reinicia digitação
    ldrb  r0, display_atual         @ carrega valor do display atual
    strb  r0, atual+3               @ salva na senha atual, posição 4
    ldr   r9, =5000                 @ valor em milissegundos da interrupção
    str   r9, [r10]                 @ ativa temporizador para depois do último dígito
    mov   r6, #1                    @ ativa registrador verificador de tempo de espera
    ldmfd sp!,{r0-r4, r14}          @ desempilha registradores
    bx lr                           @ retorna

@ ********
@ verificar_senha (retorna em verificador se a senha é válida)
@ ********
verificar_senha:
    ldrb  r0, atual                 @ carrega primeiro dígito atual
    ldrb  r1, senha                 @ carrega primeiro dígito da senha
	cmp   r1, #10                   @ verifica se já existe senha salva
    bne   senha_existente           @ caso exista, vai para senha_existente
    strb  r0, senha                 @ salva primeiro dígito na senha
    ldrb  r0, atual+1               @ carrega segundo dígito atual
    strb  r0, senha+1               @ salva segundo dígito na senha
    ldrb  r0, atual+2               @ carrega terceiro terceiro atual
    strb  r0, senha+2               @ salva terceiro dígito na senha
    ldrb  r0, atual+3               @ carrega quarto quarto atual
    strb  r0, senha+3               @ salva quarto dígito na senha
    b     retorna
senha_existente:
    ldr   r2, verificador           @ carrega valor do verificador de senha
    cmp   r0, r1                    @ verifica se atual e senha são iguais
    addne r2, #1                    @ se não, aumenta o número de tentativas erradas
    str   r2, verificador           @ grava número de tentativas no verificador
    bne   retorna                   @ e retorna
    ldrb  r0, atual+1               @ carrega segundo dígito atual
    ldrb  r1, senha+1               @ carrega segundo dígito da senha
    cmp   r0, r1                    @ verifica se são iguais
    addne r2, #1                    @ se não, aumenta o número de tentativas erradas
    str   r2, verificador           @ grava número de tentativas no verificador
    bne   retorna                   @ e retorna
    ldrb  r0, atual+2               @ carrega terceiro dígito atual
    ldrb  r1, senha+2               @ carrega terceiro dígito da senha
    cmp   r0, r1                    @ verifica se são iguais
    addne r2, #1                    @ se não, aumenta o número de tentativas erradas
    str   r2, verificador           @ grava número de tentativas no verificador
    bne   retorna                   @ e retorna
    ldrb  r0, atual+3               @ carrega quarto dígito atual
    ldrb  r1, senha+3               @ carrega quarto dígito da senha
    cmp   r0, r1                    @ verifica se são iguais
    addne r2, #1                    @ se não, aumenta o número de tentativas erradas
    str   r2, verificador           @ grava número de tentativas no verificador
    bne   retorna                   @ e retorna    
    mov   r2, #0                    @ caso a senha esteja correta, atribui 0 ao verificador
    str   r2, verificador           @ grava número de tentativas no verificador
retorna:
    bx lr                           @ retorna


@ tabela com valores do mostrador de sete segmentos em ordem crescente
digitos:
    .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47
@ senha correta
senha:
    .skip 4
@ tentativa de digitar senha
atual:
    .skip 4
@ verificador de senha
verificador:
    .word 0x00
@ posição atual do display
display_atual:
    .skip 4

@ syscall exit(int status)
@    mov  r0, #0                    @ status -> 0
@    mov  r7, #1                    @ exit is syscall #1
@    swi  #0x55                     @ invoke syscall 



