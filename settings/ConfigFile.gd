extends Node


var config = ConfigFile.new()
const CONFIG_FILE_PATH = "user://settings.ini"


func _ready():
	if !FileAccess.file_exists(CONFIG_FILE_PATH):
# 		print("No existe el archivo de configuración, creando uno nuevo...")
		config.set_value("video", "resolution", "1920x1080")
		config.set_value("video", "width", 1920)
		config.set_value("video", "height", 1080)

		config.set_value("video", "wallpaper", 1)
		
		config.set_value("video", "aspect_ratio", "16:9")
		config.set_value("video", "fullscreen", true)

		config.set_value("audio", "volume_master", 100)
		config.set_value("audio", "volume_music", 100)
		config.set_value("audio", "volume_sfx", 100)

		config.save(CONFIG_FILE_PATH)
	else:
		config.load(CONFIG_FILE_PATH)
		apply_settings()
# 		print("Archivo de configuración cargado correctamente.")


func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(CONFIG_FILE_PATH)

func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings




func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(CONFIG_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func apply_settings():
	var video_settings = load_video_settings()
	var audio_settings = load_audio_settings()

# 	print("Cargando configuración de video...")
	if video_settings.get("fullscreen")==true:
# 		print("Pantalla completa activada.")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
# 		print("Pantalla completa desactivada.")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	video_settings.get("resolution")
	var resolution = video_settings.get("resolution").split("x")
	var width = int(resolution[0])
	var height = int(resolution[1])
	DisplayServer.window_set_size(Vector2i(width, height))

	
	









# 	print("Cargando configuración de audio...")
	AudioServer.set_bus_volume_db(0, linear_to_db(audio_settings["volume_master"] / 100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(audio_settings["volume_music"] / 100.0))
	AudioServer.set_bus_volume_db(2, linear_to_db(audio_settings["volume_sfx"] / 100.0))
		
		
