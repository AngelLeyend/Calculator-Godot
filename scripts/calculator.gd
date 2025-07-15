extends Control

@onready var display:Label = $MarginContainer/VBoxContainer/PanelContainer/ScrollContainer/CalculatorLabel
var expression:String = ""
const MAX_LENGTH = 128  # Limite de caracteres en la expresión
signal close_requested  # Señal para solicitar el cierre de la escena
var result_displayed = false  # Nueva variable para saber si se está mostrando un resultado

#Nodos que cambian de tema
@onready var MainContainer =$"."
@onready var ButtonGrid =$MarginContainer/VBoxContainer/ButtonGrid
# @onready var ScreenContainer = $MarginContainer/VBoxContainer/PanelContainer
@onready var BarraArriba = $Panel

var default_theme:Theme = preload("res://themes/calculadora.tres")
var gold_theme:Theme = preload("res://themes/calculadora_gld.tres")

var up_default_theme:Theme = preload("res://themes/BarraArriba.tres")
var up_gold_theme:Theme = preload("res://themes/BarraArribaGold.tres")



func _ready():
	display.text = "0"
	# print(SaveManager.game_data["game_completed"])

	if SaveManager.game_data["game_completed"]:
		set_gold_theme()
	else:
		set_default_theme()

	Archivements.finished_game.connect(set_gold_theme)
	# Desactivar focus en todos los botones para evitar activación con teclado
	_disable_button_focus()


func _on_number_pressed(number: int) -> void:
	AudioUIManager.play("calc_number")
	# Si el display muestra "Error", se reinicia la expresión
	if display.text == "Error":
		expression = ""
	
	# Si se está mostrando un resultado y se ingresa un nuevo número, reiniciar
	if result_displayed:
		expression = ""
		result_displayed = false
	
	# No añadir multiplicación explícita después de paréntesis cerrado 
	# (se manejará implícitamente al calcular)
	
	# Verificar si la longitud máxima se ha alcanzado
	if expression.length() >= MAX_LENGTH:
		return
	
	# Si el display muestra "0" solo, reemplazar
	if expression == "0":
		expression = str(number)
	else:
		expression += str(number)
	
	display.text = expression


func _on_operator_pressed(operator: String) -> void:
	# Si el display muestra "Error", se reinicia la expresión
	if display.text == "Error":
		expression = ""
	AudioUIManager.play("calc_operator")		
	match operator:
		"C":
			_clear()
			result_displayed = false  # Reiniciar la bandera solo al limpiar
		"DEL":
			_delete_last()
		"=":
			_calculate_result()
		"%":
			# Aplica la conversión a porcentaje agregando "/100"
			_apply_percent()
			result_displayed = false  # Ya no estamos mostrando solo el resultado
		".":
			# Si se muestra un resultado y se pulsa punto, empezar nueva operación
			if result_displayed:
				expression = "0"
				result_displayed = false
			_add_decimal()
		"()":
			# Si se muestra un resultado y se pulsa paréntesis, empezar nueva operación
			if result_displayed:
				expression = ""
				result_displayed = false
			_toggle_parentheses()
		_:
			result_displayed = false  # Ya no estamos mostrando solo el resultado

			_add_operator(operator)

func _clear() -> void:
	expression = ""
	display.text = "0"

func _delete_last() -> void:
	if expression.length() > 0:
		expression = expression.substr(0, expression.length() - 1)
	display.text = expression if expression != "" else "0"

