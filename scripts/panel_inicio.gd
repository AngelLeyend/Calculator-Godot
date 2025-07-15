extends PanelContainer

@onready var ConfigContainer = preload("res://scenes/config_menu.tscn")
@onready var AchievementsContainer = preload("res://scenes/logros_screen.tscn")
@onready var CreditsContainer = preload("res://scenes/credits.tscn")
@onready var WallpapersContainer = preload("res://scenes/wallpaper_screen.tscn")
@onready var MusicContainer = preload("res://scenes/music_screen.tscn")
@onready var CalculatorContainer = preload("res://scenes/calculator.tscn")
@onready var PopUpLogro = preload("res://scenes/logros_pop_up.tscn")

@onready var MenuInicio = $".."
@onready var WindowsLayer = $"../../WindowsLayer"
@onready var LogroPopUpLayer = $"../../LogroPopUpLayer"
@onready var ExitPopup=$"../../ExitPupUp"
@onready var WallpaperRect = $"../../WallpaperRect"

@onready var MusicPlayer = $"../../AudioStreamPlayer"

@onready var HomeButton = $"../../BarraInicio/Panel/HBoxContainer/MarginContainer2/HomeButton"






var current_scene: Node = null

# Variable para rastrear si el mouse está fuera del panel
var is_mouse_outside: bool = false


func _ready():

	pass


func _unload_current_scene() -> void:
	if current_scene and current_scene.is_inside_tree():
			# await get_tree().process_frame # Espera un frame para que el size sea correcto
			AudioUIManager.play("window_close")
			current_scene.pivot_offset = Vector2(0, current_scene.size.y) # Esquina inferior izquierda
			var tween = create_tween()
			tween.tween_property(current_scene, "scale", Vector2(0.0, 0.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(current_scene, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
			tween.tween_callback(Callable(current_scene, "queue_free"))
			current_scene = null



func _on_config_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	load_scene(ConfigContainer)

func _on_archiv_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	load_scene(AchievementsContainer)

func _on_credits_button_pressed() -> void:
	Archivements.unlock_logro(13)
	AudioUIManager.play("button_pressed")
	load_scene(CreditsContainer)

func _on_custom_conf_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	load_scene(WallpapersContainer)


func _on_music_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	load_scene(MusicContainer)

func _on_calc_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	load_scene(CalculatorContainer)



func _on_exit_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	# Mostrar el popup de salida
	AudioUIManager.play("show_popup")
	ExitPopup.visible = true


func _on_scene_close_requested() -> void:
	# Manejar el cierre de la escena actual
	_unload_current_scene()


func _on_button_hovered() -> void:
	# Reproducir sonido al pasar el mouse sobre un botón
	AudioUIManager.play("button_hover")



func load_scene(scene_resource: PackedScene) -> void:
	_unload_current_scene()  # Descargar la escena actual
	AudioUIManager.play("window_open")
	# Método Exclusivo para la música
	var is_music = scene_resource == MusicContainer
	if is_music and MusicPlayer:
		MusicManager.song_actual_position = MusicPlayer.get_playback_position()
		MusicManager.set_song_position()
	elif is_music:
		print("MusicPlayer no está disponible")

	current_scene = scene_resource.instantiate()
	
	# CONFIGURAR PROPIEDADES INICIALES ANTES DE AÑADIR AL ÁRBOL
	current_scene.scale = Vector2(0.0, 0.0)
	current_scene.modulate.a = 0.0
	
	# Ahora añadir al árbol
	WindowsLayer.add_child(current_scene)
	
	# ESPERAR FRAMES para asegurar que el nodo esté completamente inicializado
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Verificar que el nodo tenga un tamaño válido y configurar pivot
	if current_scene.size == Vector2.ZERO:
# 		print("Advertencia: El nodo no tiene tamaño definido")
		# Usar un tamaño por defecto o el tamaño de la ventana
		current_scene.size = get_viewport().get_visible_rect().size

	# Configurar pivot_offset después de tener el tamaño correcto
	current_scene.pivot_offset = Vector2(0, current_scene.size.y) # Esquina inferior izquierda

	# Crear el tween - versión secuencial si la paralela no funciona
	var tween = create_tween()
	
	# Primero animar la escala
	tween.tween_property(current_scene, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Luego animar la opacidad al mismo tiempo (usar parallel)
	tween.parallel().tween_property(current_scene, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)

	# Método Exclusivo para el wallpaper
	if scene_resource == WallpapersContainer:
		current_scene.connect("wallpaper_selected", _on_wallpaper_selected)

	# Método Exclusivo para el popup de logros
	if scene_resource == AchievementsContainer:
		current_scene.connect("show_logro_popup", _on_show_logro_popup)

	current_scene.connect("close_requested", _on_scene_close_requested)
	# MenuInicio.hide()
	
	HomeButton._ocultar_menu_inicio_animado()
	
	# --- NUEVO: Poblar la lista de canciones después de la animación ---
	if is_music:
		await tween.finished
		current_scene.populate_songs(current_scene.MusicLibrary)
		# current_scene.set_current_song()  # Establecer la canción actual al inicio






func _on_wallpaper_selected(wall_id: int) -> void:
# Cambiar la textura de WallpaperRect según el valor de wall_id
	GlobalConfigFile.save_video_setting("wallpaper", wall_id)

	var texture_path = "res://assets/sprites/wallpapers/%d.png" % wall_id
	var texture = load(texture_path)
	if texture:
		WallpaperRect.texture = texture
	else:
		# print("No se pudo cargar la textura:", texture_path)
		print("Número recibido por la señal:", wall_id)



func _on_desktop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
 # Si el mouse está fuera del panel, ocultar el menú principal
		# if is_mouse_outside:
		# MenuInicio.hide()
		
		HomeButton._ocultar_menu_inicio_animado()
		
		


func _on_show_logro_popup(logro_data: Dictionary) -> void:
	# print("logro data sibnganlp " + str(logro_data))
	var popup_instance = PopUpLogro.instantiate()
	AudioUIManager.play("window_open")
	LogroPopUpLayer.add_child(popup_instance)
	
	# Llama a show_logro_data después de que el nodo esté listo
	popup_instance.call_deferred("show_logro_data", logro_data)
