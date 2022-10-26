class_name Frame
extends Reference
# A class for frame properties.
# A frame is a collection of cels, for each layer.

# TODO: Make sure to set a reference to this in FrameButton whenever one is created...
var index := 0 # TODO: Make sure to set the index when opening a project, or changing frames
var cels: Array  # An array of Cels
var duration := 1.0


func _init(_cels := [], _duration := 1.0) -> void:
	cels = _cels
	duration = _duration

# TODO: Maybe there should be instantiate_frame_button for consistentcy?
