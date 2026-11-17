class_name CombatHudViewModel
extends RefCounted
## Presentation view-model representing a complete combat HUD state snapshot (P007).
## Contains player and opponent hero states, turn status, phase, End Turn availability,
## and recent action log entries. Strictly decoupled from CombatEngine.

enum Phase {
	TURN_START,
	ACTION,
	ATTACK,
	CLEANUP,
	MATCH_OVER
}

var player_hero: HeroHudViewModel
var opponent_hero: HeroHudViewModel
var turn_number: int = 1
var active_camp: BattlefieldSlot.Camp = BattlefieldSlot.Camp.PLAYER
var phase: Phase = Phase.ACTION
var end_turn_enabled: bool = true
var recent_actions: Array[String] = []

var turn_display_override: String = ""
var phase_display_override: String = ""

func _init(
	p_player_hero: HeroHudViewModel = null,
	p_opponent_hero: HeroHudViewModel = null,
	p_turn_number: int = 1,
	p_active_camp: BattlefieldSlot.Camp = BattlefieldSlot.Camp.PLAYER,
	p_phase: Phase = Phase.ACTION,
	p_end_turn_enabled: bool = true,
	p_recent_actions: Array[String] = []
) -> void:
	player_hero = p_player_hero if p_player_hero != null else HeroHudViewModel.new("Player", 30, 30, 1, 1, 30, 0)
	opponent_hero = p_opponent_hero if p_opponent_hero != null else HeroHudViewModel.new("Opponent", 30, 30, 1, 1, 30, 0)
	turn_number = p_turn_number
	active_camp = p_active_camp
	phase = p_phase
	end_turn_enabled = p_end_turn_enabled
	recent_actions.assign(p_recent_actions)

func is_valid() -> bool:
	if player_hero == null or not player_hero.is_valid():
		return false
	if opponent_hero == null or not opponent_hero.is_valid():
		return false
	if turn_number < 1:
		return false
	return true

func get_formatted_turn() -> String:
	if not turn_display_override.strip_edges().is_empty():
		return turn_display_override
	return "TURN %02d" % turn_number

func get_formatted_phase() -> String:
	if not phase_display_override.strip_edges().is_empty():
		return phase_display_override
	var camp_str: String = "PLAYER" if active_camp == BattlefieldSlot.Camp.PLAYER else "OPPONENT"
	match phase:
		Phase.TURN_START:
			return "%s  /  START" % camp_str
		Phase.ACTION:
			return "%s  /  ACTION" % camp_str
		Phase.ATTACK:
			return "END-OF-TURN ATTACK"
		Phase.CLEANUP:
			return "%s  /  CLEANUP" % camp_str
		Phase.MATCH_OVER:
			return "MATCH OVER"
		_:
			return "%s  /  ACTION" % camp_str

func duplicate_model() -> CombatHudViewModel:
	var actions_copy: Array[String] = []
	actions_copy.assign(recent_actions)
	var copy: CombatHudViewModel = CombatHudViewModel.new(
		player_hero.duplicate_model() if player_hero != null else null,
		opponent_hero.duplicate_model() if opponent_hero != null else null,
		turn_number,
		active_camp,
		phase,
		end_turn_enabled,
		actions_copy
	)
	copy.turn_display_override = turn_display_override
	copy.phase_display_override = phase_display_override
	return copy

static func create_default() -> CombatHudViewModel:
	var player: HeroHudViewModel = HeroHudViewModel.new("Player", 30, 30, 1, 1, 34, 0)
	var opponent: HeroHudViewModel = HeroHudViewModel.new("Opponent", 30, 30, 1, 1, 34, 0)
	var empty_actions: Array[String] = []
	return CombatHudViewModel.new(player, opponent, 1, BattlefieldSlot.Camp.PLAYER, Phase.ACTION, true, empty_actions)
