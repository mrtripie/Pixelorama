extends VBoxContainer

export var is_camera2:= false
onready var camera: Camera2D = Global.camera2 if is_camera2 else Global.camera

var drag:= false # Could use CameraMovement.drag IF SET TO USE MOUSE RELATIVE (FOR TABLETS)
var zoom:= false # Could maybe be replaced with a CameraMovement one for consistency?
var rotate:= false

var touchscreen_or_tablet:= false # Is a touchscreen or drawing tablet

func _ready():
	get_parent().connect("resized", self, "_parent_resized")


# NOTE: Rotation is messing up:
#   - Rulers

# Nav Icons todo:
#   - Snapping rotation to 15 degree increments
#   - Rounding rotation causes it to not move when going slowly...


# NOTE: Make sure whatever you do that the rulers are updated!
func _gui_input(event):
		if event is InputEventMouseMotion:
			if rotate:
				camera.rotate_camera_around_point(event.relative.x / -5, Global.current_project.size / 2)

			elif zoom:
				# Zoom into the center of the screen
				# TODO: Maybe be better to have this in CameraMovement (having the offset code extracted from the zoom)
				# NOTE: Doesn't support smooth zoom
				var zoom_margin = camera.zoom * event.relative.y / 80
				if camera.zoom + zoom_margin > camera.zoom_min:
					camera.zoom += zoom_margin

				if camera.zoom > camera.zoom_max:
					camera.zoom = camera.zoom_max

				camera.zoom_changed()

			elif drag:
				camera.offset -= camera.zoom * event.relative.rotated(camera.rotation)
				camera.update_transparent_checker_offset()
				camera.update_rulers()

		elif event is InputEventMouseButton:
			touchscreen_or_tablet = event.device == -1
			if event.button_index == BUTTON_RIGHT and event.pressed:
				if $Rotate.get_rect().has_point(get_local_mouse_position()):
					camera.set_camera_rotation_degrees(0)
				elif $Zoom.get_rect().has_point(get_local_mouse_position()):
					if Input.is_key_pressed(KEY_CONTROL):
						camera.zoom_100()
					else:
						camera.fit_to_frame(Global.current_project.size)
				elif $Pan.get_rect().has_point(get_local_mouse_position()):
					camera.offset = Global.current_project.size / 2


func _parent_resized():
	visible = get_parent().rect_size.x > rect_size.x


func _on_Rotate_button_down():
	yield(get_tree(), "idle_frame") # Wait to make sure it knows if using touchscreen/tablet
	rotate = true
#	if not touchscreen_or_tablet:
#		# MOUSE_MODE_CAPTURED prevents reaching the screen boundary, allowing infinite movement,
#		# but doesn't agree with touchscreens or drawing tablets
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Zoom_button_down():
	yield(get_tree(), "idle_frame")
	zoom = true
#	if not touchscreen_or_tablet:
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Pan_button_down():
	yield(get_tree(), "idle_frame")
	drag = true
#	if not touchscreen_or_tablet:
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Rotate_button_up():
	rotate = false
	camera.set_camera_rotation_degrees(round(camera.rotation_degrees))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	warp_mouse($Rotate.rect_position + $Rotate.rect_size / 2)


func _on_Zoom_button_up():
	zoom = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	warp_mouse($Zoom.rect_position + $Zoom.rect_size / 2)


func _on_Pan_button_up():
	drag = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	warp_mouse($Pan.rect_position + $Pan.rect_size / 2)
