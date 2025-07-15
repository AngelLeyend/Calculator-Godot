extends Control
@export var load_scene: PackedScene
@export var in_time: float = 0.5
@export var fade_in_time: float = 1
@export var pause_time: float = 1
@export var fade_out_time: float = 1
@export var out_time: float = 0.5
@export var splash_screen_container : Node
var splash_screens: Array

signal splash_screen_finished()

var skip_requested := false

func _ready():
	get_screens()
	fade()

func get_screens ():
	splash_screens = splash_screen_container.get_children()
	for screen in splash_screens:
		screen.modulate.a = 0.0

func fade():
	for screen in splash_screens:
		var tween = self.create_tween()
		tween.tween_interval(in_time)
		tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
		tween.tween_interval(pause_time)
		tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
		tween.tween_interval(out_time)

		# Espera a que termine el tween o se pida saltar
		while not skip_requested and tween.is_running():
			await get_tree().process_frame

		if skip_requested:
			tween.stop()
			# Efecto de fade-out rápido al detectar input
			var fast_tween = self.create_tween()
			fast_tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
			await fast_tween.finished
		else:
			# Si no hubo input, espera a que termine el tween normalmente
			if tween.is_running():
				await tween.finished

		skip_requested = false
# 	print("Fin de la secuencia de splash screen")
	splash_screen_finished.emit()


func _input(event):
	if event.is_pressed():
# 		print("Input detectado")
		skip_requested = true
