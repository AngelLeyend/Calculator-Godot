extends Panel

signal close_requested  # Señal para solicitar el cierre de la escena
signal wallpaper_selected(wallpaper_path: String)  # Señal para seleccionar un fondo de pantalla

@onready var ButtonsContainer = $MarginContainer/VBoxContainer/ButtonsContainer


func _ready():
	setup_wallpaper_buttons_highlight()

func _on_closebutton_pressed() -> void:
	AudioUIManager.play("button_pressed")  # Reproducir sonido al presionar el botón
	close_requested.emit()  # Emitir la señal de cierre


func _on_wallpaper_button_pressed(wall_id:int) -> void:
	# print("Wallpaper button pressed with ID: ", wall_id)
	AudioUIManager.play("button_pressed")
	Archivements.unlock_logro(12)
	wallpaper_selected.emit(wall_id)  # Emitir la señal con el wallpaper seleccionado


func setup_wallpaper_buttons_highlight():
	for button in ButtonsContainer.get_children():
		if button.name.begins_with("WallpaperButton") and button is TextureButton:
			var original_texture = button.texture_normal

			# Intenta obtener la imagen de la textura, sea cual sea el tipo
			var img : Image = null
			if original_texture is ImageTexture:
				img = original_texture.get_image()
			elif original_texture is Texture2D:
				img = original_texture.get_image()
			else:
				continue  # No se puede modificar esta textura

			# Crea imágenes para hover y pressed
			var hover_img = img.duplicate()
			var pressed_img = img.duplicate()

			for y in hover_img.get_height():
				for x in hover_img.get_width():
					var color = hover_img.get_pixel(x, y)
					hover_img.set_pixel(x, y, color.lightened(0.3))
					pressed_img.set_pixel(x, y, color.darkened(0.3))


			# Crea nuevas texturas desde las imágenes
			var hover_texture = ImageTexture.create_from_image(hover_img)
			var pressed_texture = ImageTexture.create_from_image(pressed_img)

			button.texture_hover = hover_texture
			button.texture_pressed = pressed_texture




func _on_button_hovered() -> void:
	# Reproducir sonido al pasar el mouse sobre un botón
	AudioUIManager.play("button_hover")
