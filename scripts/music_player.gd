extends AudioStreamPlayer

var songs = []
var current_song_index = MusicManager.get_song_index()
var json_path = "res://assets/sounds/music/songs.json"







func _ready():
	load_songs()
	MusicManager.connect("song_index_changed", Callable(self, "_on_song_index_changed"))
	MusicManager.connect("pause_song", Callable(self, "_on_song_paused"))
	MusicManager.connect("next_song", Callable(self, "_on_song_next"))
	MusicManager.connect("previous_song", Callable(self, "_on_song_previous"))
	MusicManager.connect("song_position_changed", Callable(self, "_on_song_position_changed"))
	MusicManager.connect("song_finished", Callable(self, "_on_finished"))


func load_songs():
	# Cargar canciones desde el JSON
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
	if songs.size() > 0:
		play_song(0)

func play_song(index):
	if index >= 0 and index < songs.size():
		# Solo actualiza el índice si es diferente
		if current_song_index != index:
			current_song_index = index
			var song = songs[index]
			stream = load(song["audio_path"])
			play()
# 			print("Reproduciendo:", song["title"])
		else:
			# Si el índice es igual, solo reproduce la canción
			var song = songs[index]
			stream = load(song["audio_path"])
			play()
	else:
		print("Índice de canción no válido:", index)

func _on_song_finished():
	var next_index = current_song_index + 1
	MusicManager.song_actual_position = 0
	if MusicManager.is_song_looped:
		play_song(current_song_index) # Repite la misma canción
		MusicManager.set_song_index(current_song_index) #Reinicia la interfaz de la cancion
	elif MusicManager.is_song_random:
		var random_index = randi() % songs.size()
		MusicManager.set_song_index(random_index)
		
		play_song(random_index)

	elif next_index < songs.size():
		MusicManager.set_song_index(next_index)
		play_song(next_index)
	else:
		# Si termina la playlist, vuelve al principio (modo cíclico)
		MusicManager.set_song_index(0)
		play_song(0)

func _on_song_index_changed(new_index):
	play_song(new_index)

func _on_song_paused():

	if playing:
		MusicManager.song_actual_position = get_playback_position()
# 		print("Song paused at position:", MusicManager.song_actual_position)
		stop()
	else:
		play(MusicManager.song_actual_position)


func _on_song_next():
	if MusicManager.is_song_random:
			var random_index = current_song_index
			if songs.size() > 1:
				while random_index == current_song_index:
					random_index = randi() % songs.size()
			MusicManager.set_song_index(random_index)
			play_song(random_index)

	else:
		var next_index = current_song_index + 1
		if next_index < songs.size():
			MusicManager.set_song_index(next_index)
			play_song(next_index)
		else:
				# Si está en la última canción, vuelve al principio
			MusicManager.set_song_index(0)
			play_song(0)




func _on_song_previous():
	var prev_index = current_song_index - 1
	if prev_index >= 0:
		play_song(prev_index)
		MusicManager.set_song_index(prev_index)
	else:
		# Si está en la primera canción, va al final
		var last_index = songs.size() - 1
		MusicManager.set_song_index(last_index)
		play_song(last_index)

func _on_song_position_changed():
	if playing:
		stop()
		play(MusicManager.song_actual_position)
# 		print("Song position changed to:", MusicManager.song_actual_position)
	else:
		print("No se puede cambiar la posición de la canción porque no está reproduciéndose.")

#Señal emitida pore el AudioStreamPlayer2D cuando la canción termina
func _on_finished() -> void:
# 	print("Song finished")
	_on_song_finished()


