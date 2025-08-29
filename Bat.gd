extends KinematicBody2D

var speed = 120
var player = null
var min_distance = 10  # distancia mínima para quedarse quieto cerca del jugador
var offset = Vector2(0, -30)  # posición relativa arriba del jugador

onready var sprite = $AnimatedSprite

func _ready():
	print("✅ Bat _ready() ejecutado")

	player = get_tree().get_root().find_node("Player", true, false)
	if not player:
		print("❌ No se encontró al Player")
		return
	else:
		print("✅ Player encontrado: ", player.name)

	# Reproducir la animación por defecto
	sprite.play()
	print("🎞️ Reproduciendo animación por defecto")

func _physics_process(_delta):
	if not player:
		return

	var target_pos = player.global_position + offset
	var distance = global_position.distance_to(target_pos)

	if distance > min_distance:
		var direction = (target_pos - global_position).normalized()
		var velocity = direction * speed

		# Girar sprite horizontalmente si se mueve
		sprite.flip_h = direction.x < 0

		move_and_slide(velocity)
	else:
		# Muy cerca del jugador: quedarse flotando
		move_and_slide(Vector2.ZERO)
