extends SceneTree
func _init() -> void:
	var font: Font = UIDesignTokens.THEME.get_font(&"font", &"TacticalNumber")
	var ts: TextServer = TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	for points: int in [140, 170, 180, 190, 200, 220]:
		var result: Array[String] = []
		for value: int in [0, 1, 2, 3, 6, 8, 10, 12, 14]:
			var bounds: Rect2 = Rect2()
			var cursor: float = 0.0
			for index: int in range(str(value).length()):
				var glyph: int = ts.font_get_glyph_index(rid, points, str(value).unicode_at(index), 0)
				ts.font_render_glyph(rid, Vector2i(points, 0), glyph)
				var rect: Rect2 = Rect2(ts.font_get_glyph_offset(rid, Vector2i(points, 0), glyph) + Vector2(cursor, 0), ts.font_get_glyph_size(rid, Vector2i(points, 0), glyph))
				bounds = rect if index == 0 else bounds.merge(rect)
				cursor += ts.font_get_glyph_advance(rid, points, glyph).x
			result.append("%d:%s" % [value, bounds.size])
		print(points, " ", result)
	var records: Array[Dictionary] = []
	for primary: bool in [false,true]:
		for value: int in [0,1,2,3,6,8,10,12,14]:
			records.append(_fitted(value,primary))
	var file: FileAccess = FileAccess.open("res://docs/art/reviews/p008-c/c02/font_fit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(records,"  "))
	quit()

# Mirrors the unchanged shared renderer's font fit for reporting; physical ink
# bounds are independently measured from actual GPU probes in analyze.py.
func _fitted(value: int, primary: bool) -> Dictionary:
	var font: Font = UIDesignTokens.THEME.get_font(&"font",&"TacticalNumber")
	var points: int = CreatureTokenLayout.PRIMARY_POINTS if primary else CreatureTokenLayout.SECONDARY_POINTS
	var width: float = CreatureTokenLayout.PRIMARY_WIDTH if primary else CreatureTokenLayout.SECONDARY_WIDTH
	var radius: float = CreatureTokenLayout.PRIMARY_RADIUS if primary else 0.0
	var measured: Vector2 = font.get_string_size(str(value),HORIZONTAL_ALIGNMENT_LEFT,-1,points)
	var fitted: int = mini(points,maxi(1,int(points * width / maxf(measured.x,1.0))))
	var ts: TextServer = TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	var bounds: Rect2 = Rect2()
	while true:
		var cursor: float = 0.0
		for index: int in range(str(value).length()):
			var glyph: int = ts.font_get_glyph_index(rid,fitted,str(value).unicode_at(index),0)
			ts.font_render_glyph(rid,Vector2i(fitted,0),glyph)
			var rect: Rect2 = Rect2(ts.font_get_glyph_offset(rid,Vector2i(fitted,0),glyph)+Vector2(cursor,0),ts.font_get_glyph_size(rid,Vector2i(fitted,0),glyph))
			bounds = rect if index == 0 else bounds.merge(rect)
			cursor += ts.font_get_glyph_advance(rid,fitted,glyph).x
		if radius <= 0.0 or bounds.size.length()*0.5+4.0 <= radius or fitted <= 1:
			break
		fitted -= 1
	return {"kind":"primary" if primary else "secondary","value":value,"nominal_points":points,"fitted_source_points":fitted,"computed_fitted_physical_points_720p":fitted*154.0/1536.0*2.0/3.0,"source_glyph_cache_bounds":str(bounds)}
