extends GutTest

var NpcScene = preload("res://entities/characters/NPC.tscn")

var npc: NPC


func before_each():
	npc = NpcScene.instantiate()
	add_child_autofree(npc)


func after_each():
	if is_instance_valid(npc) and not npc.is_queued_for_deletion():
		npc.queue_free()
		npc = null


func test_npc_initialization():
	assert_not_null(npc, "NPC instance should be created")
	assert_eq(npc.speed, 3.0, "NPC default speed should be 3.0")
	assert_eq(npc.state, NPC.State.IDLE, "NPC should start in IDLE state")
	assert_null(npc.target, "NPC should have no target initially")


func test_state_can_be_set_to_chasing():
	npc.state = NPC.State.CHASING
	assert_eq(npc.state, NPC.State.CHASING, "State should be CHASING after assignment")


func test_state_can_be_set_back_to_idle():
	npc.state = NPC.State.CHASING
	npc.state = NPC.State.IDLE
	assert_eq(npc.state, NPC.State.IDLE, "State should be IDLE after re-assignment")


func test_vision_signal_with_player_body_triggers_chase():
	var fake_player := Node3D.new()
	fake_player.add_to_group("player")
	add_child_autofree(fake_player)

	npc._on_vision_area_body_entered(fake_player)

	assert_eq(npc.state, NPC.State.CHASING, "State should transition to CHASING")
	assert_eq(npc.target, fake_player, "Target should be set to the entering body")


func test_vision_signal_with_non_player_body_is_ignored():
	var non_player := Node3D.new()
	add_child_autofree(non_player)

	npc._on_vision_area_body_entered(non_player)

	assert_eq(npc.state, NPC.State.IDLE, "State should remain IDLE for non-player body")
	assert_null(npc.target, "Target should remain null for non-player body")
