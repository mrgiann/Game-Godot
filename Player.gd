extends KinematicBody2D

var speed = 200
var jump_force = -300
var gravity = 900

var velocity = Vector2()
var is_attacking = false
var is_in_special_state = false
var is_shielding = false
var was_moving_during_shield = false
var is_hurt = false  
var is_dead = false  

var sprite
var already_hit_enemies = []

# Vida
var max_health = 100
var current_health = 100
var health_bar

func _ready():
	sprite = get_node("AnimatedSprite")
	sprite.play("idle")

	add_to_group("Player")   # 👈 ahora tu player está en el grupo "Player"
	
	$AttackArea.add_to_group("PlayerAttack")
	
	health_bar = get_node("HealthBar")
	update_health_bar()
	
	$HurtArea.monitoring = true
	$HurtArea.monitorable = true
	$HurtArea.add_to_group("PlayerHurtArea")


func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		return

	velocity.y += gravity * delta

	if not is_hurt:
		handle_input()
		handle_movement()
	else:
		velocity.x = 0  

	velocity = move_and_slide(velocity, Vector2.UP)

	if not is_attacking and not is_in_special_state and not is_hurt:
		if is_on_floor():
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("run")
		else:
			sprite.play("jump")

	if is_attacking:
		var attack_area = $AttackArea
		var overlapping_areas = attack_area.get_overlapping_areas()
		for area in overlapping_areas:
			if area.is_in_group("EnemyHurtBox"):
				var enemy = area.get_parent()
				if not enemy in already_hit_enemies:
					enemy.take_damage(self)
					already_hit_enemies.append(enemy)

func handle_input():
	if is_dead:
		return  

	if is_hurt:
		is_in_special_state = true
		return
	is_in_special_state = false

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
		sprite.play("jump")

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

	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		perform_attack("cut")
	elif Input.is_mouse_button_pressed(BUTTON_RIGHT) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		perform_attack("cut2")

func handle_movement():
	if is_hurt or is_dead:
		return
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
	if is_hurt or is_dead:
		return
	is_attacking = true
	already_hit_enemies.clear()
	sprite.play(anim_name)
	yield(sprite, "animation_finished")
	is_attacking = false

func update_health_bar():
	health_bar.value = current_health

# --- Aquí está la lógica del escudo ---
func take_damage(amount, enemy_position = null):
	if is_hurt or is_dead:
		return
	
	# Si está escudando
	if is_shielding:
		if enemy_position != null:
			var facing_left = sprite.flip_h
			var enemy_on_left = enemy_position.x < global_position.x
			# Solo bloquea si el escudo está mirando hacia el enemigo
			if (facing_left and enemy_on_left) or (not facing_left and not enemy_on_left):
				return  # Inmune al daño si escudo está en la dirección correcta

	current_health -= amount
	if current_health <= 0:
		current_health = 0
		update_health_bar()
		die()
		return
	update_health_bar()
	is_hurt = true
	sprite.play("hurt")
	yield(sprite, "animation_finished")
	is_hurt = false

func die():
	is_dead = true
	sprite.play("dead")
