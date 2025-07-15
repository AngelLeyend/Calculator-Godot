extends Node
# Ruta del json con los logros
var json_path = "res://settings/logros.json"


@onready var NotificationContainer = preload("res://scenes/notification_container.tscn")
var notification_queue: Array = []
var notification_showing: bool = false

signal finished_game

var logros_parsed={ }



func _ready():
	load_logros()
	# print(get_string_date())
	# print("Desbloqueando logro test")
	# unlock_logro("sond_window")
	


func load_logros():
	# Cargar el archivo JSON
	# Verificar si el archivo existe
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		# print("Error: Could not open file at path: " + json_path)
		return []
	
	# Leer contenido del json
	var json_data = file.get_as_text()
	var json_object = JSON.new()
	

	# Parsear el contenido JSON
	json_object.parse(json_data)
	logros_parsed = json_object.data
	# print(logros_parsed)
	file.close()
	
	# Inicializa los campos unlocked y date_unlocked en cada logro
	for logro in logros_parsed:
		if not logro.has("unlocked"):
			logro["unlocked"] = false
		if not logro.has("date_unlocked"):
			logro["date_unlocked"] = ""

	load_logros_progress()

	return logros_parsed




func unlock_logro(logro_id:int):
	var logro_name = "archiv%d_title" % logro_id
	
	for logro in logros_parsed:
		if logro["name"] == logro_name:
			if logro["unlocked"]:
				return
			logro["unlocked"] = true
			logro["date_unlocked"] = get_string_date()
			break

	show_notification(logro_name)
	check_all_logros()
	save_logros_progress()
		
	
		
		
	
func get_string_date():
	var d = Time.get_date_dict_from_system()
	var d_string = "%02d-%02d-%04d"%[d["day"], d["month"], d["year"]]
	return d_string

func show_notification(logro_name:String):
	# Agrega el nombre del logro a la cola de notificaciones
	AudioUIManager.play("unlocked_archv")
	notification_queue.append(logro_name)
	# Si no se está mostrando ninguna notificación, comienza a procesar la cola
	if not notification_showing:
		_process_notification_queue()



func _process_notification_queue():
	# Si la cola está vacía, marca que no hay notificación mostrando y termina
	if notification_queue.size() == 0:
		notification_showing = false
		return
	notification_showing = true
	# Toma el siguiente logro de la cola
	var logro_name = notification_queue.pop_front()
	# Crear una instancia del NotificationContainer
	var notification_instance = NotificationContainer.instantiate()
	# print(notification_instance)
	# Obtener el Label dentro del NotificationContainer
	var notification_label = notification_instance.get_node("PanelContainer/HBoxContainer/VBoxContainer/LogroLabel")
	
	# Configurar el texto del Label con el nombre del logro
	notification_label.text = logro_name
	
	# Agregar la instancia al árbol de nodos
	get_tree().root.call_deferred("add_child", notification_instance)

	# Mostrar la notificación
	notification_instance.show()
	
	# Crear un temporizador para ocultar la notificación después de 3 segundos
	await get_tree().create_timer(3.0).timeout
	
	# Eliminar la notificación del árbol de nodos
	notification_instance.queue_free()
	
	# Procesar la siguiente notificación en la cola
	_process_notification_queue()



func check_all_logros():
	var all_unlocked = true
	for logro in logros_parsed:
		# Ignora el logro final (archiv14_title)
		if logro["name"] == "archiv14_title":
			continue
		if not logro["unlocked"]:
			all_unlocked = false
			break
	
	if all_unlocked:
		# Verifica si el logro final ya está desbloqueado para evitar doble ejecución
		for logro in logros_parsed:
			if logro["name"] == "archiv14_title" and not logro["unlocked"]:
				logro["unlocked"] = true
				logro["date_unlocked"] = get_string_date()
				show_notification("archiv14_title")
				save_logros_progress()
				finished_game.emit() # Solo emite una vez
				SaveManager.update_game_data("game_completed", 1)
				break

# Guarda el progreso de los logros en SaveManager
func save_logros_progress():
	var progress = []
	for logro in logros_parsed:
		progress.append({
			"name": logro["name"],
			"unlocked": logro["unlocked"],
			"date_unlocked": logro.get("date_unlocked", "")
		})
	SaveManager.update_game_data("logros_progress", progress)

# Carga el progreso de los logros desde SaveManager
func load_logros_progress():
	if "logros_progress" in SaveManager.game_data:
		var progress = SaveManager.game_data["logros_progress"]
		for saved_logro in progress:
			for logro in logros_parsed:
				if logro["name"] == saved_logro["name"]:
					logro["unlocked"] = saved_logro["unlocked"]
					logro["date_unlocked"] = saved_logro["date_unlocked"]


func reset_logros():
	for logro in logros_parsed:
		logro["unlocked"] = false
		logro["date_unlocked"] = ""
	save_logros_progress()
