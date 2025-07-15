extends Panel
@onready var PopUp = $".."


func _on_no_button_pressed() -> void:
	# Ocultar el popup
	AudioUIManager.play("button_pressed")
	PopUp.visible = false


func _on_yes_button_pressed() -> void:
	# Cerrar la aplicación
	AudioUIManager.play("button_pressed")
	get_tree().quit()


func _on_button_hovered() -> void:
	# Reproducir sonido al pasar el mouse sobre un botón
	AudioUIManager.play("button_hover")
