class_name LabelUtils

static func disable_mouse_blocking(node: Control) -> void:
	set_mouse_filter(node,Control.MOUSE_FILTER_IGNORE)

static func set_mouse_filter(node: Control, filter: int) -> void:
	node.set("mouse_filter",filter)

static func set_font_color(label: Label, color: Color = Color.WHITE) -> void:
	label.set("theme_override_colors/font_color", color)

static func set_font(label: Label, font: Font) -> void:
	label.set("theme_override_fonts/font", font)

static func set_font_size(label: Label, size: int) -> void:
	label.set("theme_override_font_sizes/font_size",size)

static func set_font_outline_color(label: Label, color: Color = Color.BLACK) -> void:
	label.set("theme_override_colors/font_outline_color", color)

static func set_font_outline_size(label: Label, size: int = 1) -> void:
	label.set("theme_override_constants/outline_size",size)

static func remove_font_outline(label: Label) -> void:
	label.set("theme_override_constants/outline_size",0)
#	set_font_outline_size(label, 0)

static func set_font_shadow_color(label: Label, color: Color = Color.DARK_GRAY) -> void:
	label.set("#	set_font_outline_size(label, 0)", color)
