extends Control

# Referencias a los botones
onready var play_button = $VBoxContainer/PlayButton
onready var exit_button = $VBoxContainer/ExitButton

func _ready():
	# Conectar las señales de los botones
	play_button.connect("pressed", self, "_on_PlayButton_pressed")
	exit_button.connect("pressed", self, "_on_ExitButton_pressed")

# Funciones de cada botón
func _on_PlayButton_pressed():
	print("Play button pressed!")
	# Aquí puedes cargar la siguiente escena del juego, por ejemplo:
	get_tree().change_scene("res://Juego.tscn")

func _on_ExitButton_pressed():
	print("Exit button pressed!")
	# Cerrar el juego
	get_tree().quit()
