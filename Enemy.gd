extends KinematicBody2D

var speed = 30
var direction = Vector2(1, 0)
var patrol_distance = 30 # distance to patrol
var start_position = Vector2()

var idle_time = 2.0
var timer = 0.0
var is_idle = false

var move_count = 0  # counts how many times direction changed
var max_moves = 0   # how many moves before idle

var start_delay = 0.0  # delay before starting movement
var delay_timer = 0.0
var started = false

func _ready():
	randomize()  # seed RNG once
	start_position = position
	$AnimatedSprite.play("walkenemy")
	$AnimatedSprite.flip_h = false

	max_moves = randi() % 5 + 2  # random between 2 and 6 moves

	# Use rand_range(min, max) to get a random float between 0 and 3 seconds
	start_delay = rand_range(0.0, 3.0)
	delay_timer = 0.0
	started = false

func _physics_process(delta):
	if not started:
		delay_timer += delta
		if delay_timer >= start_delay:
			started = true
		else:
			return

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
