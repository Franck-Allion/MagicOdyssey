extends SceneTree
## Actual fixture cards and GPU numeral masks; no screenshot postprocessing.
const FIXTURE: PackedScene = preload("res://scenes/ui/art002_card_integration_test.tscn")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const OUT: String = "res://docs/art/reviews/art002/t04b/"
const VALUES: Array[int] = [0, 1, 4, 5, 7, 8, 9, 10, 11, 12, 15, 20, 25, 99, 100, 999]
const CENTERS: Array[Vector2] = [Vector2(153,151), Vector2(162,1279), Vector2(919,1279)]
const OLD: Array[Vector2] = [Vector2(154,157), Vector2(157,1284), Vector2(934,1284)]
const SOCKETS: PackedStringArray = ["Mana", "Attack", "Health"]
var _failures: int = 0
var _fixture: Control

class LegacyOverlay extends CardStatOverlay:
	func _draw() -> void:
		var ink: Color = TOKENS.color_token(&"text_bright")
		draw_number(Vector2(154,157), _mana, 126, 145, ink)
		draw_number(Vector2(157,1284), _attack, 126, 145, ink)
		draw_number(Vector2(934,1284), _max_health, 126, 145, ink)
		_socket_emblem(Vector2(157,1187), &"attack")
		_socket_emblem(Vector2(934,1187), &"health")

class NumeralProbe extends CardStatOverlay:
	var value: int = 5
	var target: Vector2 = Vector2.ZERO
	var legacy: bool = false
	func _draw() -> void:
		draw_number(target, value, 126, 145, Color.WHITE, 0.0 if legacy else SOCKET_SAFE_RADIUS)

func _initialize() -> void:
	call_deferred("_run")

func _viewport(dimensions: Vector2i) -> SubViewport:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = dimensions
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport

