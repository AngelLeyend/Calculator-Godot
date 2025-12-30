extends Control

signal end_intro # Señal para indicar que la introducción ha terminado

# Tus claves de localización del CSV
var dialogs := [
    {"key": "sumiko_dialog1", "sprite": 0},
    {"key": "sumiko_dialog2", "sprite": 1},
    {"key": "sumiko_dialog3", "sprite": 2},
    {"key": "sumiko_dialog4", "sprite": 3},
    {"key": "sumiko_dialog5", "sprite": 0},
    {"key": "sumiko_dialog6", "sprite": 1},
    {"key": "sumiko_dialog7", "sprite": 2},
    {"key": "sumiko_dialog8", "sprite": 3},
]

var bbcode_icons := {
    "[world_icon]": "[img=50]res://assets/sprites/world.png[/img]",
    "[home_icon]": "[img=50]res://assets/sprites/home.png[/img]",
    # Agrega más iconos aquí
}

var sumiko_sprites := [
    preload("res://assets/sprites/sumiko/sumiko_1.png"),
    preload("res://assets/sprites/sumiko/sumiko_2.png"),
    preload("res://assets/sprites/sumiko/sumiko_3.png"),
    preload("res://assets/sprites/sumiko/sumiko_4.png"),
]

var sumiko_jump_height := -18 # Altura del salto (negativo porque Y crece hacia abajo)
var sumiko_jump_duration := 0.11 # Duración del salto (s)
var sumiko_jump_rest := 0.10

var current_dialog := 0 # Índice de diálogo actual
var is_typing := false
var skip_typewriting := false
var intro_finished := false # Nueva bandera para evitar múltiples emisiones
var is_intro_running := false # Bandera para controlar el estado de la introducción
var ringtone_looping := false
var is_processing_input := false # Nueva bandera para evitar inputs múltiples
var current_typing_tween: Tween # Referencia al tween actual de tipeo
var input_cooldown := false # Cooldown para evitar inputs muy rápidos

@export var type_speed := 0.04 # Velocidad de máquina de escribir (s)
@export var input_cooldown_time := 0.1 # Tiempo de cooldown entre inputs

# Rutas actualizadas a tus nodos:
@onready var dialog_label: RichTextLabel = $CanvasLayer/DialogueContainer/MarginContainer/DialogueLabel
# @onready var type_snd: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var canvas = $CanvasLayer
@onready var button = $SumikoIntroButton
@onready var panel = $Panel
@onready var sumiko_sprite: TextureRect = $CanvasLayer/SumikoSprite

func _ready():
    # show_dialog()
    sumiko_sprite.texture = sumiko_sprites[dialogs[0]["sprite"]] # Solo muestra el sprite inicial
    button_animation() # Llama a la animación del botón al inicio

func show_dialog():
    if is_processing_input or intro_finished:
        return
        
    is_processing_input = true
    var dialog_data = dialogs[current_dialog]
    var full_line := tr(dialog_data["key"]).strip_edges()
    
    # Reemplaza los tags clave por su BBCode real
    for tag in bbcode_icons.keys():
        full_line = full_line.replace(tag, bbcode_icons[tag])
    

    # Reproducir voz para este diálogo
    VoiceManager.play_voice(dialog_data["key"])


    await sumiko_jump_and_next_sprite(dialog_data["sprite"]) # <-- ahora espera el salto y cambio de sprite
    await type_line(full_line)
    
    is_processing_input = false

func _unhandled_input(event):
    if intro_finished or input_cooldown:
        return
        
    # Solo procesar eventos de tecla presionada
    if event is InputEventKey and event.pressed:
        if event.is_action_pressed("sumiko_open") and not is_intro_running:
            _on_sumiko_intro_button_pressed()
            return
            
        if is_intro_running and event.is_action_pressed("ui_accept"):
            _handle_dialog_advance()

func _handle_dialog_advance():
    if input_cooldown or intro_finished:
        return
        
    # Activar cooldown para evitar inputs muy rápidos
    input_cooldown = true
    get_tree().create_timer(input_cooldown_time).timeout.connect(_reset_input_cooldown)
    
    if is_typing:
        skip_typewriting = true
    elif not is_processing_input:
        _advance_dialog()

func _reset_input_cooldown():
    input_cooldown = false

func _advance_dialog():
    if is_processing_input or intro_finished:
        return
        
    current_dialog += 1
    if current_dialog < dialogs.size():
        show_dialog()
    else:
        dialog_label.text = ""
        end_intro_sequence()

# Función de tipeo, corregida para no mostrar el texto de nuevo al terminar
func type_line(line: String) -> void:
    # Cancelar cualquier tween de tipeo anterior
    if current_typing_tween:
        current_typing_tween.kill()
    
    dialog_label.text = ""
    is_typing = true
    skip_typewriting = false
    
    # Crear nuevo tween para el tipeo
    current_typing_tween = create_tween()
    
    var i = 0
    while i < line.length() and not skip_typewriting:
        if skip_typewriting:
            dialog_label.text = line
            break

        # Si encuentra un tag de imagen, agregarlo de golpe
        if line.substr(i, 5) == "[img=" or line.substr(i, 4) == "[img":
            var tag_start = i
            var tag_end = line.find("[/img]", i)
            if tag_end != -1:
                tag_end += 6 # incluir [/img]
                var tag = line.substr(tag_start, tag_end - tag_start)
                dialog_label.text += tag
                i = tag_end
                continue

        # Otros tags BBCode (como [b], [color], etc.)
        if line[i] == "[":
            var tag_end = line.find("]", i)
            if tag_end != -1:
                var tag = line.substr(i, tag_end - i + 1)
                dialog_label.text += tag
                i = tag_end + 1
                continue

        dialog_label.text += line[i]
        i += 1

        # if type_snd and type_snd.stream:
        #     type_snd.stop()
        #     type_snd.play()
            
        if not skip_typewriting:
            await get_tree().create_timer(type_speed).timeout

    # Si se saltó el tipeo, mostrar todo el texto
    if skip_typewriting:
        dialog_label.text = line

    is_typing = false
    skip_typewriting = false
    current_typing_tween = null

