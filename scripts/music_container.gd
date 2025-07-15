extends Panel

@onready var previous_button = $MarginContainer/VBoxContainer/BarraReproduccion/PreviousButton
@onready var pause_button = $MarginContainer/VBoxContainer/BarraReproduccion/PauseButton
@onready var next_button = $MarginContainer/VBoxContainer/BarraReproduccion/NextButton
@onready var music_slider = $MarginContainer/VBoxContainer/BarraReproduccion/MusicSlider
@onready var loop_button = $MarginContainer/VBoxContainer/BarraReproduccion/LoopButton
@onready var random_button = $MarginContainer/VBoxContainer/BarraReproduccion/RandomButton
@onready var SingleSongContainer = preload("res://scenes/song_container.tscn")
@onready var MusicLibrary = $MarginContainer/VBoxContainer/MusicContainer/PanelContainer/ScrollContainer/MusicLibrary

#Current Song data
@onready var current_song_label = $MarginContainer/VBoxContainer/MusicContainer/MusicInfoContainer/MusicInfo/ActiveSongLabel
@onready var current_artist_label = $MarginContainer/VBoxContainer/MusicContainer/MusicInfoContainer/MusicInfo/ActiveArtistLabel
@onready var current_album_cover = $MarginContainer/VBoxContainer/MusicContainer/MusicInfoContainer/MusicInfo/ActiveAlbumCover


signal close_requested  # Señal para solicitar el cierre de la escena

var songs = []



var local_song_position := 0.0
var is_paused := false
var last_song_index := -1

var is_dragging := false


# Ruta del json con los logros
var json_path = "res://assets/sounds/music/songs.json"


func _ready():
	MusicManager.connect("song_index_changed", Callable(self, "_on_song_index_changed"))
	# Cargar canciones y establecer la canción actual inmediatamente
	load_songs()
	if songs.size() > 0:
		set_current_song()  # Sincronizar inmediatamente con el estado actual


func _process(delta):
	var current_song_index = MusicManager.get_song_index()
	if current_song_index != last_song_index:
		local_song_position = 0.0
		last_song_index = current_song_index
		is_paused = false
	if not is_paused and not is_dragging and music_slider.value < music_slider.max_value:
		local_song_position += delta
		music_slider.value = clamp(local_song_position, 0, music_slider.max_value)




func load_songs():
	# Cargar canciones desde el JSON (como en el ejemplo anterior)
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
# 		print("Error: Could not open file at path: " + json_path)
		return []
	
	# Leer contenido del json
	var json_data = file.get_as_text()
	var json_object = JSON.new()
	

	# Parsear el contenido JSON
	json_object.parse(json_data)
	songs = json_object.data
	# print(songs)
	file.close()


func populate_songs(music_library: Control) -> void:
	load_songs()
	_create_song_items_async(music_library)
		

func _on_album_cover_pressed(index):
	# Cambiar la canción usando el índice
	MusicManager.set_song_index(index)
	# Reset completo de posición
	MusicManager.song_actual_position = 0.0
	local_song_position = 0.0
	set_current_song() # Actualiza la UI si es necesario



func _on_closebutton_pressed() -> void:
	AudioUIManager.play("button_pressed")  # Reproducir sonido al presionar el botón
	close_requested.emit()  # Emitir la señal de cierre

func set_current_song():
	# Obtener el índice de la canción actual desde MusicManager
	var current_song_index = MusicManager.get_song_index()
	local_song_position = MusicManager.song_actual_position
	music_slider.value = clamp(local_song_position, 0, music_slider.max_value)
# 	print("Índice de canción actual:", current_song_index)
	# Verificar si el índice es válido
	if current_song_index >= 0 and current_song_index < songs.size():
		var song = songs[current_song_index]
		
		# Actualizar etiquetas con la información de la canción actual
		current_song_label.text = song["title"]
		current_artist_label.text = song["artist"]
		
		# Cargar la carátula del álbum
		var cover_path = song["cover_path"] if song.has("cover_path") else "res://icon.svg"
		var album_texture = load(cover_path)
		if album_texture == null:
			album_texture = load("res://icon.svg")
		current_album_cover.texture = album_texture


		# Actualizar el slider de música
		music_slider.max_value = duration_to_seconds(song["duration"])  # Asignar la duración de la canción al slider

		# --- NUEVO: Setear la posición del slider según MusicManager.song_actual_position ---
		local_song_position = MusicManager.song_actual_position
		music_slider.value = clamp(local_song_position, 0, music_slider.max_value)
		# ----------------------------------------------------------

		last_song_index = current_song_index
		is_paused = false
		

		 
	else:
		print("Índice de canción no válido:", current_song_index)


