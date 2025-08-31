extends KinematicBody2D

var health = 1
var is_dead = false

var player = null
var player_detect_range_x = 70
var player_detect_range_y = 20

var is_player_near = false
var hurt_timer = 0.0
var hurt_duration = 0.6

# Ataque
var is_attacking = false
var attack_hit_done = false

onready var sprite = $AnimatedSprite
onready var hurt_area = $HurtArea
onready var cut_area = $CutArea

func _ready():
	randomize()
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

	if player and _player_near():
		is_player_near = true
		_look_at_player()
		if not is_attacking:
			_start_attack()
	else:
		is_player_near = false
		if not is_attacking:
			_set_idle_state()

func _start_attack():
	if is_dead:
		return

	is_attacking = true
	attack_hit_done = false
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

	# Volver a idle si no está muerto
	if not is_dead:
		_set_idle_state()

func _on_cut_area_entered(area):
	if area.is_in_group("PlayerHurtArea") and not attack_hit_done:
		var player_node = area.get_parent()
		player_node.take_damage(20, global_position)
		attack_hit_done = true

func _set_idle_state():
	sprite.play("idleenemy")

func _player_near():
	var horizontal_ok = abs(position.x - player.position.x) <= player_detect_range_x
	var vertical_ok = abs(position.y - player.position.y) <= player_detect_range_y
	return horizontal_ok and vertical_ok

func _look_at_player():
	if player.position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

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
	sprite.play("deadenemy")
	hurt_area.monitoring = false
	cut_area.monitoring = false
	set_collision_layer(0)
	set_collision_mask(0)