func _on_gui_input(event: InputEvent) -> void:
    if not is_intro_running or intro_finished or input_cooldown:
        return
        
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_dialog_advance()

func _on_panel_gui_input(event: InputEvent) -> void:
    _on_gui_input(event)

func _on_dialogue_container_gui_input(event: InputEvent) -> void:
    _on_gui_input(event)

func _on_sumiko_intro_button_pressed() -> void:
    if is_intro_running or intro_finished:
        return # Ya está corriendo o terminó, no hacer nada

    AudioUIManager.play("button_pressed")
    stop_button_animation()
    button.release_focus() # <-- Esto quita el foco del botón
    panel.hide()
    
    # Hacer invisibles todos los hijos del CanvasLayer
    for child in canvas.get_children():
        if child.has_method("set_modulate"):
            child.modulate.a = 0.0
        elif child.has_property("modulate"):
            child.modulate.a = 0.0
    
    canvas.show()
    
    # Fade in para todos los hijos del CanvasLayer
    for child in canvas.get_children():
        if child.has_method("set_modulate") or child.has_property("modulate"):
            var tween = create_tween()
            tween.tween_property(child, "modulate:a", 1.0, 0.7)
    
    is_intro_running = true
    show_dialog()
    button.hide() # Oculta el botón después de presionar

# Añade esta función para aplicar fade a todos los descendientes
func fade_children_alpha(node: Node, target_alpha: float, duration: float) -> void:
    for child in node.get_children():
        if child.has_method("set_modulate") or child.has_property("modulate"):
            var tween = create_tween()
            tween.tween_property(child, "modulate:a", target_alpha, duration)
        # Llama recursivamente para hijos anidados
        fade_children_alpha(child, target_alpha, duration)

# Modifica donde termina la intro para hacer el fade out
func end_intro_sequence():
    if intro_finished:
        return # Evitar llamadas múltiples
        
    # Detener voz
    VoiceManager.stop_voice()

    # Cancelar cualquier tween de tipeo activo
    if current_typing_tween:
        current_typing_tween.kill()
        
    fade_children_alpha(canvas, 0.0, 0.7) # Fade out a todos los hijos
    intro_finished = true
    is_intro_running = false
    is_processing_input = false

    SaveManager.show_game_data()
    SaveManager.update_game_data("beginning", 0)
    SaveManager.show_game_data()
    emit_signal("end_intro")

func button_animation():
    # Cancelar cualquier tween anterior del botón
    if button.has_meta("heartbeat_tween"):
        var old_tween = button.get_meta("heartbeat_tween")
        if old_tween and old_tween.is_valid():
            old_tween.kill()
    
    # --- NUEVO: Centrar el pivot del botón ---
    button.pivot_offset = button.size / 2

    # Crear un nuevo tween en bucle para el efecto heartbeat
    var tween = create_tween()
    tween.set_loops() # Hacer que se repita indefinidamente
    
    # Guardar escala original
    var original_scale = button.scale
    
    # Primer latido (más grande)
    tween.tween_callback(Callable(self, "_play_ringtone"))
    tween.tween_property(button, "scale", original_scale * 1.2, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(button, "scale", original_scale, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    
    # Pequeña pausa
    tween.tween_property(button, "scale", original_scale, 0.1)
    
    # Segundo latido (más pequeño)
    tween.tween_property(button, "scale", original_scale * 1.12, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(button, "scale", original_scale, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    
    # Período de descanso
    tween.tween_property(button, "scale", original_scale, 0.8)
    
    # Almacena la referencia al tween para poder cancelarlo cuando sea necesario
    button.set_meta("heartbeat_tween", tween)

func stop_button_animation():
    if button.has_meta("heartbeat_tween"):
        var tween = button.get_meta("heartbeat_tween")
        if tween and tween.is_valid():
            tween.kill()
        button.scale = Vector2(1.0, 1.0)  # Restaurar escala original

func _on_skip_button_pressed() -> void:
    if intro_finished:
        return
        
    $CanvasLayer/SkipButton.release_focus() # Quita el foco del botón

    # Si está tipeando, muestra el texto completo
    if is_typing:
        skip_typewriting = true
        await get_tree().process_frame # Espera un frame para que el tipeo termine

    # Termina la intro
    end_intro_sequence()

func sumiko_jump_and_next_sprite(sprite_index: int) -> void:
    var original_pos = sumiko_sprite.position
    sumiko_sprite.texture = sumiko_sprites[sprite_index] # Cambia el sprite justo después del salto
    var tween = create_tween()
    tween.tween_property(sumiko_sprite, "position:y", original_pos.y + sumiko_jump_height, sumiko_jump_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(sumiko_sprite, "position:y", original_pos.y, sumiko_jump_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    
    await tween.finished # Espera a que termine el salto

func _on_sumiko_intro_button_mouse_entered() -> void:
    AudioUIManager.play("sumiko_hover")

func _play_ringtone():
    AudioUIManager.play("ringtone")

func _on_button_hovered() -> void:
    # Reproducir sonido al pasar el mouse sobre un botón
    AudioUIManager.play("button_hover")