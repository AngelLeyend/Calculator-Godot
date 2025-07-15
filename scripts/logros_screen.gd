extends Panel

signal close_requested  # Señal para solicitar el cierre de la escena
signal show_logro_popup(logro_data:Variant)  # Señal para mostrar el popup con los datos del logro

func _on_closebutton_pressed() -> void:
	AudioUIManager.play("button_pressed")  # Reproducir sonido al presionar el botón
	close_requested.emit()  # Emitir la señal de cierre




func _on_scroll_logros_container_show_logro_popup(logro_data:Variant) -> void:
	# Emitir la señal para mostrar el popup con los datos del logro
	show_logro_popup.emit(logro_data)


func _on_button_mouse_entered() -> void:
	AudioUIManager.play("button_hover")  # Reproducir sonido al pasar el mouse sobre el botón
	# print("Mouse entered button")  # Imprimir en la consola (opcional)