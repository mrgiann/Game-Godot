# PlayerData.gd
extends Node

# Variables globales del jugador
var walk_speed = 130
var run_speed = 230
var jump_force = -300
var roll_speed = 180

var current_health = 100
var max_health = 100
var is_dead = false
var is_hurt = false
var position = Vector2()

# Esta función se llama cuando se necesita restablecer los valores del jugador
func reset():
	walk_speed = 130
	run_speed = 230
	jump_force = -300
	roll_speed = 180
	current_health = max_health
	is_dead = false
	is_hurt = false
	position = Vector2()
