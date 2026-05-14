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
	assert_not_null(npc.weapon, "NPC should have a weapon attached")
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

	npc.get_node("VisionArea").body_entered.emit(fake_player)

	assert_eq(npc.state, NPC.State.CHASING, "State should transition to CHASING")
	assert_eq(npc.target, fake_player, "Target should be set to the entering body")


func test_vision_signal_with_non_player_body_is_ignored():
	var non_player := Node3D.new()
	add_child_autofree(non_player)

	npc.get_node("VisionArea").body_entered.emit(non_player)

	assert_eq(npc.state, NPC.State.IDLE, "State should remain IDLE for non-player body")
	assert_null(npc.target, "Target should remain null for non-player body")


func test_vision_signal_ignored_when_already_chasing():
	var first_player := Node3D.new()
	first_player.add_to_group("player")
	add_child_autofree(first_player)
	var second_player := Node3D.new()
	second_player.add_to_group("player")
	add_child_autofree(second_player)

	npc.target = first_player
	npc.state = NPC.State.CHASING

	npc.get_node("VisionArea").body_entered.emit(second_player)

	assert_eq(npc.target, first_player, "Vision callback should not overwrite target outside IDLE")


func test_attack_range_and_resume_chase_range_defaults():
	assert_eq(npc.attack_range, 2.0, "attack_range default should be 2.0")
	assert_eq(npc.resume_chase_range, 3.0, "resume_chase_range default should be 3.0")


func test_tick_chasing_transitions_to_attacking_when_within_attack_range():
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(1.5, 0.0, 0.0)  # within default attack_range of 2.0
	npc.target = fake_player
	npc.state = NPC.State.CHASING

	npc._tick_chasing()

	assert_eq(npc.state, NPC.State.ATTACKING, "Should transition to ATTACKING when target is within attack_range")


func test_tick_chasing_stays_chasing_when_outside_attack_range():
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(2.5, 0.0, 0.0)  # beyond default attack_range of 2.0
	npc.target = fake_player
	npc.state = NPC.State.CHASING

	npc._tick_chasing()

	assert_eq(npc.state, NPC.State.CHASING, "Should remain CHASING when target is beyond attack_range")


func test_tick_attacking_transitions_to_chasing_when_beyond_resume_range():
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(4.0, 0.0, 0.0)  # beyond default resume_chase_range of 3.0
	npc.target = fake_player
	npc.state = NPC.State.ATTACKING

	npc._tick_attacking()

	assert_eq(npc.state, NPC.State.CHASING, "Should transition to CHASING when target moves beyond resume_chase_range")


func test_tick_attacking_stays_attacking_when_within_resume_range():
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(1.5, 0.0, 0.0)  # within default resume_chase_range of 3.0
	npc.target = fake_player
	npc.state = NPC.State.ATTACKING

	npc._tick_attacking()

	assert_eq(npc.state, NPC.State.ATTACKING, "Should remain ATTACKING when target is within resume_chase_range")


func test_died_signal_transitions_to_dead():
	npc.died.emit()
	assert_eq(npc.state, NPC.State.DEAD, "died signal should transition state to DEAD")


func test_enter_dead_zeros_velocity():
	npc.velocity = Vector3(5.0, 0.0, 0.0)
	npc.state = NPC.State.DEAD
	assert_eq(npc.velocity, Vector3.ZERO, "Entering DEAD should zero velocity")


func test_dead_npc_ignores_vision():
	var fake_player := Node3D.new()
	fake_player.add_to_group("player")
	add_child_autofree(fake_player)

	npc.state = NPC.State.DEAD

	npc.get_node("VisionArea").body_entered.emit(fake_player)

	assert_eq(npc.state, NPC.State.DEAD, "DEAD NPC should not react to vision")
	assert_null(npc.target, "DEAD NPC should not acquire a target")


func test_damage_taken_with_source_starts_chasing_source():
	var attacker := Node3D.new()
	add_child_autofree(attacker)

	npc.damage_taken.emit(1, attacker)

	assert_eq(npc.state, NPC.State.CHASING, "NPC should start chasing on damage with a source")
	assert_eq(npc.target, attacker, "NPC target should be set to the damage source")


func test_damage_taken_with_null_source_stays_idle():
	npc.damage_taken.emit(1, null)

	assert_eq(npc.state, NPC.State.IDLE, "NPC should not start chasing when damage source is null")
	assert_null(npc.target, "Target should remain null when damage source is null")


func test_enter_chasing_sets_nav_agent_target_position():
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(5.0, 0.0, 0.0)
	npc.target = fake_player

	npc.state = NPC.State.CHASING

	assert_eq(npc.nav_agent.target_position, fake_player.global_position,
		"Entering CHASING should set nav_agent.target_position so path calculation starts immediately")


func test_tick_chasing_velocity_points_toward_target_when_no_nav_path():
	# NPC placed off-origin. Without a baked NavigationRegion3D the NavigationAgent3D
	# returns Vector3.ZERO from get_next_path_position(). That produces a to_next
	# vector whose length is >= 0.1 (so the direct-movement fallback never fires),
	# pointing toward the origin rather than the target — the root cause of the
	# "NPC stands still and flickers" bug.
	npc.global_position = Vector3(10.0, 0.0, 0.0)
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(14.0, 0.0, 0.0)  # target is further right, beyond attack_range
	npc.target = fake_player
	npc.state = NPC.State.CHASING

	npc._tick_chasing()

	assert_gt(npc.velocity.x, 0.0,
		"Velocity must point toward the target (positive X); if nav_agent returns Vector3.ZERO the NPC incorrectly chases the origin instead")


func test_tick_chasing_sets_nonzero_velocity_when_target_is_distant():
	var fake_player := Node3D.new()
	add_child_autofree(fake_player)
	fake_player.global_position = Vector3(5.0, 0.0, 0.0)
	npc.target = fake_player
	npc.state = NPC.State.CHASING

	npc._tick_chasing()

	assert_ne(npc.velocity, Vector3.ZERO,
		"NPC should have non-zero velocity when chasing a target well beyond attack range")
