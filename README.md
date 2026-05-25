# 🎓 Corrida Colegial

> Um jogo de plataforma 2D desenvolvido no **Godot 4.6** como projeto colegial — enfrente inimigos, colete moedas e tente tirar a melhor nota da prova final!

---

## 🎮 Sobre o Jogo

**Corrida Colegial** é um jogo de plataforma 2D com pixel art onde você controla o **Melo**, um estudante em uma corrida contra o tempo através de fases repletas de obstáculos e inimigos.

Ao final das fases, você recebe uma **nota de 0 a 10** baseada no seu desempenho — coletando moedas, derrotando inimigos, tomando pouco dano e terminando rápido. Cada morte e cada hit contam!

---

## 🕹️ Controles

| Ação | Tecla |
|---|---|
| Mover para a esquerda | ← (Seta Esquerda) |
| Mover para a direita | → (Seta Direita) |
| Pular | ↑ (Seta Cima) |
| Atacar (Soco) | `Espaço` |
| Reiniciar (tela final) | `Espaço` |
| Sair (tela final) | `Esc` |

---

## 📊 Sistema de Nota

A nota final é calculada com base em:

| Fator | Efeito |
|---|---|
| 🪙 Moeda coletada | +50 pontos |
| 💀 Inimigo derrotado | +150 pontos |
| ☠️ Morte do jogador | −100 pontos |
| 💢 Hit recebido | −25 pontos |
| ⏱️ Tempo de jogo | −1 ponto por segundo |

> A pontuação é convertida para escala de **0.0 a 10.0** ao final.  
> Nota mínima garantida: **0.0** (nunca fica negativa).

---

## 🗺️ Fases

- **Cutscene** — Introdução narrativa
- **Fase 1** — Apresentação dos controles e primeiros inimigos
- **Fase 2** — Dificuldade crescente
- **Fase 3** — Desafio final
- **Cena Final** — Boletim com sua nota

---

## 👾 Inimigos

- **Boi** — Patrulha uma área, causa dano por contato direto com o Melo
- **Pombo** — Atira projéteis (`pombo_bala`) na direção do jogador

---

## ⚙️ Tecnologias

- **Engine:** [Godot 4.6](https://godotengine.org/) — GL Compatibility
- **Linguagem:** GDScript
- **Plataforma de export:** Web (HTML5) e Windows Desktop
- **Física 3D:** Jolt Physics (configuração de engine)
- **Áudio:** AudioStreamPlayer centralizado via singleton `Global`

---

## 🗂️ Estrutura do Projeto

```
corrida-colegial/
├── Global.gd              # Singleton: vidas, moedas, checkpoints, nota
├── melo.gd                # Script do personagem principal
├── boi.gd                 # Script do inimigo Boi
├── pombo.gd               # Script do inimigo Pombo
├── cena_final.gd          # Tela de boletim com nota final
├── menu_principal.gd      # Menu inicial
├── hud.gd                 # Interface durante o jogo (HUD)
├── Fase 1.tscn            # Cena da Fase 1
├── Fase 2.tscn            # Cena da Fase 2
├── Fase 3.tscn            # Cena da Fase 3
├── sons/                  # Trilha sonora e efeitos
├── personagens/           # Sprites dos personagens
├── cenários/              # Tilesets e fundos
├── interface/             # Assets de UI
├── itens/                 # Moedas e itens coletáveis
└── videos/                # Cutscenes em vídeo
```

---

## 🚀 Como Rodar

### Pré-requisitos
- [Godot 4.6](https://godotengine.org/download) instalado

### Passos
1. Clone o repositório:
   ```bash
   git clone https://github.com/LeoneoVasques/Corrida-Colegial.git
   ```
2. Abra o **Godot 4.6**
3. Clique em **"Import"** e selecione o arquivo `project.godot`
4. Pressione **F5** para rodar o projeto

---

## 📝 Observações

- O plugin `godot-git-plugin` utilizado durante o desenvolvimento **não está incluído** neste repositório. Baixe separadamente em [godotengine/godot-git-plugin](https://github.com/godotengine/godot-git-plugin) caso queira usá-lo.
- Os arquivos de export Web (`.pck`, `.wasm`, `.html`, `.js`) são gerados pelo Godot e não estão versionados.

---

## 👨‍💻 Autores

Desenvolvido como projeto colegial.

---

*Feito com ❤️ e Godot 4*
