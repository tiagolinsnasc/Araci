extends Control

var cards = [
	preload("res://n_assets/n_cuts/final/s1.png"),
	preload("res://n_assets/n_cuts/final/s2.png"),
	preload("res://n_assets/n_cuts/final/s3.png"),
	preload("res://n_assets/n_cuts/final/s4.png"),
	preload("res://n_assets/n_cuts/final/s5.png"),
	preload("res://n_assets/n_cuts/final/s6.png"),
	preload("res://n_assets/n_cuts/final/s7.png")
]
func get_sentence():
	var evidence_percent = 0
	if Globals.stat_disponible_evidences > 0:
		evidence_percent = int(round((float(Globals.coins) / float(Globals.stat_disponible_evidences)) * 100.0))
		
	if evidence_percent < 30:
		return """Condenação leve (%s%% das evidências)
				"Victor Grand escapa com punição branda"
				Com poucas provas, o tribunal aplicou apenas multas simbólicas e restrições menores.""" % int(round(evidence_percent))
	elif evidence_percent < 70:
		return """Condenação moderada (%s%% das evidências)
				"Victor Grand sofre, mas ainda mantém poder"
				Com provas razoáveis, o tribunal aplicou 10 anos de prisão e multas pesadas.""" % int(round(evidence_percent))
	else:
		return """Condenação severa (%s%% das evidências)
			"Victor Grand pega pena pesada no tribunal"
			Com base em provas robustas, mas não completas, o tribunal condenou Victor Grand a 20 anos de prisão e ao pagamento de multas milionárias. Apesar de não ter sido a pena máxima, especialistas afirmam que a decisão representa um duro golpe contra a VGR Holdings e suas práticas ilegais.""" % int(round(evidence_percent))
	
		

var texts = [
	"Em uma ação conjunta desnecadeada pela jovem Araci, autoridades ambientais e policiais, Victor Grand, magnata e fundador da VGR Holdings, foi detido nesta manhã sob acusações graves de crimes ambientais.",
	
	"As investigações apontam que a corporação estaria envolvida em desmatamento em larga escala, poluição de rios, caça ilegal, mineração clandestina e contrabando de animais silvestres.",
	
	"Segundo os investigadores, a rede de empresas de Grand operava em diversos países, mascarando atividades ilícitas sob o pretexto de desenvolvimento econômico. A prisão marca um dos maiores golpes já desferidos contra o crime ambiental corporativo, e abre caminho para processos que podem redefinir a responsabilidade de grandes conglomerados frente à preservação da natureza.",
	
	"Araci caminha de volta para casa.
	O silêncio da floresta é esperança.
	Onde havia destruição, brotam raízes.
	Mãos se unem para plantar o futuro.
	Rios correm limpos outra vez.
	Animais retornam às margens.
	A comunidade protege o que é seu.
	Educação e vigilância guardam o amanhã.
	Araci sorri. A natureza começa a se recuperar.",
	
	get_sentence(),
	
	"Araci, protagonista de uma jornada marcada pela defesa da natureza, decidiu seguir um novo caminho. Motivada pelas experiências vividas durante a luta contra crimes ambientais, ela ingressou na universidade e, após anos de dedicação, conquistou o diploma de Bacharel em Direito.",
	Globals.get_stats_text(),
    "Fim"
]

var left :Vector2 = Vector2(40, 40)
var right :Vector2 = Vector2(300, 40)
var center :Vector2 = Vector2(450, 300)
var left_top :Vector2 = Vector2(35, 35)
var positions = [
	right, 
	left, 
	left, 
	right,
	right,
	left,
	left_top,
	center
]

var current_index = 0

func _ready():
	show_card(current_index)

func show_card(index):
	# fundo
	$TextureRect.texture = cards[index]
	$ColorRect.modulate = Color(0,0,0,1)

	var tween_bg = create_tween()
	tween_bg.tween_property($ColorRect, "modulate:a", 0.0, 1.0)

	# texto principal
	$Label.text = texts[index]
	$Label.position = positions[index]
	$Label.modulate = Color(0,0,0,0)

	#Texto de instruções
	$Label_instructions.position = Vector2(220,340)
	$Label_instructions.modulate = Color(0,0,0,0)
	
	# fade-in com atraso
	var tween_text = create_tween()
	tween_text.tween_interval(0.5) # atraso de meio segundo
	tween_text.tween_property($Label, "modulate:a", 1.0, 1.0)
	tween_text.tween_property($Label_instructions, "modulate:a", 1.0, 1.0)

func _input(event):
	if event.is_action_pressed("ui_accept"): # espaço
		if current_index < cards.size() - 1:
			current_index += 1
			show_card(current_index)
		else:
			queue_free()
	elif event.is_action_pressed("ui_cancel"): # esc
		queue_free()
