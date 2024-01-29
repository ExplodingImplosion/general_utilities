class_name BBCode

const color_wrapper: String = "[color=%s]%s[/color]"
static func add_bbcode(s: String, color: String) -> String:
	return color_wrapper%[color,s]

static func set_color(s: String, color: Color) -> String:
	return add_bbcode(s,color.to_html(false))
