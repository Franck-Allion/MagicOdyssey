class_name CardContentOverlay
extends Control
## Presentation-only, native Label/RichTextLabel layout in frame-v03 source pixels.
## configure() is transactional: unsupported content returns an explicit error;
## the last accepted display remains intact and the caller retains the full input.
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const LAYOUT: GDScript = preload("res://scripts/presentation/card_view_layout.gd")

const TITLE_BOUNDS: Rect2 = CardViewLayout.TITLE_BOUNDS
const TYPE_BOUNDS: Rect2 = CardViewLayout.TYPE_BOUNDS
const TYPE_SIZE: int = CardViewLayout.TYPE_SIZE
## Narrow body column clears the upper shoulders of both original footer sockets.
const RULES_BOUNDS: Rect2 = CardViewLayout.RULES_BOUNDS
const TITLE_PREFERRED: int = 68
const TITLE_MINIMUM: int = 40
const RULES_PREFERRED: int = 48
const RULES_MINIMUM: int = 30

enum Category { CREATURE, SPELL, EQUIPMENT }

class KeywordSpan extends RefCounted:
	var start: int
	var length: int
	func _init(at: int, count: int) -> void:
		start = at
		length = count

class Content extends RefCounted:
	var title: String
	var category: Category
	var tribe: String
	var rules: String
	var keywords: Array[KeywordSpan] = []
	func _init(card_title: String = "", card_category: Category = Category.CREATURE,
			card_tribe: String = "", card_rules: String = "") -> void:
		title = card_title
		category = card_category
		tribe = card_tribe
		rules = card_rules

var title_font_size: int = TITLE_PREFERRED
var rules_font_size: int = RULES_PREFERRED
var title_overflow: bool = false
var rules_overflow: bool = false
var overflow_reason: String = ""
var accepted_content: Content
var title_label: Label
var type_label: Label
var rules_label: RichTextLabel

var active_title_bounds: Rect2 = TITLE_BOUNDS
var active_type_bounds: Rect2 = TYPE_BOUNDS
var active_rules_bounds: Rect2 = RULES_BOUNDS
var active_type_size: int = TYPE_SIZE

func _init() -> void:
	theme = TOKENS.THEME
	size = Vector2(1086, 1448)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_rules_bounds(p_bounds: Rect2) -> void:
	active_rules_bounds = p_bounds

func set_layout(p_rules_bounds: Rect2, p_title_bounds: Rect2 = TITLE_BOUNDS, p_type_bounds: Rect2 = TYPE_BOUNDS, p_type_size: int = TYPE_SIZE) -> void:
	active_rules_bounds = p_rules_bounds
	active_title_bounds = p_title_bounds
	active_type_bounds = p_type_bounds
	active_type_size = p_type_size

