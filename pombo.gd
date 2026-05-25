extends CharacterBody2D

const BALA_POMBO_SCENE = preload("res://pombo_bala.tscn")

enum Estado { CISCANDO, SACANDO, ATIRANDO, MORTO }
var estado_atual = Estado.CISCANDO

@onready var anim = $AnimationPlayer
@onready var timer_tiro = $TimerTiro
@onready var ponto_tiro = $PontoTiro

# --- AS 4 SPRITES SEPARADAS ---
@onready var sprite_ciscando = $SpriteCiscando
@onready var sprite_sacando = $SpriteSacando
@onready var sprite_atirando = $SpriteAtirando
@onready var sprite_morrendo = $SpriteMorrendo

@export var velocidad_bala: float = 350.0
@export var tempo_entre_tiros: float = 1.8

var alvo_melo: Node2D = null

func _ready() -> void:
	timer_tiro.wait_time = tempo_entre_tiros
	anim.animation_finished.connect(_on_animation_finished)
	mudar_estado(Estado.CISCANDO)

func _physics_process(delta: float) -> void:
	if estado_atual == Estado.MORTO:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
	if alvo_melo and estado_atual != Estado.MORTO:
		var olhar_esquerda = alvo_melo.global_position.x < global_position.x
		var deve_virar = !olhar_esquerda
		
		sprite_ciscando.flip_h = deve_virar
		sprite_sacando.flip_h = deve_virar
		sprite_atirando.flip_h = deve_virar
		sprite_morrendo.flip_h = deve_virar
		
		ponto_tiro.position.x = abs(ponto_tiro.position.x) * (-1 if olhar_esquerda else 1)

func mudar_estado(novo_estado: Estado) -> void:
	if estado_atual == Estado.MORTO:
		return
		
	estado_atual = novo_estado
	
	match estado_atual:
		Estado.CISCANDO:
			timer_tiro.stop()
			sprite_ciscando.visible = true
			sprite_sacando.visible = false
			sprite_atirando.visible = false
			sprite_morrendo.visible = false
			anim.play("ciscando")
			
		Estado.SACANDO:
			timer_tiro.stop()
			sprite_ciscando.visible = false
			sprite_sacando.visible = true
			sprite_atirando.visible = false
			sprite_morrendo.visible = false
			anim.play("sacando_arma")
			
		Estado.ATIRANDO:
			sprite_ciscando.visible = false
			sprite_sacando.visible = false
			sprite_atirando.visible = true
			sprite_morrendo.visible = false
			
			timer_tiro.start()
			anim.play("atirando")
			
		Estado.MORTO:
			timer_tiro.stop()
			velocity = Vector2.ZERO
			if has_node("CollisionShape2D"):
				$CollisionShape2D.set_deferred("disabled", true)
			sprite_ciscando.visible = false
			sprite_sacando.visible = false
			sprite_atirando.visible = false
			sprite_morrendo.visible = true
			anim.play("morrendo")

func executar_disparo() -> void:
	if estado_atual != Estado.ATIRANDO or !alvo_melo:
		return
		
	# --- LINHA NOVA: Toca o som do tiro perfeitamente no frame do clarão! ---
	if has_node("SomTiro"):
		$SomTiro.play()
		
	var bala = BALA_POMBO_SCENE.instantiate()
	
	get_parent().add_child(bala)
	bala.global_position = ponto_tiro.global_position
	
	var direcao_horizontal = -1 if alvo_melo.global_position.x < global_position.x else 1
	bala.direcao = Vector2(direcao_horizontal, 0) 
	bala.velocidade = velocidad_bala

	# --- AJUSTE DA ORIENTAÇÃO (A única alteração feita) ---
	if direcao_horizontal == -1:
		bala.scale.x = -1

func _on_animation_finished(anim_name: String) -> void:
	if estado_atual == Estado.SACANDO and anim_name == "sacando_arma":
		mudar_estado(Estado.ATIRANDO)
	elif estado_atual == Estado.ATIRANDO and anim_name == "atirando":
		anim.play("atirando")
		anim.stop() 
	elif estado_atual == Estado.MORTO and anim_name == "morrendo":
		queue_free()

# --- CONEXÕES DOS SENSORES (SINAIS) ---

func _on_area_range_body_entered(body: Node2D) -> void:
	if body.name == "Melo" and estado_atual == Estado.CISCANDO:
		alvo_melo = body
		mudar_estado(Estado.SACANDO)

func _on_area_range_body_exited(body: Node2D) -> void:
	if body.name == "Melo" and estado_atual != Estado.MORTO:
		alvo_melo = null
		mudar_estado(Estado.CISCANDO)

func _on_timer_tiro_timeout() -> void:
	if estado_atual == Estado.ATIRANDO:
		anim.play("atirando") 

func _on_area_contato_body_entered(body: Node2D) -> void:
	if estado_atual != Estado.MORTO and body.name == "Melo" and body.has_method("tomar_dano"):
		body.tomar_dano()

func _on_area_cabeca_body_entered(body: Node2D) -> void:
	if estado_atual != Estado.MORTO and body.name == "Melo":
		if body.get("velocity") and body.velocity.y > 0:
			body.velocity.y = -350 
			morrer()

func morrer() -> void:
	if estado_atual == Estado.MORTO:
		return
		
	Global.inimigos_mortos += 1
	mudar_estado(Estado.MORTO)
	
	await get_tree().create_timer(0.1).timeout
	if has_node("SomMorte"):
		$SomMorte.play()
