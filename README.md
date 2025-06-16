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
  - chama `ANIM_UPDATE` (a cada 200ms)
  - chama `CRON_UPDATE` (a cada 1s)
  - chama `CRON_PAUSE_RESUME` (na borda de `KEY1`)
- tabela de conversão de 7 segmentos


### `led.s`
- gerencia estado dos LEDs (conforme definido pelos comandos `00 xx` e `01 xx`)
- mantém esse estado armazenado durante a rotina de animação, reaplica após

### `anim.s`
- usa temporizador para animar os LEDs
- utiliza `roli 1` (esquerda) ou `roli 31` (direita), dependendo do estado de `SW0`

### `cron.s`
- usa temporizador para animar o 
- mantém 4 contadores decimais (unidade, dezena, ...)
- responde a comando de pause/resume
- usa tabela de conversão


## Desenvolvimento

### 26/05

- implementação da entrada de texto pela UART, aceitando apenas números e Enter
- estrutura básica do projeto, separando funcionalidades em diferentes arquivos
- parsing de comando e chamadas das respectivas subrotinas (ainda não implementadas)

### 02/06

- implementação de comandos para acender/apagar LEDs
- implementação da animação de LEDs baseada na posição do `SW0`
  - escolhemos manter o estado anterior dos LEDs, salvando em memória
- implementação inicial do cronômetro, em hexadecimal, sem pause/resume
- começamos a usar stack frames nas subrotinas para evitar de sobrescrever `ra` e `fp`

### 09/06

- implementação decimal do cronômetro
- implementação da subrotina de pause/resume
- correção de bugs relacionados a `stw`/`stb`

### 16/06

- RTI `KEY1`, chamada da subrotina de pause/resume
- correção de bugs relacionados a `stw`/`stb`
- formatação do código, adição de comentários
- relatório

## Considerações Finais

- O material de apoio fornecido foi suficiente para o desenvolvimento dos laboratórios e projeto final.
- Apreciamos o fato de que a modularização de conceitos nos laboratórios facilitou a elaboração do trabalho final.
- O professor sempre foi muito solícito em responder dúvidas e orientar o desenvolvimento.
