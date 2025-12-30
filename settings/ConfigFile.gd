extends Node


var config = ConfigFile.new()
const CONFIG_FILE_PATH = "user://settings.ini"

# Valores por defecto
const DEFAULT_SETTINGS = {
	"video": {
		"resolution": "1920x1080",
		"width": 1920,
		"height": 1080,
		"wallpaper": 1,
		"aspect_ratio": "16:9",
		"fullscreen": true
	},
	"audio": {
		"volume_master": 100,
		"volume_music": 100,
		"volume_sfx": 100,
		"volume_voice": 100
	},
	"game": {
		"language": "en"
	}
}

func _ready():
	if !FileAccess.file_exists(CONFIG_FILE_PATH):
# 		print("No existe el archivo de configuración, creando uno nuevo...")
		create_default_config()
	else:
		config.load(CONFIG_FILE_PATH)
		# Verificar y completar valores faltantes
		verify_and_update_config()
		apply_settings()
# 		print("Archivo de configuración cargado correctamente.")

func create_default_config():
	for section in DEFAULT_SETTINGS.keys():
		for key in DEFAULT_SETTINGS[section].keys():
			config.set_value(section, key, DEFAULT_SETTINGS[section][key])
		var locale = TranslationServer.get_locale()
		print("Locale detected: " + locale)
		config.set_value("game", "language", locale)
	config.save(CONFIG_FILE_PATH)

func verify_and_update_config():
	var needs_save = false
	
	# Verificar cada sección y clave
	for section in DEFAULT_SETTINGS.keys():
		# Si la sección no existe, crearla
		if not config.has_section(section):
			for key in DEFAULT_SETTINGS[section].keys():
				config.set_value(section, key, DEFAULT_SETTINGS[section][key])
			needs_save = true
		else:
			# Verificar cada clave dentro de la sección
			for key in DEFAULT_SETTINGS[section].keys():
				if not config.has_section_key(section, key):
					config.set_value(section, key, DEFAULT_SETTINGS[section][key])
					needs_save = true
	
	# Guardar solo si hubo cambios
	if needs_save:
		config.save(CONFIG_FILE_PATH)
# 		print("Configuración actualizada con nuevos valores.")

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

func save_game_setting(key: String, value):
	config.set_value("game", key, value)
	config.save(CONFIG_FILE_PATH)

func load_game_settings():
	var game_settings = {}
	for key in config.get_section_keys("game"):
		game_settings[key] = config.get_value("game", key)
	return game_settings





func apply_settings():
	var video_settings = load_video_settings()
	var audio_settings = load_audio_settings()
	var game_settings = load_game_settings()
# 	print("Cargando configuración de video...")
	if video_settings.get("fullscreen") == true:
# 		print("Pantalla completa activada.")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
# 		print("Pantalla completa desactivada.")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	var resolution = video_settings.get("resolution").split("x")
	var width = int(resolution[0])
	var height = int(resolution[1])
	DisplayServer.window_set_size(Vector2i(width, height))

	TranslationServer.set_locale(game_settings.get("language"))


# 	print("Cargando configuración de audio...")
	AudioServer.set_bus_volume_db(0, linear_to_db(audio_settings.get("volume_master", 100) / 100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(audio_settings.get("volume_music", 100) / 100.0))
	AudioServer.set_bus_volume_db(2, linear_to_db(audio_settings.get("volume_sfx", 100) / 100.0))
	AudioServer.set_bus_volume_db(3, linear_to_db(audio_settings.get("volume_voice", 100) / 100.0))
