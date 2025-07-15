extends Control

const ADVICE_COUNT := 15 # Cambia este valor según la cantidad de consejos


var current_advice_key := ""
var is_typing := false
var skip_typewriting := false
@export var type_speed := 0.04 # Velocidad de máquina de escribir (s)
var sumiko_hover_tween: Tween = null
var used_advice_numbers: Array[int] = [] # Array para rastrear consejos usados

# Variables para evitar bugs de múltiples presiones
var dialog_tween: Tween = null
var is_dialog_opening := false
var jump_tween: Tween = null


# Rutas actualizadas a tus nodos:
@onready var dialog_label: RichTextLabel = $ConsejosLayer/DialogueContainer/MarginContainer/DialogueLabel
@onready var type_snd: AudioStreamPlayer = $AudioStreamPlayer
@onready var canvas = $ConsejosLayer
@onready var sumiko_button: TextureButton = $SumikoButton

@onready var DialogPanel: PanelContainer = $ConsejosLayer/DialogueContainer
@onready var SumikoSprite: TextureRect = $ConsejosLayer/TextureRect


func _ready():
    # ...otros setups...
    var size = sumiko_button.size
    sumiko_button.pivot_offset = Vector2(size.x / 2, size.y)

func _on_sumiko_button_pressed() -> void:
    AudioUIManager.play("button_pressed")
    
    # Evitar múltiples presiones mientras se está abriendo o ya está visible
    if is_typing or canvas.visible or is_dialog_opening:
        return
    
    # Cancelar cualquier tween anterior para evitar conflictos
    _cleanup_tweens()
    
    is_dialog_opening = true
    
    # Si ya se han usado todos los consejos, reinicia la lista
    if used_advice_numbers.size() >= ADVICE_COUNT:
        used_advice_numbers.clear()
    
    var random_num: int
    # Genera un número que no esté en la lista de usados
    while true:
        random_num = randi_range(1, ADVICE_COUNT)
        if random_num not in used_advice_numbers:
            break
    
    # Agrega el número a la lista de usados
    used_advice_numbers.append(random_num)
    current_advice_key = "sumiko_advice%d" % random_num

    # Resetear estados
    dialog_label.text = ""
    DialogPanel.modulate.a = 0.0
    SumikoSprite.modulate.a = 0.0
    canvas.show()

    # FADE IN y SALTO AL MISMO TIEMPO (como antes)
    dialog_tween = create_tween()
    dialog_tween.parallel().tween_property(DialogPanel, "modulate:a", 1.0, 0.5)
    dialog_tween.parallel().tween_property(SumikoSprite, "modulate:a", 1.0, 0.5)
    
    # Inicia el salto inmediatamente, sin esperar
    sumiko_jump_and_next_sprite()
    
    await dialog_tween.finished
    is_dialog_opening = false
    await show_dialog()
    
    sumiko_button.release_focus()

func show_dialog():
    var full_line := tr(current_advice_key).strip_edges()
    await type_line(full_line)

func _unhandled_input(event):
    if SaveManager.game_data["beginning"]==0:
        if event.is_action_pressed("sumiko_open") and not canvas.visible and not is_typing and not is_dialog_opening:
            _on_sumiko_button_pressed()
        if event.is_action_pressed("ui_accept"):
            if is_typing:
                skip_typewriting = true
            elif canvas.visible and not is_dialog_opening:
                await hide_dialog_with_fade()

# Función de tipeo mejorada
func type_line(line: String) -> void:
    is_typing = true
    skip_typewriting = false

    for i in line.length():
        # Verificar si el diálogo sigue abierto
        if not canvas.visible:
            break
            
        if skip_typewriting:
            dialog_label.text = line
            break
        
        dialog_label.text += line[i]
        
        # Reproducir sonido solo si no está ya reproduciéndose
        if type_snd.stream and not type_snd.playing:
            type_snd.play()
        
        await get_tree().create_timer(type_speed).timeout

    is_typing = false
    skip_typewriting = false

func _on_panel_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if is_typing:
            skip_typewriting = true
        elif not is_dialog_opening:
            await hide_dialog_with_fade()

func hide_dialog_with_fade():
    # Evitar múltiples llamadas simultáneas
    if not canvas.visible or is_dialog_opening:
        return
    
    # Limpiar todos los tweens y estados
    _cleanup_tweens()
    is_typing = false
    skip_typewriting = false
    
    dialog_tween = create_tween()
    dialog_tween.parallel().tween_property(DialogPanel, "modulate:a", 0.0, 0.3)
    dialog_tween.parallel().tween_property(SumikoSprite, "modulate:a", 0.0, 0.3)
    
    await dialog_tween.finished
    canvas.hide()
    dialog_label.text = ""

func sumiko_jump_and_next_sprite() -> void:
    # Cancelar salto anterior si existe
    if jump_tween and jump_tween.is_valid():
        jump_tween.kill()
        
    var original_pos = SumikoSprite.position
    var jump_height = -18
    var jump_duration = 0.11
    
    jump_tween = create_tween()
    jump_tween.tween_property(SumikoSprite, "position:y", original_pos.y + jump_height, jump_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    jump_tween.tween_property(SumikoSprite, "position:y", original_pos.y, jump_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _on_sumiko_button_mouse_entered() -> void:
    # Solo hacer hover si el diálogo no está abierto
    if canvas.visible:
        return
        
    AudioUIManager.play("sumiko_hover")
    # Cancela tween anterior si existe
    if sumiko_hover_tween and sumiko_hover_tween.is_valid():
        sumiko_hover_tween.kill()
    
    sumiko_button.scale = Vector2.ONE
    var original_scale = sumiko_button.scale
    sumiko_hover_tween = create_tween()
    sumiko_hover_tween.tween_property(sumiko_button, "scale", original_scale * Vector2(1.15, 1.15), 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    sumiko_hover_tween.tween_property(sumiko_button, "scale", original_scale, 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _on_sumiko_button_mouse_exited() -> void:
    # Cancela tween y restaura escala
    if sumiko_hover_tween and sumiko_hover_tween.is_valid():
        sumiko_hover_tween.kill()
    sumiko_button.scale = Vector2.ONE

# Función auxiliar para limpiar todos los tweens
func _cleanup_tweens():
    if dialog_tween and dialog_tween.is_valid():
        dialog_tween.kill()
    if jump_tween and jump_tween.is_valid():
        jump_tween.kill()
    if sumiko_hover_tween and sumiko_hover_tween.is_valid():
        sumiko_hover_tween.kill()