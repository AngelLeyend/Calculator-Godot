extends Control

signal end_game # Señal para indicar que el juego ha terminado

# Tus claves de localización del CSV
var dialogs := [
    {"key": "sumiko_end1", "sprite": 0},
    {"key": "sumiko_end2", "sprite": 1},
    {"key": "sumiko_end3", "sprite": 2},
    {"key": "sumiko_end4", "sprite": 0},
    {"key": "sumiko_end5", "sprite": 3}
]

var sumiko_sprites := [
    preload("res://assets/sprites/sumiko/sumiko_1.png"),
    preload("res://assets/sprites/sumiko/sumiko_2.png"),
    preload("res://assets/sprites/sumiko/sumiko_3.png"),
    preload("res://assets/sprites/sumiko/sumiko_4.png"),
]

var sumiko_jump_height := -18
var sumiko_jump_duration := 0.11
var sumiko_jump_rest := 0.10

@onready var sumiko_sprite: TextureRect = $SumikoSprite

var current_dialog := 0 # Índice de diálogo actual
var is_typing := false
var skip_typewriting := false
var ending_finished := false # Nueva bandera para evitar múltiples emisiones
var is_processing_input := false # Nueva bandera para evitar inputs múltiples
var current_typing_tween: Tween # Referencia al tween actual de tipeo
var input_cooldown := false # Cooldown para evitar inputs muy rápidos

@export var type_speed := 0.04 # Velocidad de máquina de escribir (s)
@export var input_cooldown_time := 0.1 # Tiempo de cooldown entre inputs

# Rutas actualizadas a tus nodos:
@onready var dialog_label: RichTextLabel = $DialogueContainer/MarginContainer/DialogueLabel
# @onready var type_snd: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
    show_dialog()

func show_dialog():
    if is_processing_input or ending_finished:
        return
        
    is_processing_input = true
    var dialog_data = dialogs[current_dialog]
    var full_line := tr(dialog_data["key"]).strip_edges()
    
    # Reproducir voz para este diálogo
    VoiceManager.play_voice(dialog_data["key"])

    await sumiko_jump_and_next_sprite(dialog_data["sprite"]) # <-- ahora espera el salto y cambio de sprite
    await type_line(full_line)
    
    is_processing_input = false

func _unhandled_input(event):
    if ending_finished or input_cooldown:
        return
        
    # Solo procesar eventos de tecla presionada
    if event is InputEventKey and event.pressed and event.is_action_pressed("ui_accept"):
        _handle_dialog_advance()

func _handle_dialog_advance():
    if input_cooldown or ending_finished:
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
    if is_processing_input or ending_finished:
        return
        
    current_dialog += 1
    if current_dialog < dialogs.size():
        show_dialog()
    else:
        end_game_sequence()

func end_game_sequence():
    if ending_finished:
        return # Evitar llamadas múltiples
        
    # Detener voz
    VoiceManager.stop_voice()


    # Cancelar cualquier tween de tipeo activo
    if current_typing_tween:
        current_typing_tween.kill()
        
    dialog_label.text = ""
    ending_finished = true
    is_processing_input = false
    emit_signal("end_game") # Emitir señal al terminar el diálogo

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
    if ending_finished or input_cooldown:
        return
        
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_dialog_advance()

func _on_panel_gui_input(event: InputEvent) -> void:
    _on_gui_input(event)

func _on_dialogue_container_gui_input(event: InputEvent) -> void:
    _on_gui_input(event)

func _on_skip_button_pressed() -> void:
    if ending_finished:
        return
        
    AudioUIManager.play("button_play")
    $SkipButton.release_focus() # Quita el foco del botón

    # Si está tipeando, muestra el texto completo
    if is_typing:
        skip_typewriting = true
        await get_tree().process_frame # Espera un frame para que el tipeo termine

    # Termina el ending
    end_game_sequence()

func sumiko_jump_and_next_sprite(sprite_index: int) -> void:
    var original_pos = sumiko_sprite.position
    sumiko_sprite.texture = sumiko_sprites[sprite_index] # Cambia el sprite justo después del salto
    var tween = create_tween()
    tween.tween_property(sumiko_sprite, "position:y", original_pos.y + sumiko_jump_height, sumiko_jump_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(sumiko_sprite, "position:y", original_pos.y, sumiko_jump_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    
    await tween.finished # Espera a que termine el salto

func _on_skip_button_mouse_entered() -> void:
    AudioUIManager.play("button_hover")