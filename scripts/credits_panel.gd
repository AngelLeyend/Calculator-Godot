extends Panel

signal close_requested  # Señal para solicitar el cierre de la escena
@onready var CreditsContainer =$ScrollContainer/MarginContainer/VBoxContainer/CreditsContainer
@onready var LabelEnd =$ScrollContainer/MarginContainer/VBoxContainer/LabelExclusive
@onready var BBLabel = $ScrollContainer/MarginContainer/VBoxContainer/RichTextLabel
var json_path = "res://assets/credits.json"

var credits_parsed={ }

func _ready():
	load_credits()

func _on_closebutton_pressed() -> void:
	# print("Close button pressed")  # Imprimir en la consola
	AudioUIManager.play("button_pressed")  # Reproducir sonido al presionar el botón
	close_requested.emit()  # Emitir la señal de cierre


# func load_credits():
# 	# Cargar el archivo JSON
# 	# Verificar si el archivo existe
# 	var file = FileAccess.open(json_path, FileAccess.READ)
# 	if file == null:
# 		# print("Error: Could not open file at path: " + json_path)
# 		return {}
	
# 	# Leer contenido del json
# 	var json_data = file.get_as_text()
# 	var json_object = JSON.new()
	
# 	# Parsear el contenido JSON
# 	json_object.parse(json_data)
# 	credits_parsed = json_object.data
# # 	print(credits_parsed)
# 	file.close()
	
#  # Asignar los valores a los labels
# 	for i in range(min(credits_parsed.size(), 6)):
# 		var credit = credits_parsed[i]
# 		var label = CreditsContainer.get_node("Label%d" % (i + 1))
# 		if label:
# 			label.text = "%s\n%s" % [
# 				tr(credit["role"]),
# 				"\n".join(credit["members"])
# 			]


# 	# Asignar el valor exclusivo al LabelEnd (índice 6)
# 	if credits_parsed.size() > 6:
# 		var credit = credits_parsed[6]
# 		LabelEnd.text = "%s\n%s" % [
# 			tr(credit["role"]),
# 			"\n".join(credit["members"])
# 		]


# 	return credits_parsed



func load_credits():
	# Cargar el archivo JSON
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return {}
	
	var json_data = file.get_as_text()
	var json_object = JSON.new()
	json_object.parse(json_data)
	credits_parsed = json_object.data
	file.close()
	
	# Crear un solo texto con todos los créditos
	var full_credits_text = create_full_credits_bbcode()
	
	# Asignar al BBLabel
	BBLabel.bbcode_enabled = true
	BBLabel.text = full_credits_text
	if not BBLabel.meta_clicked.is_connected(_on_meta_clicked):
		BBLabel.meta_clicked.connect(_on_meta_clicked)
	if not BBLabel.meta_hover_started.is_connected(_on_meta_hover_started):
		BBLabel.meta_hover_started.connect(_on_meta_hover_started)
	
	
	# Ocultar los otros contenedores si no los necesitas
	CreditsContainer.visible = false
	LabelEnd.visible = false
	
	return credits_parsed



func create_full_credits_bbcode() -> String:
	var bbcode_text = ""
	
	# Separar música de otros créditos
	var music_credit = null
	var other_credits = []
	
	for credit in credits_parsed:
		if credit["role"] == "credits_music":
			music_credit = credit
		else:
			other_credits.append(credit)
	
	# Crear tabla de 3 columnas centrada para los créditos (con separación)
	if other_credits.size() > 0:
		bbcode_text += "[center][table=3]\n"
		
		for i in range(0, other_credits.size(), 2):
			# Primera columna
			var credit1 = other_credits[i]
			var role_text1 = tr(credit1["role"])
			var members1 = []
			for member in credit1["members"]:
				members1.append(format_member_link(member))
			
			bbcode_text += "[cell][center][color=yellow]%s:[/color]\n%s[/center][/cell]" % [role_text1, "\n".join(members1)]
			
			# Columna separadora vacía
			bbcode_text += "[cell]     [/cell]"
			
			# Segunda columna (si existe)
			if i + 1 < other_credits.size():
				var credit2 = other_credits[i + 1]
				var role_text2 = tr(credit2["role"])
				var members2 = []
				for member in credit2["members"]:
					members2.append(format_member_link(member))
				
				bbcode_text += "[cell][center][color=yellow]%s:[/color]\n%s[/center][/cell]" % [role_text2, "\n".join(members2)]
			else:
				bbcode_text += "[cell][/cell]"  # Celda vacía
			
			bbcode_text += "\n"
		
		bbcode_text += "[/table][/center]\n\n"
	
	# Agregar música al final centrada, cada canción en su renglón
	if music_credit:
		var role_text = tr(music_credit["role"])
		bbcode_text += "[center][color=yellow]%s:[/color]\n" % role_text
		for member in music_credit["members"]:
			bbcode_text += "%s\n" % format_member_link(member)
		bbcode_text += "[/center]"
	
	return bbcode_text


func format_member_link(member: String) -> String:
	# Verificar si el miembro tiene un formato "nombre|link"
	if "|" in member:
		var parts = member.split("|")
		var name = parts[0]
		var link = parts[1]
		return "[url=%s]%s[/url]" % [link, name]
	else:
		# Si no tiene link, solo devolver el nombre
		return member

func _on_meta_clicked(meta):
	AudioUIManager.play("button_pressed")
	OS.shell_open(str(meta))

func _on_meta_hover_started(meta):
	AudioUIManager.play("button_hover")

func _on_button_mouse_entered() -> void:
	AudioUIManager.play("button_hover")


func _on_link_button_pressed() -> void:
	AudioUIManager.play("button_pressed")
