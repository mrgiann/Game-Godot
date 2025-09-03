extends Node2D

# Referencias a los nodos
onready var animated_sprite = $AnimatedSprite
onready var timer = $Timer
onready var cutarea = $CutArea  # Referencia a CutArea (Area2D)

# Tiempo entre las animaciones
var time_1_to_2 = 0.5  # Tiempo entre ida y vuelta
var time_2_to_3 = 0.5  # Tiempo entre vuelta e idle
var time_3_to_1 = 2  # Tiempo entre idle e ida

# Controlador para las animaciones
var current_animation = 0

# Variable para controlar el daño al jugador
var is_damaging_player = false

func _ready():
	# Configurar el temporizador
	timer.wait_time = time_3_to_1  # Empieza con el tiempo para la animación idle
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start()

	# Asegurarse de que CutArea esté en modo monitoring
	cutarea.monitoring = true

	# Comenzamos con la animación idle
	animated_sprite.play("idle")

func _on_Timer_timeout():
	match current_animation:
		0:
			# Cambiar a la animación de ida
			animated_sprite.play("ida")
			current_animation = 1  # Cambiar al siguiente paso
			timer.wait_time = time_1_to_2  # Tiempo entre ida y vuelta
			is_damaging_player = true  # Habilitar daño al jugador durante la animación ida

		1:
			# Cambiar a la animación de vuelta
			animated_sprite.play("vuelta")
			current_animation = 2  # Cambiar al siguiente paso
			timer.wait_time = time_2_to_3  # Tiempo entre vuelta e idle
			is_damaging_player = true  # Habilitar daño al jugador durante la animación vuelta

		2:
			# Cambiar a la animación idle
			animated_sprite.play("idle")
			current_animation = 0  # Volver al principio
			timer.wait_time = time_3_to_1  # Tiempo entre idle e ida
			is_damaging_player = false  # Deshabilitar daño al jugador durante la animación idle

	# Reiniciar el temporizador con el nuevo tiempo
	timer.start()

func _process(delta):
	# Si la animación está en "ida" o "vuelta", y la trampa puede dañar al jugador
	if is_damaging_player:
		# Verificar si el área de corte está tocando al jugador
		var areas = cutarea.get_overlapping_areas()
		for area in areas:
			if area.is_in_group("PlayerHurtArea"):  # Comprobar si es el área de daño del jugador
				area.get_parent().take_damage(20, global_position)  # Infligir daño al jugador