func _render(viewport: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()

func _label(parent: Control, text: String, bounds: Rect2, points: int = 23) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = bounds.position
	label.size = bounds.size
	label.add_theme_font_size_override("font_size", points)
	label.add_theme_color_override("font_color", TOKENS.color_token(&"text"))
	parent.add_child(label)

func _page(dimensions: Vector2i, title: String, subtitle: String) -> SubViewport:
	var viewport: SubViewport = _viewport(dimensions)
	var page: Control = Control.new()
	page.theme = TOKENS.THEME
	page.size = Vector2(1920,1080)
	page.scale = Vector2.ONE * dimensions.x / 1920.0
	viewport.add_child(page)
	var background: ColorRect = ColorRect.new()
	background.color = TOKENS.color_token(&"background")
	background.size = page.size
	page.add_child(background)
	_label(page, "MAGIC ODYSSEY / ART-002-T04B", Rect2(60,30,1750,50), 34)
	_label(page, title, Rect2(60,100,1750,50), 30)
	_label(page, subtitle, Rect2(60,160,1800,50), 22)
	return viewport

func _card(parent: Control, position: Vector2, height: float, value: int, legacy: bool = false) -> void:
	var card: Control = _fixture.call("_card", parent, position, height, 3, null, 0, 0, value, value, value) as Control
	if legacy:
		var previous: Node = card.get_child(card.get_child_count()-1)
		card.remove_child(previous)
		previous.queue_free()
		var replacement: LegacyOverlay = LegacyOverlay.new()
		card.add_child(replacement)
		replacement.set_printed_values(value, value, value)

func _socket(parent: Control, position: Vector2, socket: int, value: int, factor: float, legacy: bool = false) -> void:
	var crop: Control = Control.new()
	crop.position = position
	crop.size = Vector2.ONE * 250 * factor
	crop.clip_contents = true
	parent.add_child(crop)
	_card(crop, (Vector2.ONE * 125 - CENTERS[socket]) * factor, 1448 * factor, value, legacy)

func _save(viewport: SubViewport, filename: String) -> void:
	var image: Image = await _render(viewport)
	var code: Error = image.save_png(OUT + filename)
	print("CAPTURE %s size=%s exit=%d" % [filename, image.get_size(), code])
	if code != OK or image.get_size() != viewport.size:
		_failures += 1
	viewport.queue_free()
	await process_frame

func _comparison(filename: String, values: Array[int], title: String) -> void:
	var viewport: SubViewport = _page(Vector2i(1920,1080), title,
		"Original v03 sockets / TacticalNumber / actual 760 px inspection-card scale / no per-glyph nudges")
	var page: Control = viewport.get_child(0) as Control
	var spacing: float = 1690.0 / values.size()
	for row: int in range(3):
		_label(page, SOCKETS[row], Rect2(60,315+row*240,150,45), 26)
		for column: int in range(values.size()):
			var at: Vector2 = Vector2(210 + column*spacing, 250+row*240)
			_socket(page, at, row, values[column], 760.0/1448.0)
			_label(page, str(values[column]), Rect2(at+Vector2(48,155),Vector2(100,40)))
	await _save(viewport, filename)

func _hand(dimensions: Vector2i, filename: String) -> void:
	var viewport: SubViewport = _page(dimensions, "Multi-digit hand / all three sockets / complete numeric matrix",
		"Seven-card rows / 316 px reference card height / rows continue the 16-value matrix; samples are not catalog stats")
	var page: Control = viewport.get_child(0) as Control
	# Three review rows at the existing seven-card hand scale, not a 16-card hand.
	for row: int in range(3):
		for column: int in range(7):
			var index: int = row*7+column
			if index >= VALUES.size():
				continue
			_card(page, Vector2(84+column*253, 95+row*325), 316, VALUES[index])
	# Put the heading on a dedicated side-free top strip; cards begin below it.
	for index: int in range(1,4):
		page.get_child(index).visible = false
	_label(page, "ART-002-T04B / Mana, Attack and Health share each test value / 7 cards per row", Rect2(60,25,1800,45), 27)
	await _save(viewport, filename)

func _optical() -> void:
	var viewport: SubViewport = _page(Vector2i(1920,1080), "Asymmetric numerals / T04 registration versus measured v03 registration",
		"Each pair: T04 left, T04B right / enlarged actual cards / identical glyph-bounds algorithm and emblem positions")
	var page: Control = viewport.get_child(0) as Control
	var values: Array[int] = [1,5,7]
	for row: int in range(3):
		_label(page, SOCKETS[row], Rect2(60,320+row*245,160,45), 27)
		for column: int in range(3):
			for version: int in range(2):
				var at: Vector2 = Vector2(235+column*550+version*235,230+row*245)
				_socket(page, at, row, values[column], 0.85, version == 0)
				_label(page, "T04" if version == 0 else "T04B", Rect2(at+Vector2(75,215),Vector2(110,35)), 19)
	await _save(viewport, "socket_optical_alignment_1080p.png")

func _measure(output_directory: String = OUT) -> void:
	var csv: FileAccess = FileAccess.open(output_directory+"numeral_measurements.csv", FileAccess.WRITE)
	csv.store_csv_line(PackedStringArray(["version","socket","value","scale","ink_center_dx_px","ink_center_dy_px","centroid_dx_source","centroid_dy_source","outline_radius_source","ink_height_px","safe_fit","centered","emblem_clear"]))
	var viewport: SubViewport = _viewport(Vector2i(220,220))
	var probe: NumeralProbe = NumeralProbe.new()
	viewport.add_child(probe)
	var scales: Array[float] = [760.0/1448.0,316.0/1448.0,316.0/1448.0*2.0/3.0]
	var baseline_bad_fit: int = 0
	var baseline_bad_center: int = 0
	var max_final_error: float = 0
	var final_count: int = 0
	for legacy: bool in [true,false]:
		probe.legacy = legacy
		for socket: int in range(3):
			for factor: float in scales:
				var origin: Vector2 = Vector2(460,225) if factor == scales[0] else Vector2(84,586) * (2.0/3.0 if factor == scales[2] else 1.0)
				var projected: Vector2 = origin + CENTERS[socket]*factor
				var target_pixel: Vector2 = Vector2(110,110) + projected - projected.floor()
				probe.scale = Vector2.ONE*factor
				probe.position = target_pixel-CENTERS[socket]*factor
				probe.target = OLD[socket] if legacy else CENTERS[socket]
				for value: int in VALUES:
					probe.value = value
					probe.queue_redraw()
					var image: Image = await _render(viewport)
					var low: Vector2i = Vector2i(220,220)
					var high: Vector2i = Vector2i(-1,-1)
					var weighted: Vector2 = Vector2.ZERO
					var weight: float = 0
					var max_radius: float = 0
					var emblem_clear: bool = true
					for y: int in range(55,166):
						for x: int in range(55,166):
							var pixel: Color = image.get_pixel(x,y)
							var offset: Vector2 = Vector2(x+0.5,y+0.5)-target_pixel
							if pixel.a > 0.1:
								max_radius = maxf(max_radius, (offset.length()+0.707107)/factor)
								if socket > 0:
									var emblem: Vector2 = Vector2(157,1187) if socket == 1 else Vector2(934,1187)
									# Includes the 37 px collet shadow shifted 3 px downward.
									if (CENTERS[socket]+offset/factor).distance_to(emblem) <= 40.0+0.707107/factor:
										emblem_clear = false
							if pixel.a > 0.5 and pixel.r > 0.75:
								low = Vector2i(mini(low.x,x),mini(low.y,y))
								high = Vector2i(maxi(high.x,x),maxi(high.y,y))
							var coverage: float = pixel.a*pixel.r
							weighted += offset*coverage
							weight += coverage
					var center_error: Vector2 = (Vector2(low+high)+Vector2.ONE)*0.5-target_pixel
					var centroid: Vector2 = weighted/maxf(weight,0.001)/factor
					var fit: bool = max_radius <= 70.0
					var centered: bool = high.x >= 0 and center_error.abs().x <= 1.5 and center_error.abs().y <= 1.5
					csv.store_csv_line(PackedStringArray(["T04" if legacy else "T04B",SOCKETS[socket],str(value),str(factor),str(center_error.x),str(center_error.y),str(centroid.x),str(centroid.y),str(max_radius),str(high.y-low.y+1),str(fit),str(centered),str(emblem_clear)]))
					if legacy:
						baseline_bad_fit += 0 if fit else 1
						baseline_bad_center += 0 if centered else 1
					else:
						final_count += 1
						max_final_error = maxf(max_final_error,maxf(absf(center_error.x),absf(center_error.y)))
						if not fit or not centered or not emblem_clear:
							_failures += 1
							print("FAIL %s value=%d scale=%.5f radius=%.2f center=%s emblem_clear=%s" % [SOCKETS[socket],value,factor,max_radius,center_error,emblem_clear])
	csv.close()
	print("BASELINE observations: unsafe_circle=%d off_artwork_center=%d /144" % [baseline_bad_fit,baseline_bad_center])
	print("FINAL measured=%d max_ink_center_error_px=%.4f failures=%d" % [final_count,max_final_error,_failures])
	viewport.queue_free()
	await process_frame

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_fixture = FIXTURE.instantiate() as Control
	_fixture.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_fixture.size = Vector2(1920,1080)
	root.add_child(_fixture)
	_fixture.visible = false
	await _measure()
	await _comparison("single_digit_comparison_1080p.png", [0,1,4,5,7,8,9], "Single digits / independent Mana, Attack and Health sockets")
	await _comparison("double_digit_comparison_1080p.png", [10,11,12,15,20,25,99,100,999], "Two- and three-digit fit / independent Mana, Attack and Health sockets")
	await _hand(Vector2i(1280,720), "multi_digit_hand_720p.png")
	await _hand(Vector2i(1920,1080), "multi_digit_hand_1080p.png")
	await _optical()
	_fixture.queue_free()
	await process_frame
	print("T04B_FAILURES=%d" % _failures)
	quit(0 if _failures == 0 else 1)