func _calculate_result() -> void:
	# No se evalúa si la expresión está vacía
	if expression == "":
		return
	# Eliminar caracteres finales inválidos (por ejemplo, un operador)
	if expression[-1] in "+-*/.":
		expression = expression.substr(0, expression.length() - 1)
	

		# Autocompletar paréntesis no cerrados
	var open_count = expression.count("(")
	var close_count = expression.count(")")
	if open_count > close_count:
		for i in range(open_count - close_count):
			expression += ")"

	# Chiste del pez para 2+2
	if expression == "2+2":
		var random_value = randi() % 5
		# print("Valor aleatorio para el pez: ", random_value)
		if random_value == 0: # 10% de probabilidad
			display.text = "<°)))><"
			Archivements.unlock_logro(11) # 2+2=<°)))><
			expression = ""
			return
	# Logro específico: 18*59
	if expression == "18*59":
		Archivements.unlock_logro(6) # Templo de las arenas
		

	# Crear copia de la expresión para evaluación (donde insertaremos *)
	var eval_expression = expression


 # Insertar multiplicación implícita para paréntesis
	# Buscar patrones como "5(" o ")(" o "5)" para insertar "*"
	var i = 0
	while i < eval_expression.length() - 1:
		var current_char = eval_expression[i]
		var next_char = eval_expression[i + 1]
		
		# Mejorando la detección de números decimales
		var is_digit = current_char.is_valid_int() 
		var is_decimal_point = current_char == "."
		var follows_decimal = i > 0 and eval_expression[i-1] == "."
		
		# Caso 1: número seguido de paréntesis abierto
		if ((is_digit or (is_decimal_point and not follows_decimal)) and next_char == "("):
			eval_expression = eval_expression.substr(0, i + 1) + "*" + eval_expression.substr(i + 1)
			i += 1 # Saltar el * insertado
		# Casos 2 y 3: igual que antes...
		elif current_char == ")" and next_char == "(":
			eval_expression = eval_expression.substr(0, i + 1) + "*" + eval_expression.substr(i + 1)
			i += 1
		elif current_char == ")" and (next_char.is_valid_int() or next_char == "."):
			eval_expression = eval_expression.substr(0, i + 1) + "*" + eval_expression.substr(i + 1)
			i += 1
			
		i += 1
	
