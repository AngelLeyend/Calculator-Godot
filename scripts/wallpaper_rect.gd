extends TextureRect
@onready var WallpapersContainer = "res://scenes/wallpaper_screen.tscn"



func _ready():
	var video_settings=GlobalConfigFile.load_video_settings()
	var texture_path = "res://assets/sprites/wallpapers/%d.png" % video_settings["wallpaper"]

	self.texture = load(texture_path)
