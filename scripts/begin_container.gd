extends Control

@export var logo: TextureRect
@export var label: Label
@onready var canvas = $CanvasBegin
@onready var IntroScene = "res://scenes/sumiko_intro.tscn"
@onready var EndScene = "res://scenes/sumiko_ending.tscn"
@onready var BeginContainer = $CanvasBegin/BeginContainer
@onready var SplashCanvas = $SplashLayer


var konami_code = [KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, KEY_B, KEY_A]
var konami_index = 0

var tween: Tween
var is_active := true

func _ready():
	logo.modulate.a = 0.0
	label.modulate.a = 0.0
# 	print("Valor beginning: " + str(SaveManager.game_data["beginning"]))

	# Instanciar y mostrar la splash screen en SplashCanvas
	var splash_scene = load("res://scenes/splash-screen.tscn")
	var splash_instance = splash_scene.instantiate()
	SplashCanvas.add_child(splash_instance)
	splash_instance.connect("splash_screen_finished", Callable(self, "_on_splash_finished").bind(splash_instance))

	#Conectar señal fin del juego
	Archivements.finished_game.connect(_on_finished_game)

	#Set default language
	TranslationServer.set_locale(GlobalConfigFile.load_game_settings().get("language"))
	

func start_sequence():
	await get_tree().create_timer(1.0).timeout
	fade_in(logo)
	
	await get_tree().create_timer(2.0).timeout
	fade_in(label)
	start_blink_effect(label)

func fade_in(target: Control):
	create_tween().tween_property(target, "modulate:a", 1.0, 1.0)

func start_blink_effect(target: Control):
	var blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(target, "modulate:a", 0.3, 0.5).set_trans(Tween.TRANS_SINE)
	blink_tween.tween_property(target, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)

func _on_gui_input(event):
	if !is_active: return
	
	if event is InputEventMouseButton and event.pressed:
		is_active = false
		mouse_filter = MOUSE_FILTER_IGNORE
		
		var container_tween = create_tween()
		container_tween.tween_property(BeginContainer, "modulate:a", 0.0, 0.5)
		container_tween.tween_callback(func(): BeginContainer.visible = false)

func _on_intro_end(intro_instance):
	if intro_instance: # Verifica que intro_instance no sea null
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(intro_instance, "modulate:a", 0.0, 0.5) # Duración de 0.5 segundos
		fade_out_tween.tween_callback(func():
			if intro_instance and is_instance_valid(intro_instance): # Verifica nuevamente antes de liberar
				intro_instance.queue_free()
			start_sequence()
		)

func _on_button_pressed() -> void:
	SaveManager.update_game_data("beginning", 1)
# 	print("Valor beginning resuarado, deberia ser: " + str(SaveManager.game_data["beginning"]))


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == konami_code[konami_index]:
			konami_index += 1
			if konami_index == konami_code.size():
				Archivements.unlock_logro(7)
# 				print("¡Código Konami detectado! Logro desbloqueado.")
				konami_index = 0
		else:
			konami_index = 0

func _on_splash_finished(splash_instance):
	# Fade out del SplashCanvas (splash screen)
	var splash_fade_tween = create_tween()
	splash_fade_tween.tween_property(splash_instance, "modulate:a", 0.0, 1.5)
	splash_fade_tween.tween_callback(func():
		splash_instance.queue_free()
		SplashCanvas.visible = false
		
		
		# Ahora inicia el flujo normal del juego
		if (SaveManager.game_data["beginning"]==1):
			var intro_scene = load(IntroScene)
			var intro_instance = intro_scene.instantiate()
			canvas.add_child(intro_instance)
			intro_instance.modulate.a = 0.0
			# Fade in para la intro de Sumiko
			var intro_fade_tween = create_tween()
			intro_fade_tween.tween_property(intro_instance, "modulate:a", 1.0, 0.7)
# 			print("Ya has pasado por la secuencia de inicio.")
			intro_instance.connect("end_intro", Callable(self, "_on_intro_end").bind(intro_instance))

		else:
			start_sequence())




#Fin del juego
func _on_finished_game():
	# Fade out del SplashCanvas (splash screen)
	var splash_fade_tween = create_tween()
	splash_fade_tween.tween_property(SplashCanvas, "modulate:a", 0.0, 1.5)
	splash_fade_tween.tween_callback(func():
		SplashCanvas.queue_free()
		SplashCanvas.visible = false
		# Cargar la escena de final
		var end_scene = load(EndScene)
		var end_instance = end_scene.instantiate()
		canvas.add_child(end_instance)
		end_instance.modulate.a = 0.0
		# Fade in para la escena de final
		var end_fade_tween = create_tween()
		end_fade_tween.tween_property(end_instance, "modulate:a", 1.0, 0.7)
		end_instance.connect("end_game", Callable(self, "_on_intro_end").bind(end_instance))
	)
