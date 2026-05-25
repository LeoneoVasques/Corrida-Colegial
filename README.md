# 🎓 Corrida Colegial

> Um jogo de plataforma 2D ágil e desafiador desenvolvido na **Godot Engine 4** — enfrente inimigos, colete moedas e gerencie seu tempo para não ser reprovado na Prova Final!

---

## 🎮 Sobre o Jogo

**Corrida Colegial** é um jogo de plataforma 2D com estética pixel art focado em velocidade e precisão. O jogador controla o **Melo**, um cachorro antropomórfico determinado que acabou se atrasando para a faculdade. Preocupado em perder a avaliação mais importante do semestre, ele decide correr da sua casa até o campus universitário.

Ao final da jornada, o jogador passa por um "boletim" que exibe uma **Nota de 0.0 a 10.0** baseada estritamente no seu desempenho operacional ao longo de todo o percurso.

---

## 🕹️ Controles

O jogo foi projetado para ser controlado exclusivamente via teclado:

| Contexto       | Ação                            | Tecla                  |
| :------------- | :------------------------------ | :--------------------- |
| **Gameplay**   | Mover para a Esquerda           | `←` ou `Seta Esquerda` |
| **Gameplay**   | Mover para a Direita            | `→` ou `Seta Direita`  |
| **Gameplay**   | Pular (Controle de altura)      | `↑` ou `Seta Cima`     |
| **Gameplay**   | Atacar (Soco)                   | `Barra de Espaço`      |
| **Tela Final** | Reiniciar o Jogo (Reset Global) | `Barra de Espaço`      |
| **Tela Final** | Sair do Jogo Imediatamente      | `Tecla Esc`            |

---

## ⚙️ Sistemas de Elite e Mecânicas

### 📊 Lógica de Nota e Penalidades Permanentes

A pontuação final é calculada de forma dinâmica através do Singleton `Global`. O sistema premia os objetivos cumpridos, mas pune severamente os erros cometidos pelo jogador (cujas punições acumuladas **não são perdoadas** ao voltar para um checkpoint):

- 🪙 **Moeda Coletada:** +50 pontos
- 💀 **Inimigo Derrotado:** +150 pontos
- ⏱️ **Tempo de Jogo:** −1 ponto por segundo decorrido
- 💢 **Dano Recebido (Hit):** −25 pontos por golpe sofrido
- ☠️ **Morte do Jogador:** −100 pontos por reinicialização

A pontuação bruta é processada através de uma trava de segurança que impede notas negativas, sendo convertida para a escala acadêmica:

$$PontosFinais = \max(0, (Moedas \times 50) + (Inimigos \times 150) - (Mortes \times 100) - (Danos \times 25) - Tempo)$$

$$NotaFinal = \min\left(10.0, \frac{PontosFinais}{1000.0}\right)$$

### 🛡️ Mecânica de Checkpoint Anti-Farming

Para impedir que o jogador trapaceie morrendo de propósito para eliminar o mesmo inimigo repetidamente, o jogo utiliza um sistema de "fotos" de progresso. Ao cruzar o portal de uma área, o estado seguro das moedas e abates é salvo. Caso o Melo perca todas as vidas, o jogo limpa os dados daquela tentativa fracassada e restaura apenas o progresso legítimo obtido até o início da fase.

---

## 🗺️ Estrutura de Fases

O jogo se desenrola em um nível contínuo dividido em três zonas temáticas de transição imediata:

1. **Cutscene Inicial:** Introdução em vídeo contextualizando o atraso do Melo.
2. **Área Rural:** Início da corrida, composta por bastante vegetação e árvores.
3. **Área Periférica:** Zona intermediária com pouca vegetação e pequenas construções.
4. **Área Urbana:** Desafio final em uma cidade movimentada e repleta de obstáculos que leva ao campus.
5. **Cena Final:** Tela de vitória com o boletim descritivo e o cálculo da nota final.

---

## 👾 Inimigos

- **Fazendeiros (Bois):** Habitam a Área Rural. Patrulham trechos curtos do chão e causam dano por contato físico. Só podem ser derrotados com socos.
- **Bandidos (Pombos):** Presentes nas Áreas Periférica e Urbana. Ficam estáticos e disparam projéteis (`pombo_bala`) contra o jogador. Podem ser derrotados com socos ou pulando em suas cabeças (o que concede um impulso vertical extra).

---

## 🛠️ Especificações Técnicas

- **Engine:** Godot Engine 4 (Configuração de renderização: _GL Compatibility_)
- **Linguagem:** GDScript
- **Arquitetura de Áudio:** Gerenciador centralizado em nó global persistente (_Autoload_) controlando um `AudioStreamPlayer` a -12.0 dB, garantindo a transição limpa entre a música tema da gameplay e a faixa de vitória (`musica win.mp3`).

---

## 🚀 Como Rodar o Projeto

1. Certifique-se de ter a **Godot Engine 4** instalada em sua máquina.
2. Clone este repositório:

```bash
   git clone [https://github.com/LeoneoVasques/Corrida-Colegial.git](https://github.com/LeoneoVasques/Corrida-Colegial.git)
```
