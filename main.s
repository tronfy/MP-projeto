# Ler ASCII da UART com polling, escrever de volta
#
# r8  - indexador de dispositivos (0x10000000)
# r15 - tamanho do buffer

.equ UART_DATA, 0x1000
.equ UART_CTRL, 0x1004
.global LED_DATA
.equ LED_DATA, 0x0
.global SWITCH_DATA
.equ SWITCH_DATA, 0x40
.equ TIMER, 0x10002000

.org 0x20
# RTI
    rdctl   et, ipending
    beq     et, zero, OTHER_EXCEPTIONS
    subi    ea, ea, 4       # hwint, subtrai 4 do ea

    # TODO: certificar que eh int do timer
    call    ANIM_UPDATE

    # clear timeout bit
    movia   r13, TIMER
    stwio   r0, 0(r13)
OTHER_INTERRUPTS:
    br      END_HANDLER
OTHER_EXCEPTIONS:
END_HANDLER:
    eret

.global _start
_start:
    # definir contagem
    # 10mi = 10011000 1001011010000000
    movia   r13, TIMER
    movia    r9, 0b1001011010000000 
    stwio   r9, 0x8(r13)
    movi    r9, 0b10011000
    stwio   r9, 0xc(r13)

    # inicializa o ponteiro de stack
    movia   sp, 0x100000

    # habilita PIE
    movi    r8, 0b1
    wrctl   status, r8

    # habilita int timer
    movi    r8, 0b1
    wrctl   ienable, r8     

    # configura int e inicia timer
    movi    r10, 0b0111
    stwio   r10, 4(r13)

    movia   r8, 0x10000000


    movia r16, MSG_START
    call EXIBIR_MSG                 # exibe mensagem de inicio

    movia   r16, MSG_PROMPT
    call EXIBIR_MSG                 # exibe prompt

# inicia o loop de polling
    mov     r15, zero
UART_RECEBE:
# recebe um byte da UART
    ldwio   r9, UART_DATA(r8)
    andi    r10, r9, 0x8000         # r10 = RVALID
    beq     r10, zero, UART_RECEBE
    andi    r10, r9, 0xff           # r10 = DATA

UART_PROCESSA:
    # se for enter, finaliza buffer
    movi    r14, 0xa                # LF
    beq     r10, r14, FINALIZA_BUFFER

#    # se for backspace, decrementa o tamanho do buffer
#    movi    r14, 0x08               # backspace
#    beq     r10, r14, BACKSPACE

    # se buffer cheio, continua
    movi    r14, 16
    beq     r15, r14, UART_RECEBE 

    # se nao for numero, continua
    movi    r14, 0x30               # '0'
    blt     r10, r14, UART_RECEBE
    movi    r14, 0x39               # '9'
    bgt     r10, r14, UART_RECEBE

    # armazena o byte recebido no buffer
    subI    r11, r10, 0x30          # r11 = byte - '0'
    stw     r11, INPUT_BUF(r15)
    addi    r15, r15, 4             # incrementa o indice do buffer

UART_ENVIA:
# exibe o byte recebido
    ldwio   r9, UART_CTRL(r8)
    andi    r11, r9, 0xffff0000     # r11 = WSPACE
    beq     r11, zero, UART_ENVIA
    stwio   r10, UART_DATA(r8)    
    br      UART_RECEBE

# BACKSPACE:
## decrementa o tamanho do buffer
#    beq     r15, zero, UART_RECEBE  # se buffer vazio, volta para receber
#    subi    r15, r15, 4             # decrementa o tamanho do buffer
## exibe o enter
#    ldwio   r9, UART_CTRL(r8)
#    andi    r11, r9, 0xffff0000     # r11 = WSPACE
#    beq     r11, zero, FINALIZA_BUFFER
#    stwio   r10, UART_DATA(r8)
#    br      UART_RECEBE

FINALIZA_BUFFER:
# exibe o enter
    ldwio   r9, UART_CTRL(r8)
    andi    r11, r9, 0xffff0000     # r11 = WSPACE
    beq     r11, zero, FINALIZA_BUFFER
    stwio   r10, UART_DATA(r8)

