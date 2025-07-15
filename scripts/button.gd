extends Button

@onready var polygon = $Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pressed() -> void:
	polygon.visible = not polygon.visible  # Alterna entre visible/invisible
