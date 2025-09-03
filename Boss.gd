extends KinematicBody2D

var health = 5
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
var attack_cooldown = 1.0  # Tiempo en segundos entre ataques
var attack_cooldown_timer = 0.0  # Temporizador de enfriamiento

onready var sprite = $AnimatedSprite
onready var hurt_area = $HurtArea
onready var cut_area = $CutArea
onready var health_bar = $HealthBar  # Referencia a la barra de vida

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

	# Inicializamos la barra de vida
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta):
	if is_dead:
		return

	# Actualizamos el temporizador de enfriamiento
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	if hurt_timer > 0:
		hurt_timer -= delta
		if hurt_timer <= 0 and is_player_near and not is_attacking:
			sprite.play("cutenemy")
		return

	if player and _player_near():
		is_player_near = true
		if not is_attacking and attack_cooldown_timer <= 0:  # Solo ataca si el enfriamiento ha pasado
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

	# Establecer el temporizador de enfriamiento
	attack_cooldown_timer = attack_cooldown

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

# Cambié la lógica de recibir daño para que el boss ataque después de recibir daño
func take_damage(attacker):
	if is_dead:
		return
	health -= 1
	hurt_timer = hurt_duration
	sprite.play("hurtenemy")

	# Actualizar la barra de vida
	health_bar.value = health  # Reducir el valor de la barra

	# Ataque al jugador después de recibir daño (si no está en enfriamiento)
	if player and _player_near() and not is_attacking and attack_cooldown_timer <= 0:
		_start_attack()

	if health <= 0:
		die()

func die():
	is_dead = true
	sprite.play("deadenemy")
	hurt_area.monitoring = false
	cut_area.monitoring = false
	set_collision_layer(0)
	set_collision_mask(0)

	# Desaparecer la barra de vida cuando el jefe muere
	health_bar.queue_free()
