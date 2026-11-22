extends SceneTree

func _init() -> void:
	var output: Array[Dictionary] = []
	var fonts: Array[Font] = [UIDesignTokens.THEME.get_font(&"font",&"TacticalNumber"),ThemeDB.fallback_font]
	for family: String in ["Segoe UI","Arial","Bahnschrift","Arial Narrow"]:
		var font: SystemFont = SystemFont.new()
		font.font_names = PackedStringArray([family])
		font.font_weight = 700
		fonts.append(font)
	for font: Font in fonts:
		var entry: Dictionary = {"family":font.get_font_name(),"style":font.get_font_style_name(),"rids":font.get_rids().size()}
		var server: TextServer = TextServerManager.get_primary_interface()
		entry["variation_coordinates"] = server.font_get_variation_coordinates(font.get_rids()[0])
		entry["supported_variations"] = server.font_supported_variation_list(font.get_rids()[0])
		if font is SystemFont:
			var system: SystemFont = font as SystemFont
			entry.merge({"requested":system.font_names,"antialiasing":system.antialiasing,"hinting":system.hinting,"oversampling":system.oversampling,"mipmaps":system.generate_mipmaps,"msdf":system.multichannel_signed_distance_field,"subpixel":system.subpixel_positioning})
		entry["12_at_185"] = font.get_string_size("12",HORIZONTAL_ALIGNMENT_LEFT,-1,185)
		entry["12_at_14"] = font.get_string_size("12",HORIZONTAL_ALIGNMENT_LEFT,-1,14)
		output.append(entry)
	var file: FileAccess = FileAccess.open("res://docs/art/reviews/p008-f04/fonts.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(output,"  "))
	print(JSON.stringify(output,"  "))
	var token: CreatureToken = CreatureToken.new()
	for value: int in [1,6,8,10,12,14,99,100]:
		print("SELECTED_FIT ",value," ",token.get_primary_fit(value))
	token.free()
	quit()
