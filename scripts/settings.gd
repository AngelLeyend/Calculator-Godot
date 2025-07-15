extends Control

@onready var fullscreen_checkbox= $MarginContainer/VBoxContainer/HBoxContainer2/FullscreenCheckBox
@onready var volume_slider = $MarginContainer/VBoxContainer/VolumeSlider
@onready var music_slider = $MarginContainer/VBoxContainer/MusicSlider
@onready var sfx_slider = $MarginContainer/VBoxContainer/SFXSlider
@onready var aspect_ratio_options = $MarginContainer/VBoxContainer/OptionButton
@onready var ResetConfirmCanvas = $ResetLayer

signal close_requested  # Señal para solicitar el cierre de la escena



func _ready(): #CARGA LOS VALORES DE SETTINGS.INI EN LA INTERFAZ
	var video_settings = GlobalConfigFile.load_video_settings()
	fullscreen_checkbox.button_pressed = video_settings["fullscreen"]
	


	var audio_settings = GlobalConfigFile.load_audio_settings()
	volume_slider.value = audio_settings["volume_master"]
	music_slider.value = audio_settings["volume_music"]
	sfx_slider.value = audio_settings["volume_sfx"]





func _on_fullscreen_check_box_toggled(toggled_on:bool) -> void:
	AudioUIManager.play("button_toggle")
	GlobalConfigFile.save_video_setting("fullscreen", toggled_on)
	GlobalConfigFile.apply_settings()




func center_window() -> void:
	var screen_center = DisplayServer.screen_get_position()+DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size / 2)




#VOLUMEN SE ACTUALZIA DINAMICAMENTE
func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volume_slider.value / 100.0))
	AudioUIManager.play("button_pressed")
func _on_sfx_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(sfx_slider.value / 100.0))
	AudioUIManager.play("button_pressed")
func _on_music_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(music_slider.value / 100.0))
	AudioUIManager.play("button_pressed")  # O cualquier otro sonido SFX que tengas




#VOLUMEN SE GUARDA EN SETTINGS.INI SOLO CUANDO SE SUELTA EL SLIDER
func _on_volume_slider_drag_ended(value_changed:bool) -> void:
	if value_changed:
		GlobalConfigFile.save_audio_setting("volume_master", volume_slider.value)

func _on_sfx_slider_drag_ended(value_changed:bool) -> void:
	if value_changed:
		GlobalConfigFile.save_audio_setting("volume_sfx", sfx_slider.value)


func _on_music_slider_drag_ended(value_changed:bool) -> void:
	if value_changed:
		GlobalConfigFile.save_audio_setting("volume_music", music_slider.value)


func _on_closebutton_pressed() -> void:
	AudioUIManager.play("button_pressed")
	close_requested.emit()  # Emitir la señal de cierre


func _on_reset_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	AudioUIManager.play("show_popup")
	ResetConfirmCanvas.visible = not ResetConfirmCanvas.visible


func _on_no_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	ResetConfirmCanvas.visible = not ResetConfirmCanvas.visible


func _on_yes_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
	SaveManager.reset_game()


func _on_reset_button_mouse_entered() -> void:
	AudioUIManager.play("button_hover")
