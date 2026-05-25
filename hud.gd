extends CanvasLayer

@onready var texto_moedas = $Control/HBoxMoedas/TextoMoedas
@onready var coracoes = [
	$Control/HBoxCoracoes/Coracao1,
	$Control/HBoxCoracoes/Coracao2,
	$Control/HBoxCoracoes/Coracao3
]

func _process(_delta: float) -> void:
	# Atualiza o texto de moedas direto do script Global
	texto_moedas.text = str(Global.moedas)
	
	# Liga/Desliga os corações na tela dependendo da vida do jogador
	for i in range(coracoes.size()):
		if i < Global.vidas:
			coracoes[i].visible = true
		else:
			coracoes[i].visible = false
