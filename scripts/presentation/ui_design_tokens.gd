class_name UIDesignTokens
extends RefCounted
## The native Theme owns palette and spacing values. Reuse these accessors.
const THEME: Theme = preload("res://resources/themes/fantasy_theme.tres")

static func color_token(token: StringName) -> Color:
	assert(THEME.has_color(token, &"DesignTokens"), "Unknown UI color token: %s" % token)
	return THEME.get_color(token, &"DesignTokens")

static func spacing(size_name: StringName) -> int:
	var token: StringName = StringName("space_%s" % size_name)
	assert(THEME.has_constant(token, &"DesignTokens"), "Unknown spacing token: %s" % token)
	return THEME.get_constant(token, &"DesignTokens")
