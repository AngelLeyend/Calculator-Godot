extends OptionButton

@export var group: ButtonGroup


var selected_value: String = ""

signal aspect_ratio_changed(new_ratio)

func _ready():
	# print(group.get_buttons())
	# print(group.get_pressed_button())
	for button in group.get_buttons():
		button.pressed.connect(_on_aspect_ratio_selected.bind(button))
	# print(group.get_pressed_button())
	set_active_aspect_ratio()
	set_resolution()


func set_resolution():
	var video_settings = GlobalConfigFile.load_video_settings()
	var resolution = video_settings["resolution"]
	for i in range(get_item_count()):
		if get_item_text(i) == resolution:
			select(i)
			break





func change_res_options(Resolutions):
	clear()
	for r in Resolutions:
		add_item(r) 



func _on_aspect_ratio_selected(button: BaseButton):
	selected_value = button.text
	emit_signal("aspect_ratio_changed", selected_value)
	
	match selected_value:
		"4:3":
			change_res_options(VideoResolutions.R4_3)
		"16:9":
			change_res_options(VideoResolutions.R16_9)
		"21:9":
			change_res_options(VideoResolutions.R21_9)
		"16:10":
			change_res_options(VideoResolutions.R16_10)
		_:
			print("Aspect ratio not found")

	GlobalConfigFile.save_video_setting("aspect_ratio", selected_value)
	GlobalConfigFile.save_video_setting("resolution", get_item_text(get_selected_id()))
	# print("Ratio seleccionado", selected_value)
	change_window_resolution()
	




func change_window_resolution():
	var resolution = get_item_text(get_selected_id())
	var res_parts = resolution.split("x")
	if res_parts.size() == 2:
		var width = int(res_parts[0])
		var height = int(res_parts[1])
		DisplayServer.window_set_size(Vector2i(width, height))
		# print("Window resolution changed to: ", width, "x", height)
	else:
		print("Invalid resolution format")


func set_active_aspect_ratio():
	var video_settings = GlobalConfigFile.load_video_settings()

	for button in group.get_buttons():
		# print(button.text)
		if button.text == video_settings["aspect_ratio"]:
			button.set_pressed_no_signal(true)
			selected_value = video_settings["aspect_ratio"]
			emit_signal("aspect_ratio_changed", selected_value)
			break
			

	# print(group.get_pressed_button().text) # 4:3,16:9
	match selected_value:
		"4:3":
			change_res_options(VideoResolutions.R4_3)
		"16:9":
			change_res_options(VideoResolutions.R16_9)
		"21:9":
			change_res_options(VideoResolutions.R21_9)
		"16:10":
			change_res_options(VideoResolutions.R16_10)
		_:
			print("Aspect ratio not found")


func _on_item_selected(index:int) -> void:
	# print("Item selected: ", get_item_text(index))
	GlobalConfigFile.save_video_setting("resolution", get_item_text(index))
	GlobalConfigFile.apply_settings()
