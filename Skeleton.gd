extends KinematicBody2D

var speed = 30
var move_range = 50
var start_position = Vector2.ZERO
var direction = Vector2.ZERO

var is_idle = false
var idle_time = 0.0
var idle_timer = 0.0
var move_time = 0.0
var move_timer = 0.0

var health = 5
var is_dead = false

var player = null
var player_detect_range_x = 80
var player_detect_range_y = 20
var lost_player_timer = 0.0
var lost_player_delay = 4.0

var is_player_near = false
var hurt_timer = 0.0
var hurt_duration = 0.3

# Ataque
var is_attacking = false
var attack_hit_done = false

onready var sprite = $AnimatedSprite
onready var hurt_area = $HurtArea
onready var cut_area = $CutArea

func _ready():
	randomize()
	start_position = position
	_set_idle_state()

	hurt_area.monitoring = true
	hurt_area.monitorable = true
	hurt_area.add_to_group("EnemyHurtBox")

	# Hitbox desactivado al inicio
	cut_area.monitoring = false
	cut_area.monitorable = false
	cut_area.add_to_group("EnemyAttack")
	cut_area.connect("area_entered", self, "_on_cut_area_entered")

	add_to_group("Enemies")
	player = get_tree().get_root().find_node("Player", true, false)

func _physics_process(delta):
	if is_dead:
		return

	if hurt_timer > 0:
		hurt_timer -= delta
		if hurt_timer <= 0 and is_player_near and not is_attacking:
			sprite.play("cutenemy")
		return

	if player:
		if _player_near():
			is_player_near = true
			_look_at_player()
			if not is_attacking:
				_start_attack()
			lost_player_timer = 0.0
			return
		else:
			if is_player_near:
				lost_player_timer += delta
				if lost_player_timer >= lost_player_delay:
					is_player_near = false
					lost_player_timer = 0.0
					_set_idle_state()

	if is_idle:
		idle_timer += delta
		if idle_timer >= idle_time:
			_set_move_state()
	else:
		move_timer += delta
		var velocity_move = direction * speed
		move_and_slide(velocity_move, Vector2.UP)

		var dist = position.x - start_position.x
		if abs(dist) >= move_range:
			_reverse_direction()

		if move_timer >= move_time:
			_set_idle_state()

func _start_attack():
	is_attacking = true
	attack_hit_done = false
	direction = Vector2.ZERO
	sprite.play("cutenemy")

	# Esperar hasta el frame de golpe
	yield(get_tree().create_timer(0.2), "timeout")

	# Solo un golpe
	if player and _player_near() and not attack_hit_done:
		player.take_damage(20, global_position)
		attack_hit_done = true

	# Fin de ataque
	yield(sprite, "animation_finished")
	is_attacking = false


func _on_cut_area_entered(area):
	if area.is_in_group("PlayerHurtArea") and not attack_hit_done:
		var player_node = area.get_parent()
		player_node.take_damage(20, global_position)
		attack_hit_done = true

func _set_idle_state():
	is_idle = true
	idle_time = rand_range(1.0, 2.0)
	idle_timer = 0.0
	direction = Vector2.ZERO
	sprite.play("idleenemy")

func _set_move_state():
	is_idle = false
	move_time = rand_range(4.0, 7.0)

	var dist = position.x - start_position.x
	if dist <= -move_range:
		direction = Vector2(1, 0)
	elif dist >= move_range:
		direction = Vector2(-1, 0)
	else:
		if randf() < 0.5:
			direction = Vector2(-1, 0)
		else:
			direction = Vector2(1, 0)

	sprite.flip_h = direction.x < 0
	sprite.play("walkenemy")

func _reverse_direction():
	direction = Vector2(-direction.x, 0)
	sprite.flip_h = direction.x < 0

func _player_near():
	var horizontal_ok = abs(position.x - player.position.x) <= player_detect_range_x
	var vertical_ok = abs(position.y - player.position.y) <= player_detect_range_y
	return horizontal_ok and vertical_ok

func _look_at_player():
	if player.position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	direction = Vector2.ZERO

func take_damage(attacker):
	if is_dead:
		return
	health -= 1
	hurt_timer = hurt_duration
	sprite.play("hurtenemy")
	if health <= 0:
		die()

func die():
	is_dead = true
	direction = Vector2.ZERO
	sprite.play("deadenemy")
	hurt_area.monitoring = false
	cut_area.monitoring = false
	set_collision_layer(0)
	set_collision_mask(0)
