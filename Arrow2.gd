extends Area2D

var speed = 200
var direction = Vector2.ZERO
var damage = 15
var max_range = 800  # Rango máximo en píxeles
var start_position = Vector2.ZERO

func _ready():
	connect("area_entered", self, "_on_area_entered")
	start_position = position  # Guardamos la posición inicial de la flecha

func _physics_process(delta):
	position += direction * speed * delta
	
	# Comprobar si se ha alcanzado el rango máximo
	if position.distance_to(start_position) >= max_range:
		queue_free()  # Eliminar la flecha cuando se alcanza el rango

func _on_area_entered(area):
	if area.is_in_group("PlayerHurtArea"):
		var player_node = area.get_parent()
		player_node.take_damage(damage, global_position)
		queue_free()  # Elimina la flecha al impactar
