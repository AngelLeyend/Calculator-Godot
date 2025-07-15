extends Node

signal song_index_changed(new_index)
signal pause_song()
signal next_song()
signal previous_song()
signal song_position_changed()
signal song_finished()
# signal is_song_looped_changed(is_looped)
# signal is_song_random_changed(is_random)


var current_song_index = 0
var song_actual_position = 0
var is_song_looped = false
var is_song_random = false


func song_paused():
	emit_signal("pause_song")
# 	print("Song paused")

func get_song_index():
	return current_song_index

func set_song_index(index):
	current_song_index = index
	emit_signal("song_index_changed", current_song_index)

# 	print("Current song index set to:", current_song_index)


func play_next_song():
	emit_signal("next_song")
# 	print("Next song requested")

func play_previous_song():
	emit_signal("previous_song")
# 	print("Previous song requested")

func set_song_position():
	emit_signal("song_position_changed")
# 	print("Song position set to:", song_actual_position)
	
func song_finish():
	emit_signal("song_finished")
# 	print("Song finished")
