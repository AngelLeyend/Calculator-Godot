extends ScrollContainer
@onready var LogrosContainer = $LogrosContainer
@onready var SingleLogroContainer = preload("res://scenes/single_logro_container.tscn")


signal show_logro_popup(logro_data)  # Señal para mostrar el popup con los datos del logro

func _ready():
	# print(LogrosContainer)
	# print(SingleLogroContainer)
	populate_logros_container(LogrosContainer)


func populate_logros_container(logros_container: Control):
	# Cargar los logros desde la función load_logros
	var logros = Archivements.load_logros()
	
	# Ruta de la escena SingleLogroContainer
	
	
	# Limpiar el contenedor antes de agregar nuevos logros
	#logros_container.clear_children()
	
	# Iterar sobre los logros y crear instancias de SingleLogroContainer
	for logro in logros:
		var logro_instance = SingleLogroContainer.instantiate()
		
		# Configurar el LogroLabel con el nombre del logro
		var logro_label = logro_instance.get_node("LogroLabel")
		logro_label.text = logro["name"]
		
		# Configurar el LogroButton según el estado "unlocked"
		var logro_button = logro_instance.get_node("LogroButton")
		logro_button.disabled = not logro["unlocked"]
		
		# Agregar la instancia al contenedor
		logros_container.add_child(logro_instance)

		# Conectar el botón para mostrar el popup con los datos del logro
		logro_button.pressed.connect(Callable(self, "_on_logro_button_pressed").bind(logro))



		# print(logro_label.text)
		
		
		logros_container.add_child(logro_instance)


func _on_logro_button_pressed(logro):
	# Llamar al popup para mostrar los datos del logro
	# print(logro)
	if logro["unlocked"]:
		# print("Logro desbloqueado: ", logro["name"])
		show_logro_popup.emit(logro)  # Emitir la señal con los datos del logro


		
func clear_children():
	for child in get_children():
		child.queue_free()
