extends AnimatedSprite

var is_open = false
var player_in_area = false
var heal_amount = 20

func _ready():
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")

func _process(delta):
	if player_in_area and not is_open:
		if Input.is_key_pressed(KEY_E):
			open_chest()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false

func open_chest():
	if is_open:
		return

	is_open = true
	play("default")  # animación del cofre

	# Esperar a que termine la animación antes de curar
	yield(self, "animation_finished")

	# Dar vida al jugador
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].heal(heal_amount)
