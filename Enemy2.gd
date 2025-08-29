extends KinematicBody2D

var speed = 50
var gravity = 800
var velocity = Vector2.ZERO
var player = null
var spawn_finished = false
var vision_range = 100  # rango de visión horizontal

onready var sprite = $AnimatedSprite

func _ready():
	print("✅ _ready() ejecutado")

	player = get_tree().get_root().find_node("Player", true, false)
	if not player:
		print("❌ No se encontró al Player")
		return
	else:
		print("✅ Player encontrado: ", player.name)

	sprite.play("spawnenemy2")

	var anim_name = "spawnenemy2"
	var frame_count = sprite.frames.get_frame_count(anim_name)
	var fps = sprite.frames.get_animation_speed(anim_name)

	var anim_duration = 1.0
	if fps > 0:
		anim_duration = frame_count / fps

	yield(get_tree().create_timer(anim_duration), "timeout")

	sprite.play("walkenemy2")
	spawn_finished = true

func _physics_process(delta):
	if not spawn_finished or not player:
		return

	# Aplicar gravedad
	velocity.y += gravity * delta

	var y_diff = abs(player.global_position.y - global_position.y)
	var x_diff = abs(player.global_position.x - global_position.x)

	if y_diff < 20 and x_diff < vision_range:
		# Player está en la misma plataforma y dentro de su rango
		var dir_x = player.global_position.x - global_position.x
		velocity.x = sign(dir_x) * speed
		sprite.flip_h = velocity.x < 0
	else:
		# Muy lejos o no en la misma capa
		velocity.x = 0

	# Mover con gravedad
	velocity = move_and_slide(velocity, Vector2.UP)
