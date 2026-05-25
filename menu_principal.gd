extends Control

# Puxa o nó da animação. Garanta que o nome do nó na sua árvore seja exatamente "AnimationPlayer"
@onready var anim = $AnimationPlayer 

func _ready() -> void:
	# Esconde o mouse para o visual ficar limpo
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# --- FORÇA A ANIMAÇÃO VIA CÓDIGO ---
	if has_node("AnimationPlayer"):
		# Altere "menu_idle" para o nome exato da animação que você criou!
		anim.play("menu_idle") 

func _unhandled_input(event: InputEvent) -> void:
	# Ignora o movimento do mouse
	if event is InputEventMouseMotion:
		return
		
	# Se qualquer botão for pressionado, inicia o jogo
	if event.is_pressed():
		iniciar_jogo()

func iniciar_jogo() -> void:
	set_process_unhandled_input(false)
	
	var erro = get_tree().change_scene_to_file("res://Fase 1.tscn")
	if erro != OK:
		print("Erro ao carregar a Fase 1! Verifique o caminho do arquivo.")
