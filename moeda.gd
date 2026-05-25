extends Area2D

@onready var sprite = $Sprite2D # Se estiver usando AnimatedSprite2D, mude para $AnimatedSprite2D
@onready var som_moeda = $SomMoeda
@onready var collision = $CollisionShape2D

var coletada = false

func _ready() -> void:
	# Conecta automaticamente o sinal de colisão a este próprio script
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem encostou foi o Melo e garante que não vai coletar a mesma moeda duas vezes
	if body.name == "Melo" and not coletada:
		coletada = true
		
		# Modifica a variável global que já existe no seu Global.gd!
		Global.moedas += 1
		
		# --- TRUQUE DO JUICE ---
		# Se dermos queue_free() direto, o som é deletado antes de tocar.
		# Então escondemos a moeda e desligamos a colisão na hora...
		sprite.visible = false
		collision.set_deferred("disabled", true)
		
		# ...tocamos o som...
		som_moeda.play()
		
		# ...e só deletamos o nó de verdade quando o som terminar de tocar!
		await som_moeda.finished
		queue_free()
