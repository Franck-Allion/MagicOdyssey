extends RefCounted
## Measured source-pixel geometry. All tokens use this single calibration.
const SOURCE_SIZE: Vector2 = Vector2(1536, 1024)
const SLOT_MARGIN: float = 4.0
const ATTACK: Vector2 = Vector2(220, 802)
const HEALTH: Vector2 = Vector2(1317, 802)
const INLAY_SIZE: Vector2 = Vector2(296, 296)
const PRIMARY_POINTS: int = 240
const PRIMARY_WIDTH: float = 260.0
const PRIMARY_RADIUS: float = 106.0
# V02: neutral interiors span roughly x381..750 / x788..1154 at y860.
# Insets retain each official material's aspect ratio and a common 336px width.
const ARMOR: Rect2 = Rect2(400, 802, 336, 116)
const SHIELD: Rect2 = Rect2(800, 796, 336, 128)
const SECONDARY_POINTS: int = 170
const SECONDARY_WIDTH: float = 260.0
const PORTRAIT_BOUNDS: Rect2 = Rect2(108, 84, 1320, 690)
# Polygon extends under the inner metal edge; excludes stat cavities and band.
const PORTRAIT_POLYGON: Array[Vector2] = [
	Vector2(300, 78), Vector2(1238, 78), Vector2(1335, 104),
	Vector2(1404, 171), Vector2(1422, 262), Vector2(1422, 550),
	Vector2(1400, 618), Vector2(1316, 644), Vector2(1215, 685),
	Vector2(1172, 748), Vector2(1125, 774), Vector2(410, 774),
	Vector2(363, 748), Vector2(320, 685), Vector2(220, 644),
	Vector2(136, 618), Vector2(114, 550), Vector2(114, 262),
	Vector2(132, 171), Vector2(201, 104)]
const STATUS_ORIGIN: Vector2 = Vector2(410, 120)
const INDICATOR_SIZE: Vector2 = Vector2(138, 124)
const INDICATOR_STEP: float = 146.0
const WEAPON: Vector2 = Vector2(260, 140)
const PROTECTION: Vector2 = Vector2(1140, 140)

static func fitted_rect(slot_size: Vector2) -> Rect2:
	var available: Vector2 = (slot_size - Vector2.ONE * SLOT_MARGIN * 2.0).max(Vector2.ZERO)
	var factor: float = minf(available.x / SOURCE_SIZE.x, available.y / SOURCE_SIZE.y)
	var fitted: Vector2 = SOURCE_SIZE * factor
	return Rect2((slot_size - fitted) * 0.5, fitted)

static func portrait_region(texture_size: Vector2) -> Rect2:
	var factor: float = maxf(PORTRAIT_BOUNDS.size.x / texture_size.x, PORTRAIT_BOUNDS.size.y / texture_size.y)
	var crop: Vector2 = PORTRAIT_BOUNDS.size / factor
	return Rect2(Vector2((texture_size.x - crop.x) * 0.5, 0.0), crop)
