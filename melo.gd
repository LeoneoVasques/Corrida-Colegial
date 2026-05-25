extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0

@onready var sprite_parado = $SpriteParado
@onready var sprite_correr = $SpriteCorrer
@onready var sprite_soco = $SpriteSoco
@onready var sprite_morte = $SpriteMorte # <--- NOVO: Agora o script reconhece sua sprite de morte!
@onready var anim = $AnimationPlayer
@onready var ataque_area = $AtaqueArea
@onready var som_dano = $SomDano
@onready var som_soco = $SomSoco
@onready var som_morte = $SomMorte

var atacando = false
var esta_invencivel = false
var esta_morto = false 
var ataque_base_x: float 

func _ready() -> void:
	ataque_base_x = ataque_area.position.x

	# SISTEMA DE CHECKPOINT
	if Global.checkpoint_salvo:
		global_position = Global.ultimo_checkpoint
	else:
		Global.ultimo_checkpoint = global_position
		Global.checkpoint_salvo = true

	# Inicializa escondendo a morte e mostrando apenas o parado
	sprite_parado.visible = true
	sprite_correr.visible = false
	sprite_soco.visible = false
	sprite_morte.visible = false # <--- GARANTE: Melo não começa o jogo morto

	# --- LIMITES DA CÂMERA POR MARCADORES ---
	var limite_esq = get_parent().get_node_or_null("LimiteEsquerdo")
	var limite_dir = get_parent().get_node_or_null("LimiteDireito")

	if limite_esq and limite_dir and has_node("Camera2D"):
		$Camera2D.limit_left = limite_esq.global_position.x
		$Camera2D.limit_top = limite_esq.global_position.y
		$Camera2D.limit_right = limite_dir.global_position.x
		$Camera2D.limit_bottom = limite_dir.global_position.y

func _physics_process(delta: float) -> void:
	if esta_morto:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_released("pular") and velocity.y < 0.0:
		velocity.y *= 0.5

	if Input.is_action_just_pressed("atacar") and not atacando:
		ejecutar_soco()

	var direction := Input.get_axis("mover_esquerda", "mover_direita")

	# TRAVA DE DIREÇÃO E MOVIMENTO DURANTE O SOCO
	if not atacando:
		if direction != 0:
			velocity.x = direction * SPEED
			var deve_virar = (direction < 0)
			sprite_parado.flip_h = deve_virar
			sprite_correr.flip_h = deve_virar
			sprite_soco.flip_h = deve_virar
			sprite_morte.flip_h = deve_virar # Já deixa a de morte espelhada se precisar
			
			ataque_area.position.x = ataque_base_x * direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Máquina de Estados Visual
	if not atacando:
		if direction != 0:
			sprite_parado.visible = false
			sprite_correr.visible = true
			sprite_soco.visible = false
			if is_on_floor() and anim.current_animation != "Correr":
				anim.play("Correr")
		else:
			sprite_parado.visible = true
			sprite_correr.visible = false
			sprite_soco.visible = false
			if is_on_floor() and anim.current_animation != "Parado":
				anim.play("Parado")
	else:
		sprite_parado.visible = false
		sprite_correr.visible = false
		sprite_soco.visible = true

	move_and_slide()

func ejecutar_soco(): # Mantido o nome original para evitar quebras
	if esta_morto: return 
	atacando = true
	som_soco.play()
	anim.play("atacar")
	
	await get_tree().create_timer(0.15).timeout
	if esta_morto: return 
	ataque_area.monitoring = true
	
	await anim.animation_finished
	ataque_area.monitoring = false
	atacando = false

# --- FUNÇÕES DE VIDA, MORTE E ÁUDIO ---

func tomar_dano():
	if esta_morto or esta_invencivel:
		return

	Global.vidas -= 1
	Global.total_danos_tomados += 1 # <--- ADICIONADO: Conta o dano permanentemente para a nota
	som_dano.play()
	velocity.y = -350.0
	
	if Global.vidas <= 0:
		morrer()
		return
		
	executar_efeito_dano()

func executar_efeito_dano():
	esta_invencivel = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	await tween.finished
	esta_invencivel = false

func cair_na_vala():
	if esta_morto: return
	Global.vidas = 0
	morrer()

# 💀 LÓGICA DE MORTE ESTILO SUPER MARIO
func morrer():
	if esta_morto:
		return
		
	esta_morto = true            
	Global.total_mortes += 1 # <--- ADICIONADO: Conta a morte permanentemente para a nota
	
	set_physics_process(false) 
	velocity = Vector2.ZERO    
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# CORREÇÃO DO BUG DA CÂMERA
	if has_node("Camera2D"):
		var posicao_atual_da_camera = $Camera2D.global_position 
		$Camera2D.top_level = true                            
		$Camera2D.global_position = posicao_atual_da_camera    
	
	# Para qualquer áudio ou animação antiga imediatamente
	som_dano.stop()
	anim.stop()
	
	# --- CONTROLE RIGOROSO DE VISIBILIDADE DAS SPRITES ---
	sprite_parado.visible = false
	sprite_correr.visible = false
	sprite_soco.visible = false
	sprite_morte.visible = true # <--- ATIVA EXCLUSIVAMENTE A SPRITE DE MORTE!
	
	# Dispara o áudio e a animação que você criou
	som_morte.play()
	if anim.has_animation("morrer"):
		anim.play("morrer")

	# --- COREOGRAFIA DO TWEEN (SOBE E DESCE) ---
	var start_y = position.y
	var tween_morte = create_tween().set_parallel(false)
	
	tween_morte.tween_interval(0.15)
	tween_morte.tween_property(self, "position:y", start_y - 120, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_morte.tween_property(self, "position:y", start_y + 700, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween_morte.finished
	await get_tree().create_timer(0.4).timeout
	
	# --- ATUALIZADO: Descarta moedas e abates inválidos e restaura a vida via cofre central ---
	Global.resetar_para_checkpoint()
	
	modulate = Color(1, 1, 1, 1)
	get_tree().reload_current_scene()

func _on_ataque_area_body_entered(body: Node2D) -> void:
	if esta_morto: return
	if body.has_method("morrer"):
		body.morrer()