# 	print("Expresión con multiplicación implícita: ", eval_expression)
	

	# 1. Procesar sumas/restas encadenadas con porcentajes (ej: 100+25%+10%)


	var sum_rest_pattern = RegEx.new()
	sum_rest_pattern.compile(r"^(\d+(?:\.\d+)?)([+\-]\d+(?:\.\d+)?%)+$")
	if sum_rest_pattern.search(eval_expression):
		var subtotal = 0.0
		var pattern = RegEx.new()
		pattern.compile(r"([+\-]?)(\d+(?:\.\d+)?)(%?)")
		var matches = pattern.search_all(eval_expression)
		for k in range(matches.size()):
			var m = matches[k]
			var op_sign = m.get_string(1)
			var value = float(m.get_string(2))
			var is_percent = m.get_string(3) == "%"
			if k == 0:
				subtotal = value
			else:
				if is_percent:
					value = subtotal * value / 100.0
				if op_sign == "-":
					subtotal -= value
				else:
					subtotal += value
		eval_expression = str(subtotal)
	else:
		# 2. Reemplazo de porcentaje tipo A+B% o A-B% (aplicar varias veces hasta que no queden)
		while true:
			var pattern_op = RegEx.new()
			pattern_op.compile(r"((?:\d+(?:\.\d+)?|\([^\(\)]+\)))([+\-])(\d+(?:\.\d+)?)%")
			var match_op = pattern_op.search(eval_expression)
			if not match_op:
				break
			var a = match_op.get_string(1)
			var op = match_op.get_string(2)
			var b = match_op.get_string(3)
			var replacement = a + op + "(" + a + "*" + b + "/100)"
			eval_expression = eval_expression.substr(0, match_op.get_start()) + replacement + eval_expression.substr(match_op.get_end())

		# 3. Reemplazo de porcentaje tipo A*B% o A/B%
		while true:
			var pattern_muldiv = RegEx.new()
			pattern_muldiv.compile(r"((?:\d+(?:\.\d+)?|\([^\(\)]+\)))([*/])(\d+(?:\.\d+)?)%")
			var match_muldiv = pattern_muldiv.search(eval_expression)
			if not match_muldiv:
				break
			var a = match_muldiv.get_string(1)
			var op = match_muldiv.get_string(2)
			var b = match_muldiv.get_string(3)
			var replacement = ""
			if op == "*":
				replacement = a + "*" + "(" + b + "/100)"
			else:
				replacement = a + "/(" + b + "/100)"
			eval_expression = eval_expression.substr(0, match_muldiv.get_start()) + replacement + eval_expression.substr(match_muldiv.get_end())

		# 4. Reemplazo de porcentaje tipo N%M (20%110)
		while true:
			var pattern_ab = RegEx.new()
			pattern_ab.compile(r"(\d+(?:\.\d+)?)%(\d+(?:\.\d+)?)")
			var match_ab = pattern_ab.search(eval_expression)
			if not match_ab:
				break
			var a = match_ab.get_string(1)
			var b = match_ab.get_string(2)
			var replacement = "(" + b + "*" + a + "/100)"
			eval_expression = eval_expression.substr(0, match_ab.get_start()) + replacement + eval_expression.substr(match_ab.get_end())


	# Reemplazo de porcentajes huérfanos (ej: 25% -> 0.25)
	while true:
		var orphan_percent = RegEx.new()
		orphan_percent.compile(r"(?<![\d\)])(\d+(?:\.\d+)?)%")
		var match_orphan = orphan_percent.search(eval_expression)
		if not match_orphan:
			break
		var value = match_orphan.get_string(1)
		var replacement = "(" + value + "/100)"
		eval_expression = eval_expression.substr(0, match_orphan.get_start()) + replacement + eval_expression.substr(match_orphan.get_end())



 	# Desbloquear logros básicos según la operación
	if "+" in expression:
		Archivements.unlock_logro(1) # Mi primera suma
	if "-" in expression:
		Archivements.unlock_logro(2) # Mi primera resta
	if "*" in expression:
		Archivements.unlock_logro(3) # Mi primera multiplicación
	if "/" in expression:
		Archivements.unlock_logro(4) # Mi primera división
	if "/0" in expression or expression.ends_with("/0"):
		_show_syntax_error()
		Archivements.unlock_logro(5) # Operación imposible (división entre 0)
		return  # Añadir este return para evitar la evaluación



	var modified_expression = ""
	var num_buffer = ""
	var has_decimal = false

	for j in range(eval_expression.length()):
		var c = eval_expression[j]
		if c.is_valid_int():
			num_buffer += c
		elif c == ".":
			num_buffer += c
			has_decimal = true
		else:
			if num_buffer != "":
				if has_decimal:
					modified_expression += num_buffer
				else:
					modified_expression += num_buffer + ".0"
				num_buffer = ""
				has_decimal = false
			modified_expression += c
	# Si termina en número, agrégalo como flotante o decimal
	if num_buffer != "":
		if has_decimal:
			modified_expression += num_buffer
		else:
			modified_expression += num_buffer + ".0"

# 	print("Expresión a evaluar: ", modified_expression)

	var expr = Expression.new()
	var err = expr.parse(modified_expression)

	if err == OK:
		var result = expr.execute()
# 		print("Resultado: ", result)
		if result == null:
			_show_syntax_error()
		elif is_inf(result) or str(result) == "inf" or str(result) == "-inf" or str(result) == "nan" or str(result) == "-nan":
			_show_syntax_error()
		else:
			# Mostrar decimales correctamente
			if typeof(result) == TYPE_FLOAT:
				# Limitar a 6 decimales
				var result_str = "%.*f" % [6, result]
				# Si el resultado es un entero, mostrarlo como entero
				if is_equal_approx(result, int(result)):
					result_str = str(int(result))
				else:
					# Eliminar ceros solo después del punto decimal, pero nunca dejar vacío
					while result_str.ends_with("0") and not result_str.ends_with(".0"):
						result_str = result_str.substr(0, result_str.length() - 1)
					# Si termina en punto, eliminar el punto
					if result_str.ends_with("."):
						result_str = result_str.substr(0, result_str.length() - 1)
				display.text = result_str
				expression = result_str
				
			else:
				display.text = str(result)
				expression = str(result)

			AudioUIManager.play("calc_result")
			result_displayed = true
			# Logros por resultados especiales
			if is_equal_approx(result, 69):
				Archivements.unlock_logro(8)
			elif is_equal_approx(result, 420):
				Archivements.unlock_logro(9)
			elif is_equal_approx(result, 666):
				Archivements.unlock_logro(10)
	else:
		_show_syntax_error()

