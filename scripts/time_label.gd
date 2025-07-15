extends Label

func _ready():
	update_time()

func update_time():
	var tiempo_actual = Time.get_time_dict_from_system()  # Obtener hora actual
	var hora_formateada = "%02d:%02d" % [tiempo_actual.hour, tiempo_actual.minute]
	text = hora_formateada  # Actualizar texto del Label
	#print("Hora actual: ", hora_formateada)  Imprimir en consola

func _on_timer_timeout() -> void:
	update_time()	
	
