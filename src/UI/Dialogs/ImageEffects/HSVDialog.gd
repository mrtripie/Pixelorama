extends ImageEffect

var shader: Shader = preload("res://src/Shaders/HSV.shader")
var live_preview := true

onready var hue_slider: ValueSlider = $VBoxContainer/HueSlider
onready var sat_slider: ValueSlider = $VBoxContainer/SaturationSlider
onready var val_slider: ValueSlider = $VBoxContainer/ValueSlider
onready var wait_apply_timer: Timer = $WaitApply
onready var wait_time_slider: ValueSlider = $VBoxContainer/WaitTime


func _ready() -> void:
	var sm := ShaderMaterial.new()
	sm.shader = shader
	preview.set_material(sm)


func _about_to_show() -> void:
	_reset()
	._about_to_show()


func set_nodes() -> void:
	preview = $VBoxContainer/AspectRatioContainer/Preview
	selection_checkbox = $VBoxContainer/AffectHBoxContainer/SelectionCheckBox
	affect_option_button = $VBoxContainer/AffectHBoxContainer/AffectOptionButton


func commit_action(cel: Image, project: Project = Global.current_project) -> void:
	var selection_tex := ImageTexture.new()
	if selection_checkbox.pressed and project.has_selection:
		selection_tex.create_from_image(project.selection_map, 0)

	var params := {
		"hue_shift_amount": hue_slider.value / 360,
		"sat_shift_amount": sat_slider.value / 100,
		"val_shift_amount": val_slider.value / 100,
		"selection": selection_tex,
		"affect_selection": selection_checkbox.pressed,
		"has_selection": project.has_selection
	}
	if !confirmed:
		for param in params:
			preview.material.set_shader_param(param, params[param])
	else:
		var gen := ShaderImageEffect.new()
		gen.generate_image(cel, shader, params, project.size)
		yield(gen, "done")


func _reset() -> void:
	wait_apply_timer.wait_time = wait_time_slider.value / 1000.0
	hue_slider.value = 0
	sat_slider.value = 0
	val_slider.value = 0
	confirmed = false


func _on_HueSlider_value_changed(_value: float) -> void:
	if live_preview:
		update_preview()
	else:
		wait_apply_timer.start()


func _on_SaturationSlider_value_changed(_value: float) -> void:
	if live_preview:
		update_preview()
	else:
		wait_apply_timer.start()


func _on_ValueSlider_value_changed(_value: float) -> void:
	if live_preview:
		update_preview()
	else:
		wait_apply_timer.start()


func _on_WaitApply_timeout() -> void:
	update_preview()


func _on_WaitTime_value_changed(value: float) -> void:
	wait_apply_timer.wait_time = value / 1000.0


func _on_LiveCheckbox_toggled(button_pressed: bool) -> void:
	live_preview = button_pressed
	wait_time_slider.editable = !live_preview
	wait_time_slider.visible = !live_preview
