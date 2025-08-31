extends Area2D

var speed = 200
var direction = Vector2.ZERO
var damage = 10

func _ready():
	connect("area_entered", self, "_on_area_entered")

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_entered(area):
	if area.is_in_group("PlayerHurtArea"):
		var player_node = area.get_parent()
		player_node.take_damage(damage, global_position)
		queue_free()  # elimina la flecha al impactar
