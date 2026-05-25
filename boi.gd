extends CharacterBody2D

const SPEED = 100.0
const DISTANCIA_PATRULHA = 120.0
const TEMPO_DE_ESPERA = 1.5

# Puxa os nós de imagem, animação e áudio da sua árvore
@onready var sprite_parado = $BoiParado
@onready var sprite_andando = $BoiAndando
@onready var sprite_morrendo = $BoiMorrendo
@onready var anim = $AnimationPlayer
@onready var som_morte = $SomMorte # <--- Puxa o seu novo nó de áudio!

var posicao_inicial_x: float
var direcao: float = 1.0

var esta_esperando: bool = false
var tempo_restante: float = 0.0
var esta_morto: bool = false

func _ready() -> void:
	posicao_inicial_x = global_position.x
	
	# Começa andando: mostra apenas o de andar
	sprite_andando.visible = true
	sprite_parado.visible = false
	sprite_morrendo.visible = false
	anim.play("BoiAndando")

func _physics_process(delta: float) -> void:
	# SE O BOI ESTIVER MORTO: para tudo e não executa mais nenhuma lógica!
	if esta_morto:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Aplica gravidade se estiver no ar
	if not is_on_floor():
		velocity += get_gravity() * delta

	# SE ELE ESTIVER ESPERANDO PARADO:
	if esta_esperando:
		velocity.x = 0
		tempo_restante -= delta
		
		# Quando o tempo da pausa acabar:
		if tempo_restante <= 0:
			esta_esperando = false
			
			# Inverte o valor da direção de verdade!
			if direcao > 0:
				direcao = -1.0
			else:
				direcao = 1.0
			
			# Agora que a direção mudou, atualiza o flip do lado certo
			var deve_virar = (direcao < 0)
			sprite_parado.flip_h = deve_virar
			sprite_andando.flip_h = deve_virar
			sprite_morrendo.flip_h = deve_virar
				
			# Alterna os sprites para voltar a caminhar
			sprite_parado.visible = false
			sprite_andando.visible = true
			anim.play("BoiAndando")

	# SE ELE ESTIVER CAMINHANDO:
	else:
		var distancia_atual = global_position.x - posicao_inicial_x

		# Se chegou no limite da patrulha:
		if (direcao > 0 and distancia_atual >= DISTANCIA_PATRULHA) or (direcao < 0 and distancia_atual <= -DISTANCIA_PATRULHA):
			esta_esperando = true
			tempo_restante = TEMPO_DE_ESPERA
			velocity.x = 0
			
			# Entra no estado parado
			sprite_andando.visible = false
			sprite_parado.visible = true
			anim.play("BoiParado")
		else:
			velocity.x = direcao * SPEED

	move_and_slide()

# --- FUNÇÃO DE MORTE ATUALIZADA ---
func morrer() -> void:
	if esta_morto:
		return
		
	esta_morto = true
	velocity = Vector2.ZERO
	
	# --- CONTABILIZA A DERROTA DO INIMIGO ---
	Global.inimigos_mortos += 1
	
	som_morte.play()
	
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("AreaDano/CollisionShape2D"):
		$AreaDano/CollisionShape2D.set_deferred("disabled", true)
	
	sprite_andando.visible = false
	sprite_parado.visible = false
	sprite_morrendo.visible = true
	
	anim.play("BoiMorrendo")
	
	await anim.animation_finished
	
	if som_morte.playing:
		await som_morte.finished
	
	queue_free()
	if esta_morto:
		return
		
	esta_morto = true
	velocity = Vector2.ZERO
	
	# Toca o efeito sonoro de morte imediatamente!
	som_morte.play()
	
	# Desativa as colisões para o Melo passar por dentro do corpo caindo
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("AreaDano/CollisionShape2D"):
		$AreaDano/CollisionShape2D.set_deferred("disabled", true)
	
	# Alterna a visibilidade para a sprite de morte
	sprite_andando.visible = false
	sprite_parado.visible = false
	sprite_morrendo.visible = true
	
	# Roda a animação visual da queda
	anim.play("BoiMorrendo")
	
	# Espera a animação de morte do AnimationPlayer acabar
	await anim.animation_finished
	
	# Segurança extra: se a animação acabou mas o som longo ainda está tocando, espera o áudio sumir
	if som_morte.playing:
		await som_morte.finished
	
	# Remove o Boi do mapa definitivamente
	queue_free()

func _on_area_dano_body_entered(body: Node2D) -> void:
	if body.name == "Melo" and not esta_morto:
		body.tomar_dano()
