.global LED_ACENDE
.global LED_APAGA

LED_ACENDE:
    # se ANIM_ACTIVE for 1, não faz nada
    ldb     r16, ANIM_ACTIVE(r0)
    movi    r18, 1
    beq     r16, r18, LED_ACENDE_END

    movia r18, 0x8
    ldw     r16, INPUT_BUF(r18)  # lê o byte do LED a ser aceso

    # multiplicar por 10
    add     r17, r16, r16 # r17 = 2
    add     r17, r17, r17 # r17 = 4
    add     r16, r16, r16 # r16 = 2
    add     r16, r16, r17
    add     r16, r16, r17
    
    movia   r18, 0xc
    ldw     r17, INPUT_BUF(r18)
    add     r16, r16, r17

    # acender esse LED
    movia   r17, 0b1
    sll     r17, r17, r16
    ldw     r16, LED_STATUS(r0)
    or      r16, r16, r17
    stw     r16, LED_STATUS(r0)
    stwio   r16, LED_DATA(r8)
LED_ACENDE_END:
    ret

LED_APAGA:
    # se ANIM_ACTIVE for 1, não faz nada
    ldb     r16, ANIM_ACTIVE(r0)
    movi    r18, 1
    beq     r16, r18, LED_APAGA_END

    movia   r18, 0x8
    ldw     r16, INPUT_BUF(r18)  # lê o byte do LED a ser aceso

    # multiplicar por 10
    add     r17, r16, r16 # r17 = 2
    add     r17, r17, r17 # r17 = 4
    add     r16, r16, r16 # r16 = 2
    add     r16, r16, r17
    add     r16, r16, r17
    
    movia   r18, 0xc
    ldw     r17, INPUT_BUF(r18)
    add     r16, r16, r17

    movia   r17, 0xfffffffe
    rol     r17, r17, r16

    ldw     r16, LED_STATUS(r0)
    and     r16, r16, r17
    stw     r16, LED_STATUS(r0)
    stwio   r16, LED_DATA(r8)
LED_APAGA_END:
    ret
