extends KinematicBody2D

# Variables
var health = 1
var is_dead = false
var attack_cooldown = 2.0  # segundos entre flechas
var attack_timer = 0.0

var player = null
onready var sprite = $AnimatedSprite
onready var arrow_spawn = $ArrowSpawn
onready var hurt_area = $HurtArea   # Area2D que detecta golpes

# Path de la flecha
var arrow_scene = preload("res://Arrow.tscn")
var arrow_speed = 250   # velocidad de las flechas

func _ready():
	sprite.play("cutenemy")
	player = get_tree().get_root().find_node("Player", true, false)

	# Conectar señal del HurtArea
	hurt_area.connect("area_entered", self, "_on_HurtArea_entered")
	hurt_area.connect("body_entered", self, "_on_HurtArea_entered")

func _physics_process(delta):
	if is_dead:
		return

	if player:
		_look_at_player()

		# Control del tiempo de ataque
		attack_timer -= delta
		if attack_timer <= 0:
			_shoot_arrow()
			attack_timer = attack_cooldown

func _look_at_player():
	if player.position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _shoot_arrow():
	var arrow = arrow_scene.instance()
	arrow.position = arrow_spawn.global_position

	# Dirección de la flecha
	if sprite.flip_h:
		arrow.direction = Vector2(-1, 0)
	else:
		arrow.direction = Vector2(1, 0)

	# Pasamos velocidad
	arrow.speed = arrow_speed

	get_tree().current_scene.add_child(arrow)

# Cuando entra algo en el hurt area
func _on_HurtArea_entered(area_or_body):
	if is_dead:
		return

	if area_or_body.is_in_group("PlayerAttack"):
		# Solo dañar si el jugador está atacando
		var player = area_or_body.get_parent()
		if player.is_attacking:
			take_damage(player)



func take_damage(attacker):
	if is_dead:
		return
	health -= 1
	if health <= 0:
		die()

func die():
	is_dead = true
	sprite.play("deadenemy")
	set_collision_layer(0)
	set_collision_mask(0)
