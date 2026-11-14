class_name CardViewLayout
extends RefCounted
## Authoritative native card geometry for MagicOdyssey master frame v03.
## Reference coordinate space: 1086x1448 px (1:1 with source artwork).

## Native full-card bounds and dimensions
const CARD_SIZE: Vector2 = Vector2(1086, 1448)
const CARD_BOUNDS: Rect2 = Rect2(Vector2.ZERO, CARD_SIZE)

## Illustration aperture (visible window for portrait artwork)
const APERTURE_BOUNDS: Rect2 = Rect2(124, 207, 838, 642)
const PORTRAIT_CROP_REGION: Rect2 = Rect2(0, 34, 1086, 832)

## Socket aperture centers (measured from master frame v03 in T04B)
const MANA_CENTER: Vector2 = Vector2(153, 151)
const ATTACK_CENTER: Vector2 = Vector2(162, 1279)
const HEALTH_CENTER: Vector2 = Vector2(919, 1279)

## Nearest detected metal is >= 72 source px away; reserve 70 px safe disk.
const SOCKET_SAFE_RADIUS: float = 70.0

## Auxiliary stat badge / plate slots at bottom center of master frame
const ARMOR_SLOT_BOUNDS: Rect2 = Rect2(280, 1280, 198, 100)
const SHIELD_SLOT_BOUNDS: Rect2 = Rect2(608, 1280, 198, 100)
const BOTTOM_RARITY_GEM_CENTER: Vector2 = Vector2(543, 1330)

## Text layout bounds (CardContentOverlay)
const TITLE_BOUNDS: Rect2 = Rect2(292, 90, 610, 94)
const TYPE_BOUNDS: Rect2 = Rect2(180, 916, 726, 66)
const TYPE_SIZE: int = 48
const RULES_BOUNDS: Rect2 = Rect2(260, 990, 566, 210)
