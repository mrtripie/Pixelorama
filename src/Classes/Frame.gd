class_name Frame
extends Reference
# A class for frame properties.
# A frame is a collection of cels, for each layer.

var index := 0 # TODO: Make sure to set the index when opening a project!
var cels: Array  # An array of Cels
var duration := 1.0


func _init(_cels := [], _duration := 1.0) -> void:
	cels = _cels
	duration = _duration


func instantiate_frame_button() -> Node:
	var frame_button = Global.frame_button_node.instance()
	frame_button.frame = self
	return frame_button
