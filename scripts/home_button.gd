extends TextureButton

@export var MenuInicio: CanvasLayer
@export var MenuIdiomas: CanvasLayer
@export var PanelInicio: Control

var original_offset_top: float
var pivot_set := false

func _ready():
	# Guarda el offset_top original (posición respecto a los anclajes)
	original_offset_top = PanelInicio.offset_top

func _on_pressed() -> void:
	if not MenuInicio.visible:
		MenuInicio.visible = true
		AudioUIManager.play("button_pressed")
		if not pivot_set:
			PanelInicio.pivot_offset = Vector2(PanelInicio.size.x / 2, PanelInicio.size.y)
			pivot_set = true
		
		# Anima usando offset_top en lugar de position
		PanelInicio.offset_top = original_offset_top + 100
		PanelInicio.scale = Vector2(1, 0.0)
		
		var tween := create_tween()
		AudioUIManager.play("menu_open")
		
		# Anima el offset_top hacia su posición original
		tween.tween_property(PanelInicio, "offset_top", original_offset_top, 0.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(PanelInicio, "scale", Vector2(1.1, 1.15), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(PanelInicio, "scale", Vector2(0.95, 0.95), 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(PanelInicio, "scale", Vector2(1, 1), 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		MenuIdiomas.visible = false
	else:
		_ocultar_menu_inicio_animado()
	
	release_focus()
	var calc_button = $"../../../../../MenuInicio/PanelInicio/VBoxContainer/CalcButton"
	if calc_button:
		calc_button.grab_focus()

func _ocultar_menu_inicio_animado():
	var tween := create_tween()
	tween.tween_property(PanelInicio, "scale", Vector2(1, 0.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# Anima el offset_top hacia abajo
	AudioUIManager.play("menu_close")
	tween.tween_property(PanelInicio, "offset_top", original_offset_top + 100, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.connect("finished", Callable(self, "_on_ocultar_inicio_animacion_terminada"))

func _on_ocultar_inicio_animacion_terminada():
	MenuInicio.visible = false

func _on_mouse_entered() -> void:
	AudioUIManager.play("button_hover")
