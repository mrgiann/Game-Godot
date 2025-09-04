extends KinematicBody2D

var walk_speed = 130
var run_speed = 230
var jump_force = -300
var gravity = 900
var roll_speed = 180

var velocity = Vector2()
var is_attacking = false
var is_in_special_state = false
var is_shielding = false
var was_moving_during_shield = false
var is_hurt = false  
var is_dead = false  
var is_rolling = false

var sprite
var already_hit_enemies = []

# Combo
var left_attack_sequence = ["cut", "cut3", "cut4"]
var left_attack_index = 0

# Vida
var max_health = 100
var current_health = 100
var health_bar

# Cooldown de daño
var damage_cooldown = 0.5
var damage_timer = 0.0

func _ready():
	add_to_group("Player") 
	sprite = get_node("AnimatedSprite")
	sprite.play("idle")
	sprite.flip_h = true
	$AttackArea.add_to_group("PlayerAttack")
	health_bar = get_node("HealthBar")
	update_health_bar()
	$HurtArea.monitoring = true
	$HurtArea.monitorable = true
	$HurtArea.add_to_group("PlayerHurtArea")

func _physics_process(delta):
	if damage_timer > 0:
		damage_timer -= delta

	if is_dead:
		velocity = Vector2.ZERO
		return

	velocity.y += gravity * delta

	if not is_hurt and not is_rolling:
		handle_input()
		handle_movement()
	elif is_hurt:
		velocity.x = 0  

	velocity = move_and_slide(velocity, Vector2.UP)

	if is_rolling:
		if is_on_wall():
			stop_roll()

	if not is_attacking and not is_in_special_state and not is_hurt and not is_rolling:
		if is_on_floor():
			if velocity.x == 0:
				sprite.play("idle")
			else:
				if Input.is_key_pressed(KEY_SHIFT):
					sprite.play("run")
				else:
					sprite.play("walk")
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
	if is_dead or is_hurt or is_rolling:
		is_in_special_state = is_hurt
		return
	is_in_special_state = false

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
		sprite.play("jump")

	# Escudo
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

	# Roll
	if Input.is_key_pressed(KEY_Z) and not is_attacking and not is_rolling and is_on_floor():
		start_roll()
		return

	# Ataques
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		if is_on_floor():
			perform_left_attack()
		else:
			perform_attack("jumpcut")

	elif Input.is_mouse_button_pressed(BUTTON_RIGHT) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		if is_on_floor():
			perform_attack("cut2")
		else:
			perform_attack("jumpcut")

	elif Input.is_key_pressed(KEY_X) and not is_attacking:
		if is_shielding:
			is_shielding = false
			was_moving_during_shield = false
			sprite.play("idle")
		if is_on_floor():
			perform_attack("cutkick")
		else:
			perform_attack("jumpcut")

func handle_movement():
	if is_hurt or is_dead or is_rolling:
		return
	var dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1

	var current_speed = walk_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = run_speed
	elif Input.is_key_pressed(KEY_CONTROL):
		current_speed *= 0.5

	velocity.x = dir * current_speed

	if dir != 0:
		sprite.flip_h = dir < 0

func start_roll():
	is_rolling = true
	is_in_special_state = true
	var dir = -1 if sprite.flip_h else 1
	velocity.x = dir * roll_speed
	sprite.play("roll")
	yield(sprite, "animation_finished")
	stop_roll()

func stop_roll():
	is_rolling = false
	is_in_special_state = false
	velocity.x = 0
	if is_on_floor():
		sprite.play("idle")
	else:
		sprite.play("jump")

func perform_attack(anim_name):
	if is_hurt or is_dead or is_rolling:
		return
	is_attacking = true
	already_hit_enemies.clear()
	sprite.play(anim_name)
	yield(sprite, "animation_finished")
	is_attacking = false

func perform_left_attack():
	var attack_name = left_attack_sequence[left_attack_index]
	perform_attack(attack_name)
	left_attack_index += 1
	if left_attack_index >= left_attack_sequence.size():
		left_attack_index = 0

func update_health_bar():
	health_bar.value = current_health

func take_damage(amount, enemy_position = null):
	if is_hurt or is_dead or damage_timer > 0:
		return

	damage_timer = damage_cooldown

	if is_shielding:
		if enemy_position != null:
			var facing_left = sprite.flip_h
			var enemy_on_left = enemy_position.x < global_position.x
			if (facing_left and enemy_on_left) or (not facing_left and not enemy_on_left):
				return

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

# =========================
# Función agregada para curar vida
# =========================
func heal(amount):
	if is_dead:
		return
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	update_health_bar()
