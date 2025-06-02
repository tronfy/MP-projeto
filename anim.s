.global ANIM_START
.global ANIM_STOP
.global ANIM_UPDATE

ANIM_START:
    movia r16, 0b1
    stwio r16, LED_DATA(r8)
    stw r16, ANIM_ACTIVE(r0)
    ret

ANIM_STOP:
    stw r0, ANIM_ACTIVE(r0)
    ldw r16, LED_STATUS(r0)
    stwio r16, LED_DATA(r8)
    ret

ANIM_UPDATE:
    # se ANIM_ACTIVE for 0, não faz nada
    ldw r16, ANIM_ACTIVE(r0)
    beq r16, r0, ANIM_END

    # ler status dos LEDs
    ldwio r16, LED_DATA(r8)

    # ler switches
    ldwio r18, SWITCH_DATA(r8)
    andi r18, r18, 0b1  # SW0
    beq r18, r0, ANIM_DIR

ANIM_ESQ:
    roli r16, r16, 1  # desloca para a esquerda
    # se r16 estourou, volta para 0b1
    andi r17, r16, 0b1000000000000000000
    beq r17, r0, ANIM_CONTINUE
    movia r16, 0b1  # volta para o primeiro LED
    br ANIM_CONTINUE

ANIM_DIR:
    # se r16 eh 0b1, volta para 0b10000000000000000
    andi r17, r16, 0b1
    roli r16, r16, 31  # desloca 1 para a direita
    beq r17, r0, ANIM_CONTINUE
    movia r16, 0b100000000000000000  # volta para o último LED

ANIM_CONTINUE:
    # TODO: baseado no switch
    stwio r16, LED_DATA(r8)
ANIM_END:
    ret
