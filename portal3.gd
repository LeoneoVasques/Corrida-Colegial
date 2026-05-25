extends Area2D

const CAMINHO_PROXIMA_FASE = "res://cena_final.tscn"

# --- REFERÊNCIAS DA TRANSIÇÃO (Garanta que os nomes dos nós filhos batem com estes) ---
@onready var transicao_hud = $TransicaoHUD
@onready var fundo_preto = $TransicaoHUD/FundoPreto
@onready var texto_fase = $TransicaoHUD/TextoFase

func _ready() -> void:
	# Conecta automaticamente o sensor de colisão
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Melo":
		# Proteção básica caso o Melo chegue morto no final
		if "esta_morto" in body and body.esta_morto:
			return
			
		# 1. TRAVA O MELO: Impede comandos do jogador e força pose de parado
		body.set_physics_process(false)
		if body.has_node("AnimationPlayer"):
			body.get_node("AnimationPlayer").play("Parado")
		
		# 2. PREPARA A INTERFACE: Torna visível mas 100% transparente no início
		transicao_hud.visible = true
		fundo_preto.modulate.a = 0.0
		texto_fase.modulate.a = 0.0
		
		# 3. EFEITO FADE-IN: Escurece a tela e faz o texto surgir em 0.5 segundos
		var tween = create_tween().set_parallel(true)
		tween.tween_property(fundo_preto, "modulate:a", 1.0, 0.5)
		tween.tween_property(texto_fase, "modulate:a", 1.0, 0.5)
		
		# 4. O DELAY: Dá um tempo de respiro de 1.5 segundos com a tela preta
		await get_tree().create_timer(2.5).timeout
		
		# 5. SISTEMA GLOBAL: Prepara o Global salvando as moedas e resetando o checkpoint
		Global.registrar_inicio_nova_fase()
		
		# 6. TROCA DE FASE EFETIVA
		var erro = get_tree().change_scene_to_file(CAMINHO_PROXIMA_FASE)
		if erro != OK:
			print("Erro: Não foi possível carregar a próxima fase! Verifique o caminho do arquivo.")
