extends Control

@onready var label_name = $PanelContainer/HBoxContainer/CenteredContainer/VBoxContainer/label_name
@onready var label_desc = $PanelContainer/HBoxContainer/CenteredContainer/VBoxContainer/label_desc
@onready var label_date = $PanelContainer/HBoxContainer/CenteredContainer/VBoxContainer/label_date
@onready var label_obtained = $PanelContainer/HBoxContainer/CenteredContainer/VBoxContainer/label_obtained
@onready var PopUpPanel = $PanelContainer
@onready var BackPanel = $BackPanel

func _ready():
	# Conectar la señal gui_input del BackPanel
	BackPanel.connect("gui_input", Callable(self, "_on_back_panel_gui_input"))

func show_logro_data(logro):
	# Actualizar los labels con los datos del logro
	label_name.text = logro["name"]
	label_desc.text = logro["description"]
	label_date.text = logro["date_unlocked"]

	# Mostrar el popup
	visible = true

	# Iniciar el PopUpPanel en escala 0
	PopUpPanel.scale = Vector2(0.0, 0.0)

	# Ajustar el pivot al centro del panel
	PopUpPanel.pivot_offset = PopUpPanel.size / 2

	# Crear el tween para animar la escala a 1,1
	var tween = create_tween()
	tween.tween_property(PopUpPanel, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_back_panel_gui_input(event):
	# Verificar si el evento es un clic del mouse
	if event is InputEventMouseButton and event.pressed:
		# Animar el cierre del popup con escala inversa
		var tween = create_tween()
		tween.tween_property(PopUpPanel, "scale", Vector2(0.0, 0.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_callback(Callable(self, "_hide_popup"))

func _hide_popup():
	AudioUIManager.play("window_close")
	visible = false
