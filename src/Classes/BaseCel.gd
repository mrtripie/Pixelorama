class_name BaseCel
extends Reference
# Base class for cel properties.
# The term "cel" comes from "celluloid" (https://en.wikipedia.org/wiki/Cel).

var frame: Frame
var layer: BaseLayer

var opacity: float
var image_texture: ImageTexture
# If the cel is linked a ref to the link set Dictionary this cel is in, or null if not linked:
var link_set = null  # { "cels": Array, "hue": float } or null


# Links to link_set if its a Dictionary, or unlinks if null.
# Content/image_texture are handled seperately for undo related reasons
func link(new_link_set = null) -> void:
	# Erase from the current link_set
	if link_set != null:
		if link_set.has("cels"):
			link_set["cels"].erase(self)
			if link_set["cels"].empty():
				layer.cel_link_sets.erase(link_set)
		else:
			layer.cel_link_sets.erase(link_set)
	# Add to new_link_set
	link_set = new_link_set
	if new_link_set != null:
		if not new_link_set.has("cels"):
			new_link_set["cels"] = []
		new_link_set["cels"].append(self)
		if not layer.cel_link_sets.has(new_link_set):
			if not new_link_set.has("hue"):
				var hues := PoolRealArray()
				for other_link_set in layer.cel_link_sets:
					hues.append(other_link_set["hue"])
				if hues.empty():
					new_link_set["hue"] = Color.green.h
				else:  # Calculate the largest gap in hue between existing link sets:
					hues.sort()
					# Start gap between the highest and lowest hues, otherwise its hard to include
					var largest_gap_pos := hues[-1]
					var largest_gap_size := 1.0 - (hues[-1] - hues[0])
					for h in hues.size() - 1:
						var gap_size: float = hues[h + 1] - hues[h]
						if gap_size > largest_gap_size:
							largest_gap_pos = hues[h]
							largest_gap_size = gap_size
					new_link_set["hue"] = wrapf(largest_gap_pos + largest_gap_size / 2.0, 0, 1)
			layer.cel_link_sets.append(new_link_set)


# Methods to Override:


# The content methods deal with the unique content of each cel type. For example, an Image for
# PixelLayers, or a Dictionary of settings for a procedural layer type, and null for Groups.
# Can be used fo linking/unlinking cels, copying, and deleting content
func get_content():
	return null


func set_content(_content, _texture: ImageTexture = null) -> void:
	return


# Can be used to delete the content of the cel with set_content
# (using the old content from get_content as undo data)
func create_empty_content():
	return []


# Can be used for creating copy content for copying cels or unlinking cels
func copy_content():
	return []


# Returns the image var for image based cel types, or a render for procedural types.
# It's meant for read-only usage of image data, such as copying selections or color picking.
func get_image() -> Image:
	return null


func update_texture() -> void:
	return


func save_image_data_to_pxo(_file: File) -> void:
	return


func load_image_data_from_pxo(_file: File, _project_size: Vector2) -> void:
	return


func instantiate_cel_button() -> Node:
	return null