# processa o buffer
    movia   r14, INPUT_BUF          # r14 = endereco do buffer
    ldw     r11, 0(r14)             # lê o primeiro byte do buffer
    slli    r12, r11, 4
    ldw     r11, 4(r14)             # lê o segundo byte do buffer
    or      r12, r12, r11

    # verifica o comando
    movi    r13, 0x00
    beq     r12, r13, CALL_LED_ACENDE
    movi    r13, 0x01
    beq     r12, r13, CALL_LED_APAGA
    movi    r13, 0x10
    beq     r12, r13, CALL_ANIM_START
    movi    r13, 0x11
    beq     r12, r13, CALL_ANIM_STOP
    movi    r13, 0x20
    beq     r12, r13, CALL_CRON_START
    movi    r13, 0x21
    beq     r12, r13, CALL_CRON_STOP

    # comando desconhecido, limpa o buffer e volta para receber
    movia   r16, MSG_COMANDO_DESCONHECIDO
    call EXIBIR_MSG
    br LIMPA_BUFFER

CALL_LED_ACENDE:
    call LED_ACENDE
    br LIMPA_BUFFER
CALL_LED_APAGA:
    call LED_APAGA
    br LIMPA_BUFFER
CALL_ANIM_START:
    call ANIM_START
    br LIMPA_BUFFER
CALL_ANIM_STOP:
    call ANIM_STOP
    br LIMPA_BUFFER
CALL_CRON_START:
    call CRON_START
    br LIMPA_BUFFER
CALL_CRON_STOP:
    call CRON_STOP
    br LIMPA_BUFFER

LIMPA_BUFFER:
    movia   r14, INPUT_BUF          # r17 = endereco do buffer
LOOP_LIMPA_BUFFER:
    beq     r15, zero, UART_RECEBE  # se buffer vazio, fim
    stw     r0, 0(r14)              # limpa o byte do buffer
    subi    r15, r15, 4             # decrementa o tamanho do buffer
    bne     r15, zero, LOOP_LIMPA_BUFFER  # se ainda ha bytes, continua
    movia   r16, MSG_PROMPT         # exibe o prompt novamente
    call EXIBIR_MSG
    br      UART_RECEBE             # volta para receber mais bytes


END:
    br      END


#.global EXIBIR_MSG
EXIBIR_MSG: # exibe a mensagem em r16
    addi    sp, sp, -16     # aloca espaco na pilha
    stw     ra, 12(sp)      # salva o endereco de retorno
    stw     fp, 8(sp)      # salva o frame pointer
#    stw     r16, 12(sp)
#    stw     r17, 8(sp)
#    stw     r18, 4(sp)
#    stw     r19, 0(sp)
    addi fp, sp, 8
PRINT_MSG_LOOP:
    ldb     r17, 0(r16)             # le um byte da string
    beq     r17, zero, FIM_MSG      # se zero, fim da string
    # espera espaco para enviar
WAIT_WSPACE_MSG:
    ldwio   r18, UART_CTRL(r8)
    andi    r19, r18, 0xffff0000
    beq     r19, zero, WAIT_WSPACE_MSG
    stwio   r17, UART_DATA(r8)      # envia caractere
    addi    r16, r16, 1             # próximo caractere
    br      PRINT_MSG_LOOP
FIM_MSG:
    ldw     ra, 12(sp)      # restaura o endereco de retorno
    ldw     fp, 8(sp)      # restaura o frame pointer
#    ldw     r16, 12(sp)
#    ldw     r17, 8(sp)
#    ldw     r18, 4(sp)
#    ldw     r19, 0(sp)
    addi    sp, sp, 16              # desaloca espaco na pilha
    ret


.org 0x500
.global INPUT_BUF
INPUT_BUF:
    .space 4
MSG_START:
    .asciz "Entre com o comando:\n"
MSG_PROMPT:
    .asciz "> "
MSG_COMANDO_DESCONHECIDO:
    .asciz "Comando desconhecido!\n"
.global LED_STATUS
LED_STATUS:
    .space 17

.global ANIM_ACTIVE
ANIM_ACTIVE:
    .byte 0
.end
