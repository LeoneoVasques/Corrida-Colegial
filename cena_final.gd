extends Control

# Nós do Boletim (Ative o "Acesso como Nome Único" neles no Editor!)
@onready var texto_moedas = $%TextoMoedas
@onready var texto_inimigos = $%TextoInimigos
@onready var texto_nota_final = $%TextoNotaFinal

# Nós das Instruções do teclado (Ative o "Acesso como Nome Único" neles também!)
@onready var texto_recomencar = $%TextoInstrucaoRecomencar
@onready var texto_sair = $%TextoInstrucaoSair

func _ready() -> void:
	# 1. Esconde o mouse já que o controle agora é 100% no teclado
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# 2. O GLOBAL DIZ: "Para a música antiga e toca a de Vitória!"
	Global.tocar_musica("res://sons/musica win.mp3")
	
	# 3. Coleta as estatísticas básicas para exibir na tela
	var moedas_coletadas = Global.moedas
	var inimigos_derrotados = Global.inimigos_mortos
	
	# 4. CHAMA A NOVA LÓGICA DE CÁLCULO (Aplica penalidades de tempo, dano e mortes automaticamente)
	var nota_final = Global.calcular_nota_final()
	
	# 5. Exibe os dados e a nota calibrada no painel
	texto_moedas.text = "Moedas Coletadas: " + str(moedas_coletadas)
	texto_inimigos.text = "Inimigos Derrotados: " + str(inimigos_derrotados)
	texto_nota_final.text = "nota da prova final: " + "%.1f" % nota_final

	# 6. Ativa o efeito piscar nos textos de instrução de comandos
	animar_textos_piscar()

# 🎬 FUNÇÃO DO EFEITO BLINK (OPACIDADE)
func animar_textos_piscar() -> void:
	var tween = create_tween().set_loops()
	
	# Fade Out (Ficam semi-transparentes juntos)
	tween.tween_property(texto_recomencar, "modulate:a", 0.1, 0.6)
	tween.parallel().tween_property(texto_sair, "modulate:a", 0.1, 0.6)
	
	# Fade In (Voltam a ficar 100% visíveis juntos)
	tween.tween_property(texto_recomencar, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(texto_sair, "modulate:a", 1.0, 0.6)

# ⌨️ DETECTOR DE TECLAS
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			recomencar_jogo()
		elif event.keycode == KEY_ESCAPE:
			sair_do_jogo()

func recomencar_jogo() -> void:
	set_process_unhandled_input(false)
	
	# Usa a nova função que criamos para limpar tudo do jogo de uma vez só
	Global.resetar_jogo_completo()
	
	# Manda o Global voltar a tocar a música tema padrão do jogo
	Global.tocar_musica("res://sons/pixel-drift-pecan-pie-main-version-41106-02-09.mp3")
	
	# Muda para o Menu Principal
	var erro = get_tree().change_scene_to_file("res://menu_principal.tscn")
	if erro != OK:
		print("Erro ao voltar para o Menu Principal!")

func sair_do_jogo() -> void:
	get_tree().quit()
