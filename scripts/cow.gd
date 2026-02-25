extends PeacefulAnimalsBase
#Nome já em PeacefulAnimalsBase (Preenchido no inspetor, na instância padrão)
@onready var cow_sound: AudioStreamPlayer2D = $cow_sound

func _ready():
	mooing()

func mooing():
	if cow_sound.stream:
		cow_sound.play()

	# escolhe um intervalo aleatório entre 2 e 20 segundos
	var intervalo = randf_range(2.0, 20.0)

	# cria um timer que dispara depois desse intervalo
	var timer = get_tree().create_timer(intervalo)
	timer.timeout.connect(mooing)
