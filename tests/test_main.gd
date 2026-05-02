extends GutTest

const NpcScene = preload("res://entities/characters/NPC.tscn")
const HudScene = preload("res://ui/hud.tscn")
const MainScript = preload("res://main.gd")

var main_node: Node3D
var hud: HUD


func before_each() -> void:
	hud = HudScene.instantiate()
	hud.name = "MainHUD"
	main_node = Node3D.new()
	main_node.set_script(MainScript)
	main_node.add_child(hud)
	add_child_autofree(main_node)


func _add_npc(dead: bool = false) -> NPC:
	var npc: NPC = NpcScene.instantiate()
	add_child_autofree(npc)
	npc.is_dead = dead
	return npc


func test_no_enemies_counts_as_all_dead() -> void:
	assert_true(main_node._are_all_enemies_dead())


func test_alive_enemy_means_not_all_dead() -> void:
	_add_npc(false)
	assert_false(main_node._are_all_enemies_dead())


func test_dead_enemy_counts_as_all_dead() -> void:
	_add_npc(true)
	assert_true(main_node._are_all_enemies_dead())


func test_mix_of_alive_and_dead_is_not_all_dead() -> void:
	_add_npc(true)
	_add_npc(false)
	assert_false(main_node._are_all_enemies_dead())


func test_last_enemy_death_reveals_win_hud() -> void:
	var npc := _add_npc()
	npc.died.connect(main_node._on_enemy_died)
	npc.is_dead = true
	npc.died.emit()
	assert_true(hud.visible)
	assert_true(hud.win_message.visible)


func test_partial_enemy_death_keeps_hud_hidden() -> void:
	var dead_npc := _add_npc()
	_add_npc()  # second enemy stays alive
	dead_npc.died.connect(main_node._on_enemy_died)
	dead_npc.is_dead = true
	dead_npc.died.emit()
	assert_false(hud.visible)