func _on_pause_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	is_paused = not is_paused
	MusicManager.song_paused()


func _on_previous_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	MusicManager.play_previous_song()
	# Reset de posición local antes de actualizar UI
	local_song_position = 0.0
	MusicManager.song_actual_position = 0.0
	set_current_song() # Actualiza la UI si es necesario

func _on_next_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	MusicManager.play_next_song()
	# Reset de posición local antes de actualizar UI
	local_song_position = 0.0
	MusicManager.song_actual_position = 0.0
	set_current_song() # Actualiza la UI si es necesario
	


func _on_loop_button_toggled(toggled_on: bool) -> void:
	AudioUIManager.play("button_pressed")
	MusicManager.is_song_looped = toggled_on


func _on_random_button_toggled(toggled_on: bool) -> void:
	AudioUIManager.play("button_pressed")
	MusicManager.is_song_random = toggled_on


func duration_to_seconds(duration_str: String) -> int:
	var parts = duration_str.split(":")
	if parts.size() == 2:
		var minutes = int(parts[0])
		var seconds = int(parts[1])
		return minutes * 60 + seconds
	return 0


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	is_dragging = false
	if value_changed:
		local_song_position = music_slider.value
		MusicManager.song_actual_position = music_slider.value
		MusicManager.set_song_position()


func _on_music_slider_drag_started() -> void:
	is_dragging = true


func _on_song_index_changed(_new_index: int) -> void:
	# Reset de posición cuando cambia el índice
	local_song_position = 0.0
	MusicManager.song_actual_position = 0.0
	set_current_song()



func _create_song_items_async(music_library: Control) -> void:
	await get_tree().process_frame  # Espera un frame antes de empezar
	for i in songs.size():
		var song = songs[i]
		var song_instance = SingleSongContainer.instantiate()
		
		# Configurar el SongLabel con el nombre de la canción
		var song_label = song_instance.get_node("VBoxContainer/SongLabel")
		song_label.text = song["title"]

		# Configurar el SongArtistLabel con el nombre del artista
		var song_artist_label = song_instance.get_node("VBoxContainer/ArtistLabel")
		song_artist_label.text = song["artist"]
		
		# Configurar la duración de la canción
		var song_duration_label = song_instance.get_node("DurationLabel")
		song_duration_label.text = song["duration"]

		# Configurar carátula de la canción
		var song_cover = song_instance.get_node("AlbumCover")
		var cover_path = song["cover_path"] if song.has("cover_path") else "res://icon.svg"
		var original_texture = load(cover_path)
		if original_texture == null:
			cover_path = "res://icon.svg"
			original_texture = load(cover_path)
		song_cover.texture_normal = original_texture

		# Efecto hover y pressed
		var img : Image = null
		if original_texture is ImageTexture:
			img = original_texture.get_image()
		elif original_texture is Texture2D:
			img = original_texture.get_image()
		else:
			img = null

		if img:
			var hover_img = img.duplicate()
			var pressed_img = img.duplicate()

			for y in hover_img.get_height():
				for x in hover_img.get_width():
					var color = hover_img.get_pixel(x, y)
					hover_img.set_pixel(x, y, color.lightened(0.3))
					pressed_img.set_pixel(x, y, color.darkened(0.3))

			var hover_texture = ImageTexture.create_from_image(hover_img)
			var pressed_texture = ImageTexture.create_from_image(pressed_img)
			song_cover.texture_hover = hover_texture
			song_cover.texture_pressed = pressed_texture

		song_cover.pressed.connect(_on_album_cover_pressed.bind(i))
		song_cover.pressed.connect(func(): AudioUIManager.play("button_pressed"))
		song_cover.mouse_entered.connect(func(): AudioUIManager.play("button_hover"))

		music_library.add_child(song_instance)

		await get_tree().process_frame  # Espera un frame antes de crear el siguiente



func _on_button_hovered() -> void:
	# Reproducir sonido al pasar el mouse sobre un botón
	AudioUIManager.play("button_hover")
