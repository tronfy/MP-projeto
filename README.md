# Projeto Final de Microprocessadores

[TODO: introdução]

## Cronograma

| data  | atividade |
| ----- | --------- |
| 26/05 | entrada UART, LEDs |
| 02/06 | animação LEDs |
| 09/06 | cronômetro |
| 16/06 | finalizar relatório |
| 30/06 | tempo extra, apresentação |

## Estrutura do código

### `main.s`
- entrada do programa (`_start`)
- trata da entrada do usuário (UART)
- rotina de tratamento de interrupção
  - chama `led.s`
  - chama `anim.s`
  - chama `cron.s`

### `led.s`
- gerencia estado dos LEDs (conforme definido pelos comandos `00 xx` e `01 xx`)
- mantém esse estado armazenado durante a rotina de animação, reaplica após

### `anim.s`
- usa temporizador para animar os LEDs
- utiliza `sll` ou `srl`, dependendo do estado de `SW0`

### `cron.s`
- usa temporizador para animar o cronômetro
- tabela de conversão de 7 segmentos