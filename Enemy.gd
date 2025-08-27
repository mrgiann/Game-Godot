extends KinematicBody2D

# Movimiento y patrullaje
var speed = 30
var direction = Vector2(1, 0)
var patrol_distance = 30
var start_position = Vector2()

var idle_time = 2.0
var timer = 0.0
var is_idle = false
var move_count = 0
var max_moves = 0

# Delay inicial antes de empezar a patrullar
var start_delay = 0.0
var delay_timer = 0.0
var started = false

# Vida y estado
var health = 3
var is_dead = false
var is_aggressive = false
var is_attacking = false
var player_target = null  # Guarda al jugador que lo atacó

# Distancia para iniciar ataque
var attack_range = 40

func _ready():
	randomize()
	start_position = position
	$AnimatedSprite.play("walkenemy")
	$AnimatedSprite.flip_h = false

	max_moves = randi() % 5 + 2
	start_delay = rand_range(0.0, 3.0)
	delay_timer = 0.0
	started = false

	add_to_group("Enemies")

	# Conectar área de daño
	$HurtArea.connect("body_entered", self, "_on_HurtArea_body_entered")

	# Conectar señal para saber cuándo termina la animación de ataque
	$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")

func _physics_process(delta):
	if is_dead:
		return

	# Esperar delay inicial
	if not started:
		delay_timer += delta
		if delay_timer >= start_delay:
			started = true
		else:
			return

	# Si está agresivo, mirar al jugador y atacar si está cerca
	if is_aggressive and player_target != null:
		var dir_to_player = (player_target.global_position - global_position).normalized()
		$AnimatedSprite.flip_h = dir_to_player.x < 0

		var dist_to_player = position.distance_to(player_target.global_position)

		if not is_attacking:
			if dist_to_player <= attack_range:
				$AnimatedSprite.play("cutenemy")
				is_attacking = true
			elif $AnimatedSprite.animation != "idleenemy":
				$AnimatedSprite.play("idleenemy")
		return

	# Patrullaje
	timer += delta

	if is_idle:
		if timer >= idle_time:
			is_idle = false
			timer = 0
			move_count = 0
			max_moves = randi() % 5 + 2
			$AnimatedSprite.play("walkenemy")
	else:
		var velocity = direction * speed
		move_and_slide(velocity)

		if position.distance_to(start_position) >= patrol_distance:
			direction = -direction
			$AnimatedSprite.flip_h = direction.x < 0
			move_count += 1

			if move_count >= max_moves:
				is_idle = true
				timer = 0
				$AnimatedSprite.play("idleenemy")

func _on_HurtArea_body_entered(body):
	if is_dead or is_attacking:
		return

	if body.is_in_group("PlayerAttack"):
		var attacker = body.get_owner()
		if attacker != null and attacker.is_in_group("Player"):
			take_damage(attacker)

func take_damage(from_player):
	if is_dead:
		return

	health -= 1
	player_target = from_player
	is_aggressive = true

	if health <= 0:
		die()
		return

	started = false
	$AnimatedSprite.play("hurtenemy")
	yield($AnimatedSprite, "animation_finished")

	$AnimatedSprite.play("cutenemy")
	yield($AnimatedSprite, "animation_finished")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attackenemy":
		is_attacking = false
		if is_aggressive and player_target != null:
			$AnimatedSprite.play("idleenemy")

func die():
	is_dead = true
	$AnimatedSprite.play("deadenemy")
	set_collision_layer(0)
	set_collision_mask(0)
	set_physics_process(false)

	yield($AnimatedSprite, "animation_finished")
	queue_free()
