extends KinematicBody2D

var speed = 200
var jump_force = -400
var gravity = 900

var velocity = Vector2()
var is_attacking = false
var is_in_special_state = false
var is_shielding = false
var was_moving_during_shield = false

var sprite

func _ready():
	sprite = get_node("AnimatedSprite")
	sprite.play("idle")
	
	# Aseguramos que el área de ataque esté en el grupo correcto
	$AttackArea.add_to_group("PlayerAttack")

func _physics_process(delta):
	velocity.y += gravity * delta

	handle_input()
	handle_movement()

	velocity = move_and_slide(velocity, Vector2.UP)

	# Animaciones (si no hay ataque ni estado especial)
	if not is_attacking and not is_in_special_state:
		if is_on_floor():
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("run")
		else:
			sprite.play("jump")

func handle_input():
	is_in_special_state = false

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
		sprite.play("jump")

	# ESCUDO (Ctrl presionado)
	if Input.is_key_pressed(KEY_CONTROL) and not is_attacking:
		var is_moving_now = abs(velocity.x) > 0

		if not is_shielding:
			sprite.play("escudo")
			sprite.frame = 0
			sprite.stop()
			is_shielding = true
			was_moving_during_shield = false
		else:
			if is_moving_now and not was_moving_during_shield:
				sprite.play("escudo")
				was_moving_during_shield = true
			elif not is_moving_now:
				sprite.play("escudo")
				sprite.frame = 0
				sprite.stop()
				was_moving_during_shield = false

		is_in_special_state = true
	else:
		is_shielding = false
		was_moving_during_shield = false

	# HURT (O)
	if Input.is_key_pressed(KEY_O):
		sprite.play("hurt")
		is_in_special_state = true
		is_shielding = false

	# DEAD (K)
	if Input.is_key_pressed(KEY_K):
		sprite.play("dead")
		is_in_special_state = true
		is_shielding = false

	# ATAQUE izquierdo (click izquierdo)
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		perform_attack("cut")

	# ATAQUE derecho (click derecho)
	elif Input.is_mouse_button_pressed(BUTTON_RIGHT) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		perform_attack("cut2")

func handle_movement():
	var dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1

	var current_speed = speed
	if Input.is_key_pressed(KEY_CONTROL):
		current_speed *= 0.5

	velocity.x = dir * current_speed

	if dir != 0:
		sprite.set_flip_h(dir < 0)

func perform_attack(anim_name):
	is_attacking = true
	sprite.play(anim_name)

	# Detectar cuerpos dentro del área de ataque
	var attack_area = $AttackArea
	var overlapping_bodies = attack_area.get_overlapping_bodies()

	for body in overlapping_bodies:
		if body.is_in_group("Enemies"):
			# Pasar self para que el enemigo sepa quién lo atacó
			body.take_damage(self)

	yield(sprite, "animation_finished")
	is_attacking = false
