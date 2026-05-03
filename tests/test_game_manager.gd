extends GutTest

const NpcScene = preload("res://entities/characters/NPC.tscn")

var gm: GameManager


func before_each() -> void:
	gm = GameManager.new()
	add_child_autofree(gm)


func _add_npc(dead: bool = false) -> NPC:
	var npc: NPC = NpcScene.instantiate()
	add_child_autofree(npc)
	npc.is_dead = dead
	return npc


func test_no_enemies_counts_as_all_dead() -> void:
	assert_true(gm._are_all_enemies_dead())


func test_alive_enemy_means_not_all_dead() -> void:
	_add_npc(false)
	assert_false(gm._are_all_enemies_dead())


func test_dead_enemy_counts_as_all_dead() -> void:
	_add_npc(true)
	assert_true(gm._are_all_enemies_dead())


func test_mix_of_alive_and_dead_is_not_all_dead() -> void:
	_add_npc(true)
	_add_npc(false)
	assert_false(gm._are_all_enemies_dead())


func test_last_enemy_death_emits_game_won() -> void:
	var npc := _add_npc()
	npc.died.connect(gm._on_enemy_died)
	watch_signals(gm)
	npc.is_dead = true
	npc.died.emit()
	assert_signal_emitted(gm.game_won)


func test_partial_enemy_death_does_not_emit_game_won() -> void:
	var dead_npc := _add_npc()
	_add_npc()
	dead_npc.died.connect(gm._on_enemy_died)
	watch_signals(gm)
	dead_npc.is_dead = true
	dead_npc.died.emit()
	assert_signal_not_emitted(gm.game_won)


func test_player_death_emits_game_lost() -> void:
	watch_signals(gm)
	gm._on_player_died()
	assert_signal_emitted(gm.game_lost)
