extends SceneTree
## Measure actual GPU glyph rasterization on V05 for both geometry configurations.

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const FRAME_V05: Texture2D = preload("res://assets/textures/tokens/mo_creature_token_frame_v05_final.png")
const INLAY_ATTACK: Texture2D = preload("res://assets/textures/cards/icons/mo_inlay_attack.png")
const INLAY_HEALTH: Texture2D = preload("res://assets/textures/cards/icons/mo_inlay_health.png")
const PLATE_ARMOR: Texture2D = preload("res://assets/textures/cards/icons/mo_plate_armor.png")
const PLATE_SHIELD: Texture2D = preload("res://assets/textures/cards/icons/mo_plate_shield.png")
const PORTRAIT: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")

const OUT: String = "res://docs/art/reviews/p008-f03/"
const SOURCE_SIZE: Vector2 = Vector2(1536, 1024)

class TestToken extends CardSocketOverlay:
	var mode: String = "raised_b" # or "v05_housing"
	var values: Vector4i = Vector4i(12, 14, 10, 12) # atk, hlth, arm, shd
	var only_glyphs: bool = false
	var probe_stat: int = -1 # 0: atk, 1: arm, 2: shd, 3: hlth

	func _draw() -> void:
		var atk_c: Vector2 = Vector2(204, 821) if mode == "raised_b" else Vector2(216, 823)
		var hlth_c: Vector2 = Vector2(1332, 821) if mode == "raised_b" else Vector2(1320, 823)
		var arm_rect: Rect2 = Rect2(429, 598, 319, 110) if mode == "raised_b" else Rect2(365, 788, 380, 126)
		var shd_rect: Rect2 = Rect2(788, 592, 319, 122) if mode == "raised_b" else Rect2(780, 782, 380, 138)
		
		var primary_pts: int = 280
		var secondary_pts: int = 210
		var primary_rad: float = 122.0

		if not only_glyphs:
			# Background & portrait
			draw_rect(Rect2(Vector2.ZERO, SOURCE_SIZE), Color(0.08, 0.09, 0.12))
			draw_texture_rect(PORTRAIT, Rect2(94, 98, 1350, 674), false)
			# Inlays
			draw_texture_rect(INLAY_ATTACK, Rect2(atk_c - Vector2(160, 160), Vector2(320, 320)), false)
			draw_texture_rect(INLAY_HEALTH, Rect2(hlth_c - Vector2(160, 160), Vector2(320, 320)), false)
			# Frame
			draw_texture_rect(FRAME_V05, Rect2(Vector2.ZERO, SOURCE_SIZE), false)
			# Plaques
			if values.z > 0:
				draw_texture_rect(PLATE_ARMOR, arm_rect, false)
			if values.w > 0:
				draw_texture_rect(PLATE_SHIELD, shd_rect, false)

		var ink: Color = TOKENS.color_token(&"text_bright")
		
		# Draw numbers
		if probe_stat == -1 or probe_stat == 0:
			draw_number(atk_c, values.x, primary_pts, 260.0, ink, primary_rad, Vector2.ZERO)
		if probe_stat == -1 or probe_stat == 3:
			draw_number(hlth_c, values.y, primary_pts, 260.0, ink, primary_rad, Vector2.ZERO)
		if (probe_stat == -1 or probe_stat == 1) and values.z > 0:
			draw_number(arm_rect.get_center(), values.z, secondary_pts, 260.0, ink, 0.0, Vector2.ZERO)
		if (probe_stat == -1 or probe_stat == 2) and values.w > 0:
			draw_number(shd_rect.get_center(), values.w, secondary_pts, 260.0, ink, 0.0, Vector2.ZERO)

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var results: Dictionary = {}
	
	for mode: String in ["raised_b", "v05_housing"]:
		results[mode] = {}
		for dim: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			var h: int = dim.y
			results[mode][h] = {}
			
			var vp: SubViewport = SubViewport.new()
			vp.size = dim
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(vp)
			
			var token: TestToken = TestToken.new()
			token.mode = mode
			var scale_factor: float = (154.0 / 1536.0) * (float(dim.y) / 1080.0)
			token.scale = Vector2.ONE * scale_factor
			token.position = (Vector2(dim) - SOURCE_SIZE * scale_factor) * 0.5
			vp.add_child(token)
			
			# Render full token
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var full_img: Image = vp.get_texture().get_image()
			full_img.save_png("%sv05_%s_%dp.png" % [OUT, mode, h])
			
			# Probe individual glyphs
			token.only_glyphs = true
			for stat_idx: int in range(4):
				var stat_name: String = ["atk", "arm", "shd", "hlth"][stat_idx]
				results[mode][h][stat_name] = {}
				token.probe_stat = stat_idx
				for val: int in [1, 2, 6, 8, 10, 12, 14, 99]:
					token.values = Vector4i(val, val, val, val)
					await process_frame
					await process_frame
					await RenderingServer.frame_post_draw
					var glyph_img: Image = vp.get_texture().get_image()
					# Measure ink
					var data: PackedByteArray = glyph_img.get_data()
					var w: int = glyph_img.get_width()
					var min_x: int = 9999
					var max_x: int = -1
					var min_y: int = 9999
					var max_y: int = -1
					for y: int in range(glyph_img.get_height()):
						for x: int in range(w):
							var offset: int = (y * w + x) * 4
							var r: int = data[offset]
							var g: int = data[offset + 1]
							var b: int = data[offset + 2]
							var a: int = data[offset + 3]
							if a >= 128 and r >= 150 and g >= 150 and b >= 140:
								if x < min_x: min_x = x
								if x > max_x: max_x = x
								if y < min_y: min_y = y
								if y > max_y: max_y = y
					if max_x >= min_x:
						var ink_w: int = max_x - min_x + 1
						var ink_h: int = max_y - min_y + 1
						results[mode][h][stat_name][val] = {"w": ink_w, "h": ink_h}
					else:
						results[mode][h][stat_name][val] = {"w": 0, "h": 0}
			vp.queue_free()
			await process_frame

	var f: FileAccess = FileAccess.open(OUT + "measured_ink_results.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(results, "  "))
	print("SAVED measured_ink_results.json")
	quit(0)
