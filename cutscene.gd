extends Control

@onready var video = $VideoStreamPlayer # Garanta que esse nome após o $ seja o do seu nó!

func _ready() -> void:
	video.play()

# Essa função PRECISA ter o nome exato que está conectado no painel de Sinais
func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://menu_principal.tscn")
func _unhandled_input(event: InputEvent) -> void:
	# Se mexer o mouse, ignora para não pular sem querer
	if event is InputEventMouseMotion:
		return
		
	# Se apertar qualquer tecla, botão do controle ou clique do mouse
	if event.is_pressed():
		# Interrompe o input para não dar cliques duplicados e vai para o menu
		set_process_unhandled_input(false)
		get_tree().change_scene_to_file("res://menu_principal.tscn")
