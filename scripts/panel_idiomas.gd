extends PanelContainer
@onready var IdiomasContainer = $".."
@onready var IdiomasButton = $"../../BarraInicio/Panel/HBoxContainer/LangButton"


func _ready() -> void:
	# print("idiomas")
	pass



func _on_button_pressed(idioma_id:String) -> void:
	TranslationServer.set_locale(idioma_id)
	AudioUIManager.play("button_pressed")

func _on_button_hovered() -> void:
	# Reproducir sonido al pasar el mouse sobre un botón
	AudioUIManager.play("button_hover")





func _on_desktop_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
 # Si el mouse está fuera del panel, ocultar el menú principal
		# IdiomasContainer.hide()
		IdiomasButton._ocultar_menu_animado()
