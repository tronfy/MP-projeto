.global CRON_START
.global CRON_STOP
.global CRON_UPDATE
.global CRON_PAUSE_RESUME

CRON_START:
    addi    sp, sp, -16
    stw     ra, 12(sp)
    stw     fp, 8(sp)
    
    movia r16, 0b1
    stb r16, CRON_ACTIVE(r0)
    #NEW
    stb r0,  CRON_PAUSED(r0)

    # Inicializa contadores de unidade->[...]->milhar
    stb r0, CRON_COUNTER_UNI(r0)
    stb r0, CRON_COUNTER_DEZ(r0)
    stb r0, CRON_COUNTER_CEN(r0)
    stb r0, CRON_COUNTER_MIL(r0)

    # Teste com valores personalizados
    # addi r17, r0, 9
    #stb r17, CRON_COUNTER_MIL(r0)
    # addi r17, r0, 8
    #stb r17, CRON_COUNTER_CEN(r0)
    # addi r17, r0, 9
    #stb r17, CRON_COUNTER_DEZ(r0)
    # addi r17, r0, 0
    #stb r17, CRON_COUNTER_UNI(r0)

    ldw     ra, 12(sp)
    ldw     fp, 8(sp)
    addi    sp, sp, 16
    ret

# FALTA ALTERAR OS VALORES DE IO DO BOTAO
CRON_PAUSE_RESUME:
    addi    sp, sp, -16
    stw     ra, 12(sp)
    stw     fp, 8(sp)

    ldb     r16, CRON_PAUSED(r0)
    addi    r17, r0, 1
    sub     r16, r17, r16
    stb     r16, CRON_PAUSED(r0)

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
    ldb  r16, CRON_ACTIVE(r0)
    beq  r16, r0, CRON_END
    # se COIN_PAUSED for 1, não faz nada
    ldb  r16, CRON_PAUSED(r0)
    addi r17, r0, 1
    beq  r16, r17, CRON_END

    # Carrega digito das unidades do cronometro para somar 1
    ldb r16, CRON_COUNTER_UNI(r0)
    addi r16, r16, 1
    addi r17, r0, 10
    # Se não transborda unidade, pula próximos passos
    bne r16, r17, CRON_NOT_CARRYOVER_UNI
    stb r0, CRON_COUNTER_UNI(r0)

    # Carrega digito das dezenas do cronometro para somar 1
    ldb r16, CRON_COUNTER_DEZ(r0)
    addi r16, r16, 1
    addi r17, r0, 10
    # Se não transborda dezena, pula próximos passos
    bne r16, r17, CRON_NOT_CARRYOVER_DEZ
    stb r0, CRON_COUNTER_DEZ(r0)

    # Carrega digito das centenas do cronometro para somar 1
    ldb r16, CRON_COUNTER_CEN(r0)
    addi r16, r16, 1
    addi r17, r0, 10
    # Se não transborda centena, pula próximos passos
    bne r16, r17, CRON_NOT_CARRYOVER_CEN
    stb r0, CRON_COUNTER_CEN(r0)

    # Carrega digito dos milhares do cronometro para somar 1
    ldb r16, CRON_COUNTER_MIL(r0)
    addi r16, r16, 1
    addi r17, r0, 10
    # Se não transborda milhar, pula próximos passos
    bne r16, r17, CRON_NOT_CARRYOVER_MIL
    stb r0, CRON_COUNTER_MIL(r0)
    br CRON_DONE_CARRYOVER


CRON_NOT_CARRYOVER_UNI:
    stb r16, CRON_COUNTER_UNI(r0)
    br CRON_DONE_CARRYOVER

CRON_NOT_CARRYOVER_DEZ:
    stb r16, CRON_COUNTER_DEZ(r0)
    br CRON_DONE_CARRYOVER

CRON_NOT_CARRYOVER_CEN:
    stb r16, CRON_COUNTER_CEN(r0)
    br CRON_DONE_CARRYOVER

CRON_NOT_CARRYOVER_MIL:
    stb r16, CRON_COUNTER_MIL(r0)
    br CRON_DONE_CARRYOVER


CRON_DONE_CARRYOVER:
    # escrever nos displays
    movia r17, DISPLAY_DATA(r0)

    # r19 guarda a palavra a ser escrita nos displays
    mov     r19, r0

    # DECODE UNIDADE
    ldb     r16, CRON_COUNTER_UNI(r0)  # carrega valor das unidades
    ldb     r18, TABELA_7SEG(r16)      # pega o decode do display na tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    # DECODE DEZENA
    ldb     r16, CRON_COUNTER_DEZ(r0)  # carrega valor das dezenas
    ldb     r18, TABELA_7SEG(r16)      # pega o decode do display na tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    # DECODE CENTENA
    ldb     r16, CRON_COUNTER_CEN(r0)  # carrega valor das centenas
    ldb     r18, TABELA_7SEG(r16)      # pega o decode do display na tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    # DECODE MILHAR
    ldb     r16, CRON_COUNTER_MIL(r0)  # carrega valor dos milhares
    ldb     r18, TABELA_7SEG(r16)      # pega o decode do display na tabela
    add     r19, r19, r18
    roli    r19, r19, 32-8

    stwio   r19, 0(r17)                # escreve nos displays de 7 segmentos (HEX3->HEX0)


CRON_END:
    ldw     ra, 12(sp)
    ldw     fp, 8(sp)
    addi    sp, sp, 16
    ret
