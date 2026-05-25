extends Area2D

var direcao: Vector2 = Vector2.ZERO
var velocidade: float = 0.0

func _ready() -> void:
	print("--- BALA LOG: Eu nasci no mundo! Minha posição inicial é: ", global_position)

func _physics_process(delta: float) -> void:
	global_position += direcao * velocidade * delta

func _on_body_entered(body: Node2D) -> void:
	print("--- BALA LOG: Encostei em algo chamado -> ", body.name)
	if body.name == "Melo":
		if body.has_method("tomar_dano"):
			body.tomar_dano()
		queue_free()
	elif body is TileMapLayer or body.name.contains("Chão") or body.name.contains("StaticBody"):
		print("--- BALA LOG: Sumi porque bati no cenário/chão!")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("--- BALA LOG: Sumi porque saí da tela.")
	queue_free()
