.global CRON_START
.global CRON_STOP
.global CRON_UPDATE

CRON_START:
    addi    sp, sp, -16
    stw     ra, 12(sp)
    stw     fp, 8(sp)
    
    movia r16, 0b1
    stb r16, CRON_ACTIVE(r0)
    stw r0, CRON_COUNTER(r0)  # zera o contador

    ldw     ra, 12(sp)
    ldw     fp, 8(sp)
    addi    sp, sp, 16
    ret

CRON_STOP:
    addi    sp, sp, -16
    stw     ra, 12(sp)
    stw     fp, 8(sp)

    stb r0, CRON_ACTIVE(r0)

    # apaga os displays
    movia r16, DISPLAY_DATA
    stwio r0, 0(r16)  # escreve 0 nos displays de 7 segmentos (HEX3->HEX0)

    ldw     ra, 12(sp)
    ldw     fp, 8(sp)
    addi    sp, sp, 16
    ret

CRON_UPDATE:
    addi    sp, sp, -16
    stw     ra, 12(sp)
    stw     fp, 8(sp)

    # se CRON_ACTIVE for 0, não faz nada
    ldb r16, CRON_ACTIVE(r0)
    beq r16, r0, CRON_END

    # ler o contador
    ldw r16, CRON_COUNTER(r0)
    addi r16, r16, 1  # incrementa o contador
    stw r16, CRON_COUNTER(r0)  # salva o contador

    # escrever nos displays
    movia r17, DISPLAY_DATA(r0)

    mov     r19, r0

    # escreve o primeiro dígito
    andi    r18, r16, 0xf  # pega os 4 bits menos significativos
    ldb     r18, TABELA_7SEG(r18)  # pega o valor da tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    # escreve o segundo dígito
    srli    r16, r16, 4  # desloca 4 bits para a direita
    andi    r18, r16, 0xf  # pega os 4 bits menos significativos
    ldb     r18, TABELA_7SEG(r18)  # pega o valor da tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    # escreve o terceiro dígito
    srli    r16, r16, 4  # desloca mais 4 bits para a direita
    andi    r18, r16, 0xf  # pega os 4 bits menos significativos
    ldb     r18, TABELA_7SEG(r18)  # pega o valor da tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    # escreve o quarto dígito
    srli    r16, r16, 4  # desloca mais 4 bits para a direita
    andi    r18, r16, 0xf  # pega os 4 bits menos significativos
    ldb     r18, TABELA_7SEG(r18)  # pega o valor da tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    stwio   r19, 0(r17)  # escreve nos displays de 7 segmentos (HEX3->HEX0)

CRON_END:
    ldw     ra, 12(sp)
    ldw     fp, 8(sp)
    addi    sp, sp, 16
    ret
