extends Node

const VOICE_PATH := "res://assets/sounds/voices/"
const VOICE_BUS := "Voice"

var current_voice: AudioStreamPlayer = null
var voice_streams: Dictionary = {} # Cache de streams cargados

func _ready():
    # Pre-cargar los streams si quieres (opcional)
    pass

func play_voice(dialog_key: String) -> void:
    # Detener voz anterior si existe
    if current_voice and current_voice.playing:
        current_voice.stop()
    
    # Construir la ruta del archivo
    var voice_file := VOICE_PATH + dialog_key + ".ogg"
    
    # Usar ResourceLoader.exists() en lugar de FileAccess.file_exists()
    # FileAccess no funciona en exportaciones web para res://
    if not ResourceLoader.exists(voice_file):
        print("Voice file not found: ", voice_file)
        return
    
    # Cargar el stream (o usar cache)
    var stream: AudioStream
    if voice_streams.has(dialog_key):
        stream = voice_streams[dialog_key]
    else:
        stream = load(voice_file)
        if stream:
            voice_streams[dialog_key] = stream
        else:
            print("Failed to load voice: ", voice_file)
            return
    
    # Crear un nuevo AudioStreamPlayer
    if current_voice:
        current_voice.queue_free()
    
    current_voice = AudioStreamPlayer.new()
    add_child(current_voice)
    current_voice.stream = stream
    current_voice.bus = VOICE_BUS
    current_voice.finished.connect(_on_voice_finished)
    current_voice.play()

func stop_voice() -> void:
    if current_voice and current_voice.playing:
        current_voice.stop()

func _on_voice_finished() -> void:
    if current_voice:
        current_voice.queue_free()
        current_voice = null