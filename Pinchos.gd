extends Area2D

# Configurar el daño de los pinchos
var spike_damage = 100  # El daño que causan los pinchos

# Llamado cuando un área entra en la zona de los pinchos
func _on_Spike_area_entered(area):
	if area.is_in_group("PlayerHurtArea"):  # Verificar si el área que tocó es el área de daño del jugador
		var player = area.get_parent()
		player.take_damage(spike_damage, global_position)  # Infligir daño al jugador

# Llamado cuando la escena está lista
func _ready():
	# Asegurarnos de que el área esté monitoreando colisiones
	monitoring = true
	connect("area_entered", self, "_on_Spike_area_entered")  # Conectar la señal de entrada de área a la función
