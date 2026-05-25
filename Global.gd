extends Node

var moedas: int = 0
var moedas_inicio_fase: int = 0 
var vidas: int = 3
var max_vidas: int = 3

var ultimo_checkpoint: Vector2 = Vector2.ZERO
var checkpoint_salvo: bool = false

var inimigos_mortos: int = 0
var inimigos_inicio_fase: int = 0 
var tempo_jogo: float = 0.0
var cronometro_ativo: bool = true

# --- NOVAS VARIÁVEIS DE PENALIDADE PERMANENTE ---
var total_mortes: int = 0         # Rastreia todas as mortes da gameplay inteira
var total_danos_tomados: int = 0   # Rastreia cada frame/hit de dano que o Melo levou

# Tocador central de áudio do projeto
var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = -12.0
	tocar_musica("res://sons/pixel-drift-pecan-pie-main-version-41106-02-09.mp3")

func _process(delta: float) -> void:
	if cronometro_ativo:
		tempo_jogo += delta

func resetar_vidas():
	vidas = max_vidas

# Executado quando o jogador clica em recomeçar do zero
func resetar_jogo_completo():
	moedas = 0
	moedas_inicio_fase = 0 
	inimigos_mortos = 0
	inimigos_inicio_fase = 0 
	tempo_jogo = 0.0
	vidas = max_vidas
	checkpoint_salvo = false
	ultimo_checkpoint = Vector2.ZERO
	cronometro_ativo = true
	# Limpa o histórico de penalidades
	total_mortes = 0
	total_danos_tomados = 0

func registrar_inicio_nova_fase():
	moedas_inicio_fase = moedas 
	inimigos_inicio_fase = inimigos_mortos 
	checkpoint_salvo = false 

func resetar_para_checkpoint():
	moedas = moedas_inicio_fase 
	inimigos_mortos = inimigos_inicio_fase 
	resetar_vidas()
	# NOTA: total_mortes e total_danos_tomados NÃO são resetados aqui deliberadamente,
	# pois o jogador deve carregar a penalidade por ter falhado!

# --- NOVA LOGICA DE NOTA COM PENALIDADES ---
func calcular_nota_final() -> float:
	# 1. Pontos positivos conquistados
	var pontos_base = (moedas * 50) + (inimigos_mortos * 150)
	
	# 2. Definição do peso das punições (Ajuste os valores se quiser mais fácil ou difícil)
	var punicao_mortes = total_mortes * 100       # -100 pontos por morte
	var punicao_danos = total_danos_tomados * 25   # -25 pontos por hit levado
	var punicao_tempo = int(tempo_jogo) * 1        # -1 ponto por segundo de jogo
	
	# 3. TITANIC SHIELD: Impede matematicamente que a pontuação fique abaixo de zero
	var pontos_finais = max(0, pontos_base - punicao_mortes - punicao_danos - punicao_tempo)
	
	# 4. Converte os pontos restantes para a nota padrão de 0.0 a 10.0
	var nota = pontos_finais / 1000.0
	return min(10.0, nota)

# --- GERENCIADOR CENTRAL DE ÁUDIO ---
func tocar_musica(caminho_da_musica: String):
	if caminho_da_musica == "":
		parar_musica()
		return
		
	var nova_faixa = load(caminho_da_musica)
	if audio_player.stream != nova_faixa:
		audio_player.stop()
		audio_player.stream = nova_faixa
		audio_player.play()

func parar_musica():
	if audio_player and audio_player.playing:
		audio_player.stop()
