class_name CreatureTokenLayout
extends RefCounted
## Measured source-pixel geometry. All tokens use this single calibration.
const SOURCE_SIZE: Vector2 = Vector2(1536, 1024)
const SLOT_MARGIN: float = 4.0
const ATTACK: Vector2 = Vector2(216, 823)
const HEALTH: Vector2 = Vector2(1320, 823)
const INLAY_SIZE: Vector2 = Vector2(300, 300)
const PRIMARY_POINTS: int = 280
const PRIMARY_WIDTH: float = 260.0
const PRIMARY_RADIUS: float = 122.0
# V05 calibrated: measured neutral plaque interiors at the y851 centerline.
# Insets retain the official materials' proportions inside the bronze rim.
const ARMOR: Rect2 = Rect2(365, 788, 380, 126)
const SHIELD: Rect2 = Rect2(780, 782, 380, 138)
const SECONDARY_POINTS: int = 210
const SECONDARY_WIDTH: float = 280.0
const PORTRAIT_BOUNDS: Rect2 = Rect2(71, 75, 1395, 711)
# Polygon extends under the inner metal edge; excludes stat cavities and band.
const PORTRAIT_POLYGON: Array[Vector2] = [
	Vector2(150, 75), Vector2(768, 75), Vector2(1386, 75),
	Vector2(1465, 140), Vector2(1465, 625),
	Vector2(1420, 680), Vector2(1385, 680), Vector2(1310, 680), Vector2(1210, 720),
	Vector2(1171, 775), Vector2(1130, 778), Vector2(768, 785), Vector2(406, 778), Vector2(365, 775),
	Vector2(326, 720), Vector2(226, 680), Vector2(151, 680), Vector2(116, 680),
	Vector2(71, 625), Vector2(71, 140)]
const STATUS_ORIGIN: Vector2 = Vector2(410, 150)
const INDICATOR_SIZE: Vector2 = Vector2(138, 124)
const INDICATOR_STEP: float = 146.0
const WEAPON: Vector2 = Vector2(260, 140)
const PROTECTION: Vector2 = Vector2(1140, 140)

# Variant B reference reservations (P008-F01 benchmark §4)
const VARIANT_B_ATTACK: Vector2 = Vector2(204, 821)
const VARIANT_B_HEALTH: Vector2 = Vector2(1332, 821)
const VARIANT_B_ARMOR: Rect2 = Rect2(428.5, 488.5, 319.0, 329.0)
const VARIANT_B_SHIELD: Rect2 = Rect2(788.5, 488.5, 319.0, 329.0)

static func fitted_rect(slot_size: Vector2) -> Rect2:
	var available: Vector2 = slot_size - Vector2.ONE * (SLOT_MARGIN * 2.0)
	var scale: float = minf(available.x / SOURCE_SIZE.x, available.y / SOURCE_SIZE.y)
	var target_size: Vector2 = SOURCE_SIZE * scale
	return Rect2((slot_size - target_size) * 0.5, target_size)

static func portrait_region(texture_size: Vector2) -> Rect2:
	var factor: float = maxf(PORTRAIT_BOUNDS.size.x / texture_size.x, PORTRAIT_BOUNDS.size.y / texture_size.y)
	var crop: Vector2 = PORTRAIT_BOUNDS.size / factor
	return Rect2(Vector2((texture_size.x - crop.x) * 0.5, 0.0), crop)
