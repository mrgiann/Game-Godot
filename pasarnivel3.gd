extends Area2D

# Este método solo se ejecutará si el cuerpo que entra es un KinematicBody2D (o el tipo que elijas)
func _ready():
	# Verificar si la señal 'body_entered' ya está conectada
	if not is_connected("body_entered", self, "_on_body_entered"):
		connect("body_entered", self, "_on_body_entered")

# Método llamado cuando un cuerpo entra en el área
func _on_body_entered(body):
	if body is KinematicBody2D:  # Verificar si es el jugador (o el cuerpo que necesitas)
		# Llamar a la función para transferir la información del jugador
		PlayerData.current_health = body.current_health
		PlayerData.position = body.position
		# Cambiar la escena
		get_tree().change_scene("res://level3.tscn")
