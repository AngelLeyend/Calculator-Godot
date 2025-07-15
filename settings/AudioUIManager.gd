extends Node

var num_players = 8
var bus = "SFX"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.




@onready var sounds = {
	"calc_number": preload("res://assets/sounds/ui/switch13.ogg"),
	"calc_operator": preload("res://assets/sounds/ui/switch14.ogg"),
	"calc_result": preload("res://assets/sounds/ui/confirmation_001.ogg"),
	"button_pressed": preload("res://assets/sounds/ui/click3.ogg"),
	"button_toggle": preload("res://assets/sounds/ui/switch8.ogg"),
	"button_hover": preload("res://assets/sounds/ui/rollover2.ogg"),
	"sumiko_hover": preload("res://assets/sounds/ui/phaseJump1.ogg"),
	"window_open": preload("res://assets/sounds/ui/maximize_008.ogg"),
	"window_close": preload("res://assets/sounds/ui/minimize_008.ogg"),
	"menu_open": preload("res://assets/sounds/ui/maximize_006.ogg"),
	"menu_close": preload("res://assets/sounds/ui/minimize_006.ogg"),
	"unlocked_archv": preload("res://assets/sounds/ui/jingles_STEEL04.ogg"),
	"show_popup": preload("res://assets/sounds/ui/question_004.ogg"),
	"ringtone": preload("res://assets/sounds/ui/zapTwoTone2.ogg"),
}

func _ready():
	for i in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus

func _on_stream_finished(player):
	available.append(player)

func play(sound_id: String):
	if sounds.has(sound_id):
		queue.append(sounds[sound_id])
	else:
		push_warning("Sound ID not found: %s" % sound_id)

func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		var player = available.pop_front()
		player.stream = queue.pop_front()
		player.play()