func _add_decimal() -> void:
	# Se busca el último número ingresado para evitar dobles puntos
	var last_number: String = ""
	for i in range(expression.length() - 1, -1, -1):
		if expression[i] in "+-*/":
			break
		last_number = expression[i] + last_number
	if "." in last_number:
		return
	# Si la expresión está vacía o termina en un operador, se añade "0."
	if expression == "" or expression[-1] in "+-*/":
		expression += "0."
	else:
		expression += "."
	display.text = expression

func _toggle_parentheses() -> void:
	# Si los paréntesis están balanceados o el último carácter es un operador o "(" se abre uno nuevo
	var open_count = expression.count("(")
	var close_count = expression.count(")")
	
	# Caso 1: Abrir paréntesis
	if open_count == close_count or expression == "" or expression[-1] in "+-*/^(":
		# No añadimos multiplicación implícita visiblemente
		# Simplemente añadimos el paréntesis abierto
		if expression.length() < MAX_LENGTH:
			expression += "("
	# Caso 2: Cerrar paréntesis
	else:
		# Solo cerramos si hay paréntesis abiertos pendientes
		if open_count > close_count:
			expression += ")"
	
	display.text = expression

func _add_operator(op: String) -> void:
	# Permitir el signo menos inicial incluso en expresión vacía
	if expression == "":
		if op == "-":
			expression += op
		return
	# Si el último carácter es un operador, se reemplaza por el nuevo (evita operadores dobles)
	if expression[-1] in "+-*/":
		expression = expression.substr(0, expression.length() - 1) + op
	elif expression.length() < MAX_LENGTH:
		expression += op
	display.text = expression


func _on__pressed() -> void:
	pass # Replace with function body.


func _on_closebutton_pressed() -> void:
	AudioUIManager.play("button_pressed")
	close_requested.emit()  # Emitir la señal de cierre


func _show_syntax_error():
	display.text = "Syntax Error"
	expression = ""
	await get_tree().create_timer(1.0).timeout
	display.text = "0"



func _apply_percent() -> void:
	# Si la expresión está vacía o termina en operador, no hacer nada
	if expression == "" or expression[-1] in "+-*/%":
		return
	# No permitir dos % seguidos
	if expression.ends_with("%"):
		return
	# Agregar el símbolo % a la expresión
	expression += "%"
	display.text = expression


func _on_button_mouse_entered() -> void:
	AudioUIManager.play("button_hover")


func set_gold_theme() -> void:
	MainContainer.theme = gold_theme
	ButtonGrid.theme = gold_theme
	BarraArriba.theme = up_gold_theme

func set_default_theme() -> void:
	MainContainer.theme = default_theme
	ButtonGrid.theme = default_theme
	BarraArriba.theme = up_default_theme




func _disable_button_focus():
	# Buscar todos los botones en ButtonGrid y desactivar su focus
	for child in ButtonGrid.get_children():
		if child is Button:
			child.focus_mode = Control.FOCUS_NONE
		# Si hay contenedores anidados con botones
		elif child.get_child_count() > 0:
			_disable_focus_recursive(child)
	
	# También desactivar focus del botón de cerrar si existe
	var close_button = get_node_or_null("Panel/CloseButton")
	if close_button and close_button is Button:
		close_button.focus_mode = Control.FOCUS_NONE

func _disable_focus_recursive(node: Node):
	# Función recursiva para desactivar focus en botones anidados
	for child in node.get_children():
		if child is Button:
			child.focus_mode = Control.FOCUS_NONE
		elif child.get_child_count() > 0:
			_disable_focus_recursive(child)