func _title(value: String, points: int) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.position = active_title_bounds.position
	label.size = active_title_bounds.size
	label.theme = TOKENS.THEME
	label.theme_type_variation = &"CardTitle"
	label.add_theme_font_size_override("font_size", points)
	label.add_theme_color_override("font_color", TOKENS.color_token(&"text_bright"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_constant_override("line_separation", -6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _rules(data: Content, points: int) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.theme = TOKENS.THEME
	label.position = active_rules_bounds.position
	label.size = active_rules_bounds.size
	label.scroll_active = false
	label.threaded = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("normal_font_size", points)
	label.add_theme_font_size_override("bold_font_size", points)
	label.add_theme_constant_override("line_separation", 0)
	label.add_theme_color_override("default_color", TOKENS.color_token(&"text"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	# Spans are literal character ranges, never BBCode interpreted from card data.
	# Sorted non-overlapping spans are validated before this method is called.
	var cursor: int = 0
	for span: KeywordSpan in data.keywords:
		label.add_text(data.rules.substr(cursor, span.start-cursor))
		label.push_bold()
		label.add_text(data.rules.substr(span.start, span.length))
		label.pop()
		cursor = span.start+span.length
	label.add_text(data.rules.substr(cursor))
	label.pop()
	return label

func configure(data: Content, custom_rules_bounds: Rect2 = Rect2(), custom_type_bounds: Rect2 = Rect2(), custom_type_size: int = 0, type_glyph_spacing: int = 0) -> Error:
	if custom_rules_bounds.size != Vector2.ZERO:
		active_rules_bounds = custom_rules_bounds
	if custom_type_bounds.size != Vector2.ZERO:
		active_type_bounds = custom_type_bounds
	if custom_type_size > 0:
		active_type_size = custom_type_size
	title_overflow = false
	rules_overflow = false
	overflow_reason = ""
	if data == null or data.title.strip_edges().is_empty() or data.title.contains("\n"):
		overflow_reason = "A non-empty single-line title is required."
		return ERR_INVALID_DATA
	var cursor: int = 0
	for span: KeywordSpan in data.keywords:
		if span.start < cursor or span.length <= 0 or span.start+span.length > data.rules.length():
			overflow_reason = "Keyword spans must be ordered, non-overlapping character ranges."
			return ERR_INVALID_DATA
		cursor = span.start+span.length
	var display_font: Font = TOKENS.THEME.get_font(&"font", &"CardTitle")
	var type_text: String = category_name(data.category) + (" · " + data.tribe if data.category == Category.CREATURE and not data.tribe.is_empty() else "")
	if display_font.get_string_size(type_text, HORIZONTAL_ALIGNMENT_LEFT, -1, active_type_size).x > active_type_bounds.size.x:
		overflow_reason = "Type/tribe line exceeds its supported width."
		return ERR_PARAMETER_RANGE_ERROR
	var preferred_width: float = display_font.get_string_size(data.title, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_PREFERRED).x
	var title_points: int = clampi(int(TITLE_PREFERRED * active_title_bounds.size.x / maxf(preferred_width, 1.0)), TITLE_MINIMUM, TITLE_PREFERRED)
	while title_points > TITLE_MINIMUM and display_font.get_string_size(data.title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_points).x > active_title_bounds.size.x:
		title_points -= 1
	var single_fits: bool = display_font.get_string_size(data.title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_points).x <= active_title_bounds.size.x

	# Controlled wrapping (P005-R09B): if title is long and multi-word, evaluate 2-line wrap
	# to preserve comfortable physical legibility (aiming for >= 12 physical px at 720p).
	if title_points < 52 and data.title.contains(" "):
		var test_points: int = 48
		while test_points > title_points:
			var p: TextParagraph = TextParagraph.new()
			p.width = active_title_bounds.size.x
			p.alignment = HORIZONTAL_ALIGNMENT_CENTER
			p.line_spacing = -6.0
			p.add_string(data.title, display_font, test_points)
			if p.get_line_count() <= 2 and p.get_size().y <= active_title_bounds.size.y:
				title_points = test_points
				single_fits = true
				break
			test_points -= 1

	title_overflow = not single_fits
	var candidate_rules: RichTextLabel
	var rule_points: int = RULES_PREFERRED
	while true:
		candidate_rules = _rules(data, rule_points)
		# Native synchronous shaping; attach before querying content dimensions.
		add_child(candidate_rules)
		var fits: bool = candidate_rules.get_content_height() <= active_rules_bounds.size.y and candidate_rules.get_content_width() <= active_rules_bounds.size.x
		if fits or rule_points == RULES_MINIMUM:
			rules_overflow = not fits
			break
		remove_child(candidate_rules)
		candidate_rules.free()
		rule_points -= 1
	if title_overflow or rules_overflow:
		remove_child(candidate_rules)
		candidate_rules.free()
		overflow_reason = "Content exceeds the title/rules envelope at the minimum readable font size."
		return ERR_PARAMETER_RANGE_ERROR
	if is_instance_valid(title_label):
		title_label.free()
		type_label.free()
		rules_label.free()
	title_label = _title(data.title, title_points)
	add_child(title_label)
	type_label = _title(type_text, active_type_size)
	type_label.position = active_type_bounds.position
	type_label.size = active_type_bounds.size
	type_label.add_theme_color_override("font_color", TOKENS.color_token(&"accent"))
	if type_glyph_spacing != 0:
		var category_font: FontVariation = FontVariation.new()
		category_font.base_font = TOKENS.THEME.get_font(&"font", &"CardTitle")
		category_font.spacing_glyph = type_glyph_spacing
		type_label.add_theme_font_override(&"font", category_font)
	add_child(type_label)
	rules_label = candidate_rules
	# Center the native wrapped block in the available panel without stretching lines.
	var height: float = float(rules_label.get_content_height())
	rules_label.position.y += floorf((active_rules_bounds.size.y-height)*0.5)
	rules_label.size.y = maxf(1.0, height)
	title_font_size = title_points
	rules_font_size = rule_points
	accepted_content = data
	return OK

static func category_name(category: Category) -> String:
	match category:
		Category.SPELL: return "Spell"
		Category.EQUIPMENT: return "Equipment"
		_: return "Creature"
