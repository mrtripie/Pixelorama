class_name LayerBlendShaderFactory
extends Reference
# Generates a shader for blending layers

# Requirements:
# - Build a shader for a project, while building shaders for group layers
# - Handle placement of uniforms (shader properties)
# - Skip drawing layers that aren't visible or have 0 op
# - Handle placement of functions for effects
# - Blend Modes
# - Image effects preview (like HSV adjust)
# - FX Layers
# - Onion Skinning? (Has to be done somewhere, not sure if here?)

# Perhaps there is a noticable peformance difference in string formatting and adding?
# what about PoolStringArray.join? (not sure about Godot 4 with that though)

# Not sure if it would be better to just return the code...
func create_project_blend_shader_code(project) -> void:
	var uniforms := ""
	var funcs := {}

	var fragment := "void fragment(){\nCOLOR=vec4(0,0,0,0);\n"

	# Add group variables ahead of time, maybe can be while? # did I mean white or a while loop? # is this needed?
	for layer in project.layers:
		if not layer.is_visible_in_hierarchy():
			continue
		# TODO: Probably makes sense for fx to be placed here, where they will
		# be responsible for sampling the texture and setting the layer color
		# Of course, Group FX would need to be done later...
		if layer is PixelLayer:
			var l := str("l", layer.index)
			fragment += str("vec4 ", l, "=texture(", "t", layer.index, ",UV);", l, ".rgb=", l, ".rgb*", l, ".a;")
		elif layer is GroupLayer:
			fragment += str("vec4 l", layer.index, "=vec4(0,0,0,0);")

	fragment += "\n" # make shader a little more readable

	for layer in project.layers:
		if not layer.is_visible_in_hierarchy(): # Skip invisible layers
			continue
		var l := str("l", layer.index)
		if layer is PixelLayer:
			var t := str("t", layer.index)
			var o := str("o", layer.index)
			uniforms += str("uniform sampler2D ", t, ";uniform float ", o, ";") # Why are the uniforms mixed into the blend code?

			if layer.parent:
				var out := str("l", layer.parent.index)
				fragment += blend(layer.blend_mode, out, l, o)
			else:
				fragment += blend(layer.blend_mode, "COLOR", l, o)
		elif layer is GroupLayer:
			var o := str("o", layer.index)
			uniforms += str("uniform float ", o, ";")
			if layer.parent:
				var out := str("l", layer.parent.index)
				fragment += blend(layer.blend_mode, out, l, o)
			else:
				fragment += blend(layer.blend_mode, "COLOR", l, o)

	fragment += "}"

	project.layer_blend_shader.code = "shader_type canvas_item;render_mode blend_premul_alpha;\n" + uniforms + "\n" + BLEND_MODES.alpha + fragment
	print(project.layer_blend_shader.code)


const BLEND_MODES = {
	"alpha": "vec4 alpha(vec4 d,vec4 s,float o){s.rgb=s.rgb*o;s.a=s.a*o; d.rgb=d.rgb*(1.-s.a)+s.rgb;  d.a=d.a*(1.-s.a)+s.a;return d;}\n" # WIKIPEDIA PREMULTIPLIED
}


# TODO: Wondering about Shader.custom_defines and if it could optimize blend modes?
# TODO: Investigate if adding these as shader functions helps performance
# TODO: Ensure these are actually blending correctly in all situations
func blend(mode: String, out: String, col: String, op: String) -> String:
	match mode:
		"alpha":
			return str(out, "=alpha(", out, ",", col, ",", op, ");")
	return ""
