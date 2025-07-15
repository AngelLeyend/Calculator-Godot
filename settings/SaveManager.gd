extends Node
#Singleton SaveManager
var save_path = "user://savegame.dat"

var game_data = {
	"beginning": 1,
	"game_completed": 0,
	"game_purchased": 0,
	"logros_progress": [] # <--- Agrega esta línea
}




func _ready():
	#reset_game()
	load_game()
	show_game_data()


func save_game():
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_var(game_data)
	save_file=null

func load_game():
	if FileAccess.file_exists(save_path):
		var save_file = FileAccess.open(save_path, FileAccess.READ)
		game_data = save_file.get_var()
		save_file=null
	else:
		print("No se encontró el archivo de guardado.")


func update_game_data(key: String, value: Variant):
	if key in game_data:
		game_data[key] = value
		save_game()
	else:
		print("La clave no existe en los datos del juego.")



func show_game_data():
	for key in game_data.keys():
		print(key + ": " + str(game_data[key]))


func reset_game():
	# Reinicia los valores por defecto
	game_data = {
		"beginning": 1,
		"game_completed": 0,
		"game_purchased": 0,
		"logros_progress": []
	}
	MusicManager.set_song_index(0)
	MusicManager.song_actual_position = 0
	save_game()
	
	# Reinicia también los logros en memoria
	Archivements.reset_logros()
	
	# Reinicia la escena principal
	get_tree().change_scene_to_file("res://scenes/main.tscn")
