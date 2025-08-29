extends Area2D

export var heal_amount = 20  # Vida que recupera

func _ready():
	# Conecto la señal del área (cuando algo entra en el área)
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	# Verificamos que el objeto que entra sea el Player
	if body.is_in_group("Player"):
		# Curamos solo si no está al máximo
		if body.current_health < body.max_health:
			body.current_health += heal_amount
			if body.current_health > body.max_health:
				body.current_health = body.max_health
			body.update_health_bar()
		# Después de curar, eliminamos el corazón
		queue_free()
