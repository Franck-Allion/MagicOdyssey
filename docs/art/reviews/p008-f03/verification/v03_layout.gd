extends RefCounted
## Measured source-pixel geometry. All tokens use this single calibration.
const SOURCE_SIZE: Vector2 = Vector2(1536, 1024)
const SLOT_MARGIN: float = 4.0
const ATTACK: Vector2 = Vector2(233, 800)
const HEALTH: Vector2 = Vector2(1300, 800)
const INLAY_SIZE: Vector2 = Vector2(296, 296)
const PRIMARY_POINTS: int = 260
const PRIMARY_WIDTH: float = 260.0
const PRIMARY_RADIUS: float = 116.0
# V03: measured neutral plaque interiors at the y845 centerline.
# Insets retain the official materials' proportions inside the bronze rim.
const ARMOR: Rect2 = Rect2(420, 787, 322, 116)
const SHIELD: Rect2 = Rect2(802, 785, 312, 120)
const SECONDARY_POINTS: int = 170
const SECONDARY_WIDTH: float = 260.0
const PORTRAIT_BOUNDS: Rect2 = Rect2(112, 116, 1304, 620)
# Polygon extends under the inner metal edge; excludes stat cavities and band.
const PORTRAIT_POLYGON: Array[Vector2] = [
	Vector2(210,110), Vector2(1320,110), Vector2(1370,125),
	Vector2(1405,150), Vector2(1425,190), Vector2(1425,590),
	Vector2(1410,625), Vector2(1370,658), Vector2(1300,640),
	Vector2(1220,660), Vector2(1170,700), Vector2(1130,740),
	Vector2(410,740), Vector2(370,720), Vector2(320,670),
	Vector2(233,640), Vector2(155,663), Vector2(115,630),
	Vector2(100,590), Vector2(100,190), Vector2(115,150), Vector2(155,120)]
const STATUS_ORIGIN: Vector2 = Vector2(410, 150)
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
