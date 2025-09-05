extends Control

# Referencias a nodos de UI
onready var pause_menu = self
onready var resume_button = $ResumeButton
onready var restart_button = $RestartButton
onready var quit_button = $QuitButton

func _ready():
	# De entrada, ocultamos el menú de pausa
	pause_menu.visible = false

	# Establece el modo de pausa para que se procese incluso si el juego está pausado
	pause_menu.pause_mode = Node.PAUSE_MODE_PROCESS

	# Asegúrate de que cada botón también procese en pausa
	resume_button.pause_mode = Node.PAUSE_MODE_PROCESS
	restart_button.pause_mode = Node.PAUSE_MODE_PROCESS
	quit_button.pause_mode = Node.PAUSE_MODE_PROCESS

	# Conecta señales de los botones
	resume_button.connect("pressed", self, "_on_resume_pressed")
	restart_button.connect("pressed", self, "_on_restart_pressed")
	quit_button.connect("pressed", self, "_on_quit_pressed")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	get_tree().paused = true
	pause_menu.visible = true

func resume_game():
	get_tree().paused = false
	pause_menu.visible = false

func _on_resume_pressed():
	resume_game()

func _on_restart_pressed():
	resume_game()  # Asegúrate de que el juego esté despausado
	get_tree().paused = false  # Despausa el juego
	resume_button.disconnect("pressed", self, "_on_resume_pressed")
	restart_button.disconnect("pressed", self, "_on_restart_pressed")
	quit_button.disconnect("pressed", self, "_on_quit_pressed")
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()
