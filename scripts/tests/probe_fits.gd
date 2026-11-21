extends SceneTree

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var ts: TextServer = TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	
	print("--- Probing Primary Fits ---")
	for radius: float in [116.0, 120.0, 122.0, 124.0]:
		print("Testing PRIMARY_RADIUS = %f:" % radius)
		for val: int in [1, 2, 6, 8, 10, 12, 14, 99]:
			var points: int = 300
			var squeeze: float = 0.80 if val >= 10 else 1.0
			var bounds: Rect2 = Rect2()
			while points > 1:
				var cursor: float = 0.0
				for index: int in range(str(val).length()):
					var glyph: int = ts.font_get_glyph_index(rid, points, str(val).unicode_at(index), 0)
					ts.font_render_glyph(rid, Vector2i(points, 0), glyph)
					var rect: Rect2 = Rect2(ts.font_get_glyph_offset(rid, Vector2i(points, 0), glyph) + Vector2(cursor, 0), ts.font_get_glyph_size(rid, Vector2i(points, 0), glyph))
					bounds = rect if index == 0 else bounds.merge(rect)
					cursor += ts.font_get_glyph_advance(rid, points, glyph).x
				if Vector2(bounds.size.x * squeeze, bounds.size.y).length() * 0.5 + 6.0 <= radius:
					break
				points -= 1
			# Physical height at 720p: points * (68.444 / 1024) * 0.7 (approx font em/ink ratio)
			var estimated_720p_ink: float = bounds.size.y * (68.444 / 1024.0)
			print("  Val %2d: points=%3d, bounds=(w=%5.1f, h=%5.1f), 720p ink=%.2f px" % [val, points, bounds.size.x * squeeze, bounds.size.y, estimated_720p_ink])
	quit(0)
